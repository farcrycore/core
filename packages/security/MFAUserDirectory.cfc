<cfcomponent displayname="MFA User Directory" hint="Abstract base for user directories that support multi-factor authentication. Holds the whole MFA engine (TOTP, passkeys, recovery codes, the challenge and enrolment flow, secret-at-rest crypto and key-rotation migration) so a concrete credential directory gains MFA by extending this and implementing a small set of account hooks. Never instantiated directly (bAbstract); the security manager skips it during user-directory discovery." extends="UserDirectory" output="false" bAbstract="true">

	<!--- =============================
	  MFA engine

	  This abstract directory owns the second factor implementation. A concrete
	  directory (e.g. CLIENTUD) extends it and supplies the account hooks at the
	  foot of this file (getUserKey, getUserRoleIDs, recordMFAFailure,
	  resetLoginFailures, getUseridForKey), which are the only points that reach
	  into the directory's own user store.
	============================== --->

	<cffunction name="init" access="public" output="true" returntype="any" hint="Wires up the crypto and WebAuthn helpers shared by every MFA flow">
		<cfset super.init() />

		<cfset variables.oMFACrypto = createObject("component", application.factory.oUtils.getPath("security", "mfaCrypto")).init() />
		<cfset variables.oWebAuthn = createObject("component", application.factory.oUtils.getPath("security", "webauthn")).init() />

		<cfreturn this />
	</cffunction>

	<cffunction name="providesMFA" access="public" output="false" returntype="boolean" hint="An MFA directory can perform second factor verification; overrides the UserDirectory capability default">

		<cfreturn true />
	</cffunction>

	<cffunction name="requiresMFA" access="public" output="false" returntype="boolean" hint="True when this user must complete a second factor step at login: an enrolled user is always challenged, and policy can force a not-yet-enrolled user to enrol">
		<cfargument name="userid" type="string" required="true" />

		<cfset var userKey = getUserKey(arguments.userid) />

		<cfif getMFAMode() eq "off" or not len(userKey)>
			<cfreturn false />
		</cfif>

		<!--- an enrolled user is always challenged; a not-yet-enrolled user is only forced when policy makes MFA mandatory --->
		<cfif getFactorType().hasActiveAuthFactor(userKey=userKey, userDirectory=this.key)>
			<cfreturn true />
		</cfif>

		<cfreturn isMFAMandatory(arguments.userid) />
	</cffunction>

	<cffunction name="isMFAMandatory" access="public" output="false" returntype="boolean" hint="True when policy compels MFA for this user (required mode, or they hold a role in mfaRequiredRoles). Distinct from requiresMFA: a mandatory user may not remove their own factor, whereas a merely-enrolled user in optional mode may">
		<cfargument name="userid" type="string" required="true" />

		<cfset var mode = getMFAMode() />
		<cfset var lRequiredRoles = application.fapi.getConfig("security", "mfaRequiredRoles", "") />
		<cfset var lUserRoles = "" />
		<cfset var roleID = "" />

		<cfif mode eq "off">
			<cfreturn false />
		</cfif>

		<cfif mode eq "required">
			<cfreturn true />
		</cfif>

		<!--- optional mode: mandatory only for holders of a configured required role --->
		<cfif len(lRequiredRoles)>
			<cfset lUserRoles = getUserRoleIDs(arguments.userid) />
			<cfloop list="#lRequiredRoles#" index="roleID">
				<cfif listFindNoCase(lUserRoles, roleID)>
					<cfreturn true />
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn false />
	</cffunction>

	<cffunction name="getMFAForm" access="public" output="false" returntype="string" hint="Challenge form when enrolled, enrolment wizard when not (or while the post-enrolment recovery codes are still being shown)">
		<cfargument name="userid" type="string" required="true" />

		<cfset var stContext = getEnrolContext() />

		<!--- keep the enrolment view up while the just-issued recovery codes are displayed --->
		<cfif structKeyExists(stContext, "bRecoveryShown") and stContext.bRecoveryShown>
			<cfreturn "farMFAEnrol" />
		</cfif>

		<cfif getFactorType().hasActiveAuthFactor(userKey=getUserKey(arguments.userid), userDirectory=this.key)>
			<cfreturn "farMFAChallenge" />
		</cfif>

		<cfreturn "farMFAEnrol" />
	</cffunction>

	<cffunction name="issueMFAChallenge" access="public" output="false" returntype="struct" hint="Returns the pending-state context. TOTP and passkeys have nothing to push; when email is the user's only factor, a code is emailed now so it is waiting at the challenge screen.">
		<cfargument name="userid" type="string" required="true" />

		<cfset var stContext = structnew() />
		<cfset var userKey = getUserKey(arguments.userid) />

		<!--- auto-send an email code only when email is the user's sole factor (no totp/passkey to prefer) - avoids emailing a code on every login for a user who also has a strong factor. The code is stashed into the returned context (the pending mfa context). --->
		<cfif len(userKey)
				and getEmailOTPMode() neq "off"
				and not structIsEmpty(getFactorType().getActiveFactor(userKey=userKey, userDirectory=this.key, factorType="emailOTP"))
				and not getFactorType().hasStrongAuthFactor(userKey=userKey, userDirectory=this.key)>
			<cfset sendEmailOTPCode(userid=arguments.userid, stContext=stContext) />
		</cfif>

		<cfreturn stContext />
	</cffunction>

	<cffunction name="verifyMFA" access="public" output="false" returntype="struct" hint="Processes the interstitial post: challenge code, recovery code, enrolment confirmation or the post-enrolment acknowledgment">
		<cfargument name="userid" type="string" required="true" />

		<cfset var stResult = { verified = false, reason = "noSubmission", message = "", method = "" } />
		<cfset var stProperties = structnew() />
		<cfset var userKey = getUserKey(arguments.userid) />
		<cfset var stContext = getEnrolContext() />
		<cfset var stEnrol = structnew() />
		<cfset var stSend = structnew() />
		<cfset var bEnrolled = false />
		<cfset var bGraceSkippable = false />
		<cfset var sAction = "" />

		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

		<cfif not len(userKey)>
			<cfset stResult.reason = "userNotFound" />
			<cfset stResult.message = "Unable to verify your login. Please log in again." />
			<cfreturn stResult />
		</cfif>

		<!--- display sub-step: the factor is active and we are showing the one-time recovery codes.
		      Driven by persisted context (not transient POST data) so a refresh re-shows the codes
		      with the ack button rather than stranding the user. Only the ack advances; a re-POST of
		      the confirm form is ignored here (no duplicate enrolment, no burnt attempt). --->
		<cfif structKeyExists(stContext, "bRecoveryShown") and stContext.bRecoveryShown>
			<ft:processform action="mfaRecoveryAck">
				<cfset structDelete(stContext, "bRecoveryShown") />
				<cfset structDelete(stContext, "aRecoveryCodes") />
				<cfset stResult.verified = true />
				<cfset stResult.reason = "" />
				<cfset stResult.method = structKeyExists(stContext, "enrolMethod") ? stContext.enrolMethod : "totp" />
				<cfset structDelete(stContext, "enrolMethod") />
			</ft:processform>

			<cfif not stResult.verified>
				<!--- still on the display step: re-surface the codes from persisted state --->
				<cfset stResult.reason = "recoveryCodes" />
				<cfset stResult.bShowRecovery = true />
				<cfset stResult.aRecoveryCodes = stContext.aRecoveryCodes />
			</cfif>

			<cfreturn stResult />
		</cfif>

		<!--- SERVER-SIDE INVARIANT (security-critical gate): an ENROLLED user may only PROVE an existing factor
		      here; a NOT-yet-enrolled user may only ENROL. getMFAForm renders the matching form, but the client
		      controls what it posts, so this must be enforced server-side. Without it an attacker who holds the
		      password could POST a passkey REGISTRATION at the challenge screen - attestation is "none", so it is
		      unsigned and can be fabricated - reusing the rendered challenge, and a successful registration would
		      satisfy the second factor: a full MFA bypass. Adding a factor to an already-enrolled account happens
		      only in the post-login self-service page, never in this pre-auth interstitial. --->
		<cfset bEnrolled = getFactorType().hasActiveAuthFactor(userKey=userKey, userDirectory=this.key) />

		<!--- detect the action buttons. form.FarcryFormSubmitButton is only populated inside an ft:processform, so read each action through its own processform (the same mechanism the recovery-ack and the self-service actions use). --->
		<ft:processform action="mfaEmailSend"><cfset sAction = "mfaEmailSend" /></ft:processform>
		<ft:processform action="mfaSkip"><cfset sAction = "mfaSkip" /></ft:processform>
		<ft:processform action="mfaActivateEmail"><cfset sAction = "mfaActivateEmail" /></ft:processform>

		<!--- email code send/resend: a non-verifying action (throttled in the engine), so it never counts as a failed attempt. Sends into the pending context when proving, or the enrol context when enrolling. --->
		<cfif sAction eq "mfaEmailSend">
			<cfset stResult.method = "emailOTP" />
			<cfset stResult.reason = "emailCodeSent" />
			<cfif bEnrolled>
				<cfif isEmailFactorUsable(userKey) and not structIsEmpty(getFactorType().getActiveFactor(userKey=userKey, userDirectory=this.key, factorType="emailOTP"))>
					<cfset stSend = sendEmailOTPCode(userid=arguments.userid, stContext=stContext, contextKey="emailOTP") />
					<cfif stSend.sent>
						<cfset stResult.message = "We have emailed you a code." />
					<cfelseif stSend.reason eq "throttled">
						<cfset stResult.message = "A code was sent recently. Please check your email." />
					<cfelseif stSend.reason eq "noEmail">
						<cfset stResult.message = "There is no email address on file for your account. Contact your administrator." />
					<cfelse>
						<cfset stResult.message = "We could not send a code right now. Please try again in a moment." />
					</cfif>
				<cfelse>
					<cfset stResult.message = "Email verification is not available." />
				</cfif>
			<cfelse>
				<cfset stEnrol = startEmailOTPEnrolment(userid=arguments.userid) />
				<cfset stResult.message = len(stEnrol.message) ? stEnrol.message : "We have emailed you a code." />
			</cfif>
			<cfreturn stResult />
		</cfif>

		<cfif bEnrolled>

			<!--- prove an existing factor: a passkey assertion (opaque blobs read straight from the form post), an authenticator code, or a recovery code --->
			<cfif structKeyExists(form, "authenticatorData") and len(trim(form.authenticatorData))>
				<cfreturn verifyPasskeyAssertion(userid=arguments.userid, userKey=userKey) />
			</cfif>

			<ft:processform>
				<ft:processformObjects typename="farMFAChallenge" r_stProperties="stProperties">
					<cfset stResult = verifyChallengeCode(userid=arguments.userid, userKey=userKey, code=trim(stProperties.code)) />
					<ft:break>
				</ft:processformObjects>
			</ft:processform>

		<cfelse>

			<!--- grace period: a mandatory but not-yet-enrolled user may skip enrolment until the deadline. Re-checked server-side here (never trust a client-supplied skip). --->
			<cfset bGraceSkippable = graceSkipAvailable(arguments.userid) />
			<cfset stResult.bGraceSkippable = bGraceSkippable />
			<cfif bGraceSkippable and sAction eq "mfaSkip">
				<cfset stResult.skipped = true />
				<cfset stResult.reason = "" />
				<cfreturn stResult />
			</cfif>

			<!--- enrol a first factor: a passkey registration (the challenge is inherent to the create() ceremony), or a proven authenticator code --->
			<cfif structKeyExists(form, "attestationObject") and len(trim(form.attestationObject))>
				<cfset stResult.method = "passkey" />
				<cfset stEnrol = confirmPasskeyEnrolment(userid=arguments.userid, clientDataJSON=(structKeyExists(form, "clientDataJSON") ? form.clientDataJSON : ""), attestationObject=form.attestationObject, transports=(structKeyExists(form, "transports") ? form.transports : ""), label=(structKeyExists(form, "passkeyLabel") and len(trim(form.passkeyLabel)) ? form.passkeyLabel : "Passkey")) />
				<cfif stEnrol.bSuccess>
					<cfif arrayLen(stEnrol.aRecoveryCodes)>
						<!--- first factor: persist the codes so the display step survives a refresh; cleared on ack or login --->
						<cfset stContext.bRecoveryShown = true />
						<cfset stContext.aRecoveryCodes = stEnrol.aRecoveryCodes />
						<cfset stContext.enrolMethod = "passkey" />
						<cfset stResult.reason = "recoveryCodes" />
						<cfset stResult.bShowRecovery = true />
						<cfset stResult.aRecoveryCodes = stEnrol.aRecoveryCodes />
					<cfelse>
						<cfset stResult.verified = true />
						<cfset stResult.reason = "" />
					</cfif>
				<cfelse>
					<cfset stResult.reason = stEnrol.reason />
					<cfset stResult.message = stEnrol.message />
				</cfif>
				<cfreturn stResult />
			</cfif>

			<!--- email OTP enrolment (the mfaActivateEmail button marks the chosen method); recovery codes issue here as the first factor --->
			<cfif sAction eq "mfaActivateEmail">
				<ft:processform>
					<ft:processformObjects typename="farMFAEnrol" r_stProperties="stProperties">
						<cfset stEnrol = confirmEmailOTPEnrolment(userid=arguments.userid, code=trim(structKeyExists(stProperties, "otpcode") ? stProperties.otpcode : "")) />
						<cfif stEnrol.bSuccess>
							<cfif arrayLen(stEnrol.aRecoveryCodes)>
								<cfset stContext.bRecoveryShown = true />
								<cfset stContext.aRecoveryCodes = stEnrol.aRecoveryCodes />
								<cfset stContext.enrolMethod = "emailOTP" />
								<cfset stResult.reason = "recoveryCodes" />
								<cfset stResult.bShowRecovery = true />
								<cfset stResult.aRecoveryCodes = stEnrol.aRecoveryCodes />
							<cfelse>
								<cfset stResult.verified = true />
								<cfset stResult.reason = "" />
								<cfset stResult.method = "emailOTP" />
							</cfif>
						<cfelse>
							<cfset stResult.reason = stEnrol.reason />
							<cfset stResult.message = stEnrol.message />
							<cfset stResult.method = "emailOTP" />
						</cfif>
						<ft:break>
					</ft:processformObjects>
				</ft:processform>
				<cfreturn stResult />
			</cfif>

			<ft:processform>
				<ft:processformObjects typename="farMFAEnrol" r_stProperties="stProperties">
					<cfset stEnrol = confirmTOTPEnrolment(userid=arguments.userid, code=trim(stProperties.code)) />
					<cfif stEnrol.bSuccess>
						<!--- persist the codes so the display step survives a refresh; cleared on ack or login --->
						<cfset stContext.bRecoveryShown = true />
						<cfset stContext.aRecoveryCodes = stEnrol.aRecoveryCodes />
						<cfset stContext.enrolMethod = "totp" />
						<cfset stResult.reason = "recoveryCodes" />
						<cfset stResult.bShowRecovery = true />
						<cfset stResult.aRecoveryCodes = stEnrol.aRecoveryCodes />
					<cfelse>
						<cfset stResult.reason = stEnrol.reason />
						<cfset stResult.message = stEnrol.message />
						<cfset stResult.method = "totp" />
					</cfif>
					<ft:break>
				</ft:processformObjects>
			</ft:processform>

		</cfif>

		<cfreturn stResult />
	</cffunction>


	<!--- MFA engine: called by the contract methods above and by self-service / admin webskins --->

	<cffunction name="startTOTPEnrolment" access="public" output="false" returntype="struct" hint="Creates (or returns the in-progress) enrolment candidate and its provisioning URI">
		<cfargument name="userid" type="string" required="true" />

		<cfset var stResult = { bSuccess = true, message = "" } />
		<cfset var stContext = getEnrolContext() />

		<cfif not variables.oMFACrypto.isKeyConfigured()>
			<cfset application.security.logSecurityEvent(event="mfaUnavailable", level="error", message="mfa enrolment attempted without an encryption key configured", userid="#arguments.userid#_#this.key#") />
			<cfset stResult.bSuccess = false />
			<cfset stResult.message = "Multi-factor authentication is not fully configured on this site (missing encryption key). Please contact your administrator." />
			<cfreturn stResult />
		</cfif>

		<!--- keep the same candidate across re-renders so a refresh does not change the QR mid-scan --->
		<cfif not structKeyExists(stContext, "enrolSecret")>
			<cfset stContext.enrolSecret = variables.oMFACrypto.generateTOTPSecret() />
		</cfif>

		<cfset stResult.secret = stContext.enrolSecret />
		<cfset stResult.otpauthURI = variables.oMFACrypto.otpauthURI(issuer=getIssuer(), account=arguments.userid, secretB32=stContext.enrolSecret) />

		<cfreturn stResult />
	</cffunction>

	<cffunction name="confirmTOTPEnrolment" access="public" output="false" returntype="struct" hint="Verifies the confirmation code, activates the factor and issues recovery codes">
		<cfargument name="userid" type="string" required="true" />
		<cfargument name="code" type="string" required="true" />

		<cfset var stResult = { bSuccess = false, reason = "", message = "", aRecoveryCodes = arraynew(1) } />
		<cfset var stContext = getEnrolContext() />
		<cfset var stVerify = structnew() />
		<cfset var userKey = getUserKey(arguments.userid) />
		<cfset var sealed = "" />

		<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />

		<cfif not len(userKey) or not structKeyExists(stContext, "enrolSecret")>
			<cfset stResult.reason = "noCandidate" />
			<cfset stResult.message = "Your enrolment session has expired. Please start again." />
			<cfreturn stResult />
		</cfif>

		<cfset stVerify = variables.oMFACrypto.verifyTOTP(secretB32=stContext.enrolSecret, code=arguments.code) />

		<cfif not stVerify.verified>
			<!--- an enrolment typo does not feed the shared password lockout (the code derives from a secret we just showed the user; there is no credential to brute force here). The session-level attempts cap in security.cfc still applies. --->
			<cfset stResult.reason = "badCode" />
			<cfset stResult.message = "That code didn't match. Check the code in your authenticator app and try again." />
			<cfreturn stResult />
		</cfif>

		<cftry>
			<cfset sealed = variables.oMFACrypto.encryptSecret(stContext.enrolSecret) />
			<cfcatch>
				<cfset application.security.logSecurityEvent(event="mfaUnavailable", level="error", message="mfa secret encryption failed", userid="#arguments.userid#_#this.key#") />
				<cfset stResult.reason = "mfaUnavailable" />
				<cfset stResult.message = "Multi-factor authentication is not fully configured on this site. Please contact your administrator." />
				<cfreturn stResult />
			</cfcatch>
		</cftry>

		<!--- idempotent: a re-enrolment replaces the existing authenticator rather than stacking a second (dead) totp row --->
		<cfset getFactorType().removeFactors(userKey=userKey, userDirectory=this.key, factorType="totp") />
		<cfset getFactorType().createFactor(userKey=userKey, userDirectory=this.key, factorType="totp", stPayload={ secret = sealed, lastStep = stVerify.step }, label="Authenticator app", keyId=variables.oMFACrypto.envelopeKeyId(sealed)) />
		<cfset stResult.aRecoveryCodes = issueRecoveryCodes(userKey=userKey) />
		<cfset structDelete(stContext, "enrolSecret") />

		<cfset resetLoginFailures(userKey) />

		<cfset application.security.logSecurityEvent(event="mfaEnrolled", message="second factor enrolled", userid="#arguments.userid#_#this.key#", stFields={ method = "totp" }) />
		<farcry:logevent type="security" event="mfaEnrolled" userid="#arguments.userid#_#this.key#" notes="totp" />

		<cfset stResult.bSuccess = true />

		<cfreturn stResult />
	</cffunction>

	<cffunction name="startEmailOTPEnrolment" access="public" output="false" returntype="struct" hint="Sends a one-time code to the user's email to begin (or resend during) email OTP enrolment. Returns { bSuccess, reason, message }.">
		<cfargument name="userid" type="string" required="true" />

		<cfset var stResult = { bSuccess = true, reason = "", message = "" } />
		<cfset var stContext = getEnrolContext() />
		<cfset var stSend = structnew() />
		<cfset var userKey = getUserKey(arguments.userid) />

		<!--- server-side gate: email must be permitted for this user by the lever (off never; soleFactor only when no strong factor exists) - not merely hidden in the UI --->
		<cfif not len(userKey) or not isEmailFactorUsable(userKey)>
			<cfset stResult.bSuccess = false />
			<cfset stResult.reason = "emailNotAllowed" />
			<cfset stResult.message = "Email verification is not available." />
			<cfreturn stResult />
		</cfif>

		<cfset stSend = sendEmailOTPCode(userid=arguments.userid, stContext=stContext, contextKey="enrolEmailOTP") />

		<cfif not stSend.sent>
			<cfif stSend.reason eq "throttled">
				<!--- a code was sent very recently and is still valid; let the user enter it --->
				<cfset stResult.message = "A code was just sent. Please wait a moment before requesting another." />
			<cfelseif stSend.reason eq "noEmail">
				<cfset stResult.bSuccess = false />
				<cfset stResult.reason = "noEmail" />
				<cfset stResult.message = "We do not have an email address on file for your account. Contact your administrator." />
			<cfelse>
				<cfset stResult.bSuccess = false />
				<cfset stResult.reason = "mailError" />
				<cfset stResult.message = "We could not send a code right now. Please try again in a moment." />
			</cfif>
		</cfif>

		<cfreturn stResult />
	</cffunction>

	<cffunction name="confirmEmailOTPEnrolment" access="public" output="false" returntype="struct" hint="Verifies the emailed enrolment code, activates the email OTP factor, and issues recovery codes only when this is the user's first factor.">
		<cfargument name="userid" type="string" required="true" />
		<cfargument name="code" type="string" required="true" />

		<cfset var stResult = { bSuccess = false, reason = "", message = "", aRecoveryCodes = arraynew(1) } />
		<cfset var stContext = getEnrolContext() />
		<cfset var userKey = getUserKey(arguments.userid) />
		<cfset var stCheck = structnew() />
		<cfset var bFirstFactor = false />

		<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />

		<cfif not len(userKey) or not structKeyExists(stContext, "enrolEmailOTP")>
			<cfset stResult.reason = "noCandidate" />
			<cfset stResult.message = "Your enrolment session has expired. Please request a new code." />
			<cfreturn stResult />
		</cfif>

		<!--- server-side gate (defence in depth with startEmailOTPEnrolment): the lever must still permit email for this user --->
		<cfif not isEmailFactorUsable(userKey)>
			<cfset stResult.reason = "emailNotAllowed" />
			<cfset stResult.message = "Email verification is not available." />
			<cfreturn stResult />
		</cfif>

		<cfset stCheck = checkEmailCode(stCodeState=stContext.enrolEmailOTP, code=arguments.code) />

		<cfif not stCheck.matched or stCheck.expired>
			<!--- an enrolment typo does not feed the shared password lockout (the session-level attempts cap still applies) --->
			<cfset stResult.reason = stCheck.expired ? "codeExpired" : "badCode" />
			<cfset stResult.message = stCheck.expired ? "That code has expired. Request a new one." : "That code didn't match. Check the code we emailed you and try again." />
			<cfreturn stResult />
		</cfif>

		<cfset bFirstFactor = not getFactorType().hasActiveAuthFactor(userKey=userKey, userDirectory=this.key) />

		<!--- idempotent: replace any existing email factor rather than stacking a second --->
		<cfset getFactorType().removeFactors(userKey=userKey, userDirectory=this.key, factorType="emailOTP") />
		<cfset getFactorType().createFactor(userKey=userKey, userDirectory=this.key, factorType="emailOTP", stPayload={ enrolledAt = now() }, label="Email") />
		<cfset structDelete(stContext, "enrolEmailOTP") />

		<!--- only issue recovery codes when this is the first factor, so adding email alongside an existing factor does not replace the user's current codes --->
		<cfif bFirstFactor>
			<cfset stResult.aRecoveryCodes = issueRecoveryCodes(userKey=userKey) />
		</cfif>

		<cfset resetLoginFailures(userKey) />

		<cfset application.security.logSecurityEvent(event="mfaEnrolled", message="second factor enrolled", userid="#arguments.userid#_#this.key#", stFields={ method = "emailOTP" }) />
		<farcry:logevent type="security" event="mfaEnrolled" userid="#arguments.userid#_#this.key#" notes="emailOTP" />

		<cfset stResult.bSuccess = true />

		<cfreturn stResult />
	</cffunction>

	<cffunction name="regenerateRecoveryCodes" access="public" output="false" returntype="struct" hint="Replaces the user's recovery codes; returns the new set for one-time display">
		<cfargument name="userid" type="string" required="true" />

		<cfset var stResult = { bSuccess = false, aRecoveryCodes = arraynew(1) } />
		<cfset var userKey = getUserKey(arguments.userid) />

		<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />

		<cfif len(userKey)>
			<cfset stResult.aRecoveryCodes = issueRecoveryCodes(userKey=userKey) />
			<cfset stResult.bSuccess = true />

			<cfset application.security.logSecurityEvent(event="mfaEnrolled", message="recovery codes regenerated", userid="#arguments.userid#_#this.key#", stFields={ method = "recoveryCode" }) />
			<farcry:logevent type="security" event="mfaEnrolled" userid="#arguments.userid#_#this.key#" notes="recoveryCode" />
		</cfif>

		<cfreturn stResult />
	</cffunction>

	<cffunction name="resetMFA" access="public" output="false" returntype="numeric" hint="Removes all of a user's factors (admin reset or self-service disable); returns the number removed">
		<cfargument name="userKey" type="string" required="true" hint="The stable user key" />
		<cfargument name="by" type="string" required="false" default="admin" hint="self / admin" />

		<cfset var count = 0 />
		<cfset var uid = getUseridForKey(arguments.userKey) />
		<cfset var eventUserid = len(uid) ? "#uid#_#this.key#" : arguments.userKey />

		<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />

		<cfset count = getFactorType().removeFactors(userKey=arguments.userKey, userDirectory=this.key) />

		<cfif count gt 0>
			<cfset application.security.logSecurityEvent(event="mfaDisabled", message="second factor disabled", userid=eventUserid, stFields={ by = arguments.by }) />
			<farcry:logevent type="security" event="mfaDisabled" userid="#eventUserid#" notes="by #arguments.by#" />
		</cfif>

		<cfreturn count />
	</cffunction>

	<cffunction name="getMFAStatus" access="public" output="false" returntype="struct" hint="Enrolment status for self-service and admin views">
		<cfargument name="userid" type="string" required="true" />

		<cfset var stResult = structnew() />
		<cfset var userKey = getUserKey(arguments.userid) />

		<cfset stResult.mode = getMFAMode() />
		<cfset stResult.bEnabled = stResult.mode neq "off" />
		<cfset stResult.bKeyConfigured = variables.oMFACrypto.isKeyConfigured() />
		<cfset stResult.userKey = userKey />
		<cfset stResult.bEnrolled = len(userKey) and getFactorType().hasActiveAuthFactor(userKey=userKey, userDirectory=this.key) />
		<cfset stResult.bRequired = requiresMFA(userid=arguments.userid) />
		<cfset stResult.bMandatory = isMFAMandatory(userid=arguments.userid) />
		<cfif len(userKey)>
			<cfset stResult.qFactors = getFactorType().getFactors(userKey=userKey, userDirectory=this.key) />
		</cfif>

		<cfreturn stResult />
	</cffunction>


	<!--- passkey (WebAuthn) engine: called by the contract methods above and by self-service / login webskins. Public key material only, so unlike TOTP these never touch the encryption key. --->

	<cffunction name="startPasskeyEnrolment" access="public" output="false" returntype="struct" hint="Builds the registration options for a create() ceremony and stashes a fresh challenge for confirmPasskeyEnrolment. Does not require the encryption key.">
		<cfargument name="userid" type="string" required="true" />

		<cfset var stResult = { bSuccess = true, message = "", stOptions = structnew() } />
		<cfset var stContext = getEnrolContext() />
		<cfset var userKey = getUserKey(arguments.userid) />
		<cfset var aExclude = arraynew(1) />
		<cfset var stPk = "" />

		<cfif not len(userKey)>
			<cfset stResult.bSuccess = false />
			<cfset stResult.message = "Unable to start setup. Please log in again." />
			<cfreturn stResult />
		</cfif>

		<!--- exclude already-registered credentials so the same authenticator is not enrolled twice --->
		<cfloop array="#getFactorType().getPasskeys(userKey=userKey, userDirectory=this.key)#" index="stPk">
			<cfif structKeyExists(stPk.stPayload, "credentialId")>
				<cfset arrayAppend(aExclude, { id = stPk.stPayload.credentialId, transports = (structKeyExists(stPk.stPayload, "transports") and isArray(stPk.stPayload.transports) ? stPk.stPayload.transports : arraynew(1)) }) />
			</cfif>
		</cfloop>

		<cfset stContext.passkeyChallenge = variables.oWebAuthn.newChallenge() />
		<cfset stResult.stOptions = variables.oWebAuthn.buildRegistrationOptions(
			rpId = getRpId(),
			rpName = getRpName(),
			userKey = userKey,
			userName = arguments.userid,
			challenge = stContext.passkeyChallenge,
			aExcludeCredentials = aExclude,
			userVerification = getPasskeyUVPolicy().userVerification
		) />

		<cfreturn stResult />
	</cffunction>

	<cffunction name="confirmPasskeyEnrolment" access="public" output="false" returntype="struct" hint="Verifies a create() response, stores the passkey and (only when this is the user's first factor) issues recovery codes.">
		<cfargument name="userid" type="string" required="true" />
		<cfargument name="clientDataJSON" type="string" required="true" hint="base64url" />
		<cfargument name="attestationObject" type="string" required="true" hint="base64url" />
		<cfargument name="transports" type="string" required="false" default="" hint="comma list of transport hints from the client" />
		<cfargument name="label" type="string" required="false" default="Passkey" />

		<cfset var stResult = { bSuccess = false, reason = "", message = "", aRecoveryCodes = arraynew(1) } />
		<cfset var stContext = getEnrolContext() />
		<cfset var userKey = getUserKey(arguments.userid) />
		<cfset var stReg = structnew() />
		<cfset var stPayload = structnew() />
		<cfset var aTransports = arraynew(1) />
		<cfset var t = "" />

		<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />

		<cfif not len(userKey) or not structKeyExists(stContext, "passkeyChallenge")>
			<cfset stResult.reason = "noCandidate" />
			<cfset stResult.message = "Your setup session has expired. Please start again." />
			<cfreturn stResult />
		</cfif>

		<cfset stReg = variables.oWebAuthn.verifyRegistration(
			clientDataJSON = arguments.clientDataJSON,
			attestationObject = arguments.attestationObject,
			expectedChallenge = stContext.passkeyChallenge,
			aExpectedOrigins = getExpectedOrigins(),
			rpId = getRpId(),
			bRequireUserVerification = getPasskeyUVPolicy().bRequireUV
		) />

		<cfif not stReg.verified>
			<cfset stResult.reason = stReg.reason />
			<cfset stResult.message = len(stReg.message) ? stReg.message : "Your passkey could not be set up. Please try again." />
			<cfreturn stResult />
		</cfif>

		<cfif len(trim(arguments.transports))>
			<cfloop list="#arguments.transports#" index="t">
				<cfset arrayAppend(aTransports, trim(t)) />
			</cfloop>
		</cfif>

		<cfset stPayload = duplicate(stReg.stCredential) />
		<cfset stPayload.transports = aTransports />

		<cfset getFactorType().createFactor(userKey=userKey, userDirectory=this.key, factorType="passkey", stPayload=stPayload, label=left(trim(arguments.label), 255)) />

		<!--- first factor for this user? issue recovery codes as the account recovery fallback. A passkey added
		      alongside an existing factor keeps the codes already in place (no array returned = no display step). --->
		<cfif structIsEmpty(getFactorType().getActiveFactor(userKey=userKey, userDirectory=this.key, factorType="recoveryCode"))>
			<cfset stResult.aRecoveryCodes = issueRecoveryCodes(userKey=userKey) />
		</cfif>

		<cfset structDelete(stContext, "passkeyChallenge") />
		<cfset resetLoginFailures(userKey) />

		<cfset application.security.logSecurityEvent(event="mfaEnrolled", message="second factor enrolled", userid="#arguments.userid#_#this.key#", stFields={ method = "passkey" }) />
		<farcry:logevent type="security" event="mfaEnrolled" userid="#arguments.userid#_#this.key#" notes="passkey" />

		<cfset stResult.bSuccess = true />

		<cfreturn stResult />
	</cffunction>

	<cffunction name="getPasskeyAssertionOptions" access="public" output="false" returntype="struct" hint="Builds the assertion options for a get() ceremony and stashes a fresh challenge for verify. bSuccess is false when the user has no passkey to offer.">
		<cfargument name="userid" type="string" required="true" />

		<cfset var stResult = { bSuccess = false, stOptions = structnew() } />
		<cfset var stContext = getEnrolContext() />
		<cfset var userKey = getUserKey(arguments.userid) />
		<cfset var aAllow = arraynew(1) />
		<cfset var stPk = "" />

		<cfif not len(userKey)>
			<cfreturn stResult />
		</cfif>

		<cfloop array="#getFactorType().getPasskeys(userKey=userKey, userDirectory=this.key)#" index="stPk">
			<cfif structKeyExists(stPk.stPayload, "credentialId")>
				<cfset arrayAppend(aAllow, { id = stPk.stPayload.credentialId, transports = (structKeyExists(stPk.stPayload, "transports") and isArray(stPk.stPayload.transports) ? stPk.stPayload.transports : arraynew(1)) }) />
			</cfif>
		</cfloop>

		<cfif not arrayLen(aAllow)>
			<cfreturn stResult />
		</cfif>

		<cfset stContext.passkeyChallenge = variables.oWebAuthn.newChallenge() />
		<cfset stResult.stOptions = variables.oWebAuthn.buildAssertionOptions(
			rpId = getRpId(),
			challenge = stContext.passkeyChallenge,
			aAllowCredentials = aAllow,
			userVerification = getPasskeyUVPolicy().userVerification
		) />
		<cfset stResult.bSuccess = true />

		<cfreturn stResult />
	</cffunction>

	<cffunction name="removePasskey" access="public" output="false" returntype="boolean" hint="Removes one of the user's passkeys (self-service); leaves other factors and recovery codes in place. Ownership is checked in storage.">
		<cfargument name="userid" type="string" required="true" />
		<cfargument name="objectid" type="uuid" required="true" />

		<cfset var userKey = getUserKey(arguments.userid) />
		<cfset var bRemoved = false />

		<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />

		<cfif not len(userKey)>
			<cfreturn false />
		</cfif>

		<cfset bRemoved = getFactorType().removeFactorForUser(objectid=arguments.objectid, userKey=userKey, userDirectory=this.key) />

		<cfif bRemoved>
			<cfset application.security.logSecurityEvent(event="mfaDisabled", message="passkey removed", userid="#arguments.userid#_#this.key#", stFields={ method = "passkey", by = "self" }) />
			<farcry:logevent type="security" event="mfaDisabled" userid="#arguments.userid#_#this.key#" notes="passkey removed by self" />
		</cfif>

		<cfreturn bRemoved />
	</cffunction>

	<cffunction name="renamePasskey" access="public" output="false" returntype="boolean" hint="Renames one of the user's passkeys (self-service). Ownership is checked in storage.">
		<cfargument name="userid" type="string" required="true" />
		<cfargument name="objectid" type="uuid" required="true" />
		<cfargument name="label" type="string" required="true" />

		<cfset var userKey = getUserKey(arguments.userid) />

		<cfif not len(userKey)>
			<cfreturn false />
		</cfif>

		<cfreturn getFactorType().setFactorLabel(objectid=arguments.objectid, userKey=userKey, userDirectory=this.key, label=arguments.label) />
	</cffunction>

	<cffunction name="hasTOTPFactor" access="public" output="false" returntype="boolean" hint="True when the user has an active authenticator (TOTP) factor. Lets the challenge screen label the code field 'Authenticator code' rather than 'Recovery code' only when it applies.">
		<cfargument name="userid" type="string" required="true" />

		<cfset var userKey = getUserKey(arguments.userid) />

		<cfif not len(userKey)>
			<cfreturn false />
		</cfif>

		<cfreturn not structIsEmpty(getFactorType().getActiveFactor(userKey=userKey, userDirectory=this.key, factorType="totp")) />
	</cffunction>

	<!--- ============= Email OTP: availability and self-service ============= --->

	<cffunction name="emailFactorAvailable" access="public" output="false" returntype="boolean" hint="True when an emailed one-time code is offered to this user at the challenge screen: they have an active email factor and the mfaEmailOTP lever allows it now (soleFactor hides it once a strong factor exists).">
		<cfargument name="userid" type="string" required="true" />

		<cfset var userKey = getUserKey(arguments.userid) />

		<cfif not len(userKey)>
			<cfreturn false />
		</cfif>

		<cfreturn isEmailFactorUsable(userKey) and not structIsEmpty(getFactorType().getActiveFactor(userKey=userKey, userDirectory=this.key, factorType="emailOTP")) />
	</cffunction>

	<cffunction name="emailEnrolOffered" access="public" output="false" returntype="boolean" hint="True when email OTP may be offered as an enrolment option (the mfaEmailOTP lever is on). At first enrolment the user has no stronger factor, so both soleFactor and anyFactor allow it.">
		<cfreturn getEmailOTPMode() neq "off" />
	</cffunction>

	<cffunction name="emailEnrolAvailable" access="public" output="false" returntype="boolean" hint="True when this user may enrol email OTP now via self-service: the lever is on, they have not already enrolled email, and the soleFactor rule permits it (no strong factor present).">
		<cfargument name="userid" type="string" required="true" />

		<cfset var userKey = getUserKey(arguments.userid) />

		<cfif not len(userKey)>
			<cfreturn false />
		</cfif>
		<cfif getEmailOTPMode() eq "off">
			<cfreturn false />
		</cfif>
		<cfif not structIsEmpty(getFactorType().getActiveFactor(userKey=userKey, userDirectory=this.key, factorType="emailOTP"))>
			<cfreturn false />
		</cfif>

		<cfreturn isEmailFactorUsable(userKey) />
	</cffunction>

	<cffunction name="removeEmailFactor" access="public" output="false" returntype="boolean" hint="Removes the user's email OTP factor (self-service); returns true when one was removed. Other factors and recovery codes are left in place.">
		<cfargument name="userid" type="string" required="true" />

		<cfset var userKey = getUserKey(arguments.userid) />
		<cfset var n = 0 />

		<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />

		<cfif not len(userKey)>
			<cfreturn false />
		</cfif>

		<cfset n = getFactorType().removeFactors(userKey=userKey, userDirectory=this.key, factorType="emailOTP") />

		<cfif n gt 0>
			<cfset application.security.logSecurityEvent(event="mfaDisabled", message="email factor removed", userid="#arguments.userid#_#this.key#", stFields={ method = "emailOTP", by = "self" }) />
			<farcry:logevent type="security" event="mfaDisabled" userid="#arguments.userid#_#this.key#" notes="emailOTP removed by self" />
		</cfif>

		<cfreturn n gt 0 />
	</cffunction>

	<!--- ============= Grace period (staged rollout) ============= --->

	<cffunction name="graceSkipAvailable" access="public" output="false" returntype="boolean" hint="True when a mandatory but not-yet-enrolled user may skip enrolment during the grace period (drives the 'skip for now' option; the skip is always re-checked server-side on submit).">
		<cfargument name="userid" type="string" required="true" />

		<cfset var userKey = getUserKey(arguments.userid) />

		<cfif not len(userKey)>
			<cfreturn false />
		</cfif>
		<cfif getFactorType().hasActiveAuthFactor(userKey=userKey, userDirectory=this.key)>
			<cfreturn false />
		</cfif>

		<cfreturn isMFAMandatory(arguments.userid) and inMFAGrace(arguments.userid) />
	</cffunction>


	<!--- MFA private helpers --->

	<cffunction name="checkEmailCode" access="private" output="false" returntype="struct" hint="Checks a submitted code against a stashed email-code state { hash, expiresAt }; returns { matched, expired }. Match is via the hash comparison; expiry is by epoch seconds.">
		<cfargument name="stCodeState" type="struct" required="true" />
		<cfargument name="code" type="string" required="true" />

		<cfset var stResult = { matched = false, expired = false } />

		<cfif not structKeyExists(arguments.stCodeState, "hash")>
			<cfreturn stResult />
		</cfif>

		<cfif application.security.cryptlib.passwordMatchesHash(password=trim(arguments.code), hashedPassword=arguments.stCodeState.hash)>
			<cfset stResult.matched = true />
			<cfif not structKeyExists(arguments.stCodeState, "expiresAt") or variables.oMFACrypto.epochSeconds() gte arguments.stCodeState.expiresAt>
				<cfset stResult.expired = true />
			</cfif>
		</cfif>

		<cfreturn stResult />
	</cffunction>

	<cffunction name="verifyChallengeCode" access="private" output="false" returntype="struct" hint="Verifies a challenge submission: a 6 digit code against an emailed one-time code (when the lever allows it) then TOTP; anything else against recovery codes">
		<cfargument name="userid" type="string" required="true" />
		<cfargument name="userKey" type="string" required="true" />
		<cfargument name="code" type="string" required="true" />

		<cfset var stResult = { verified = false, reason = "badCode", message = "", method = "" } />
		<cfset var stFactor = structnew() />
		<cfset var stVerify = structnew() />
		<cfset var stRedeem = structnew() />
		<cfset var secret = "" />
		<cfset var stContext = getEnrolContext() />
		<cfset var stTOTPFactor = structnew() />
		<cfset var hasTOTP = false />
		<cfset var stEmailFactor = structnew() />
		<cfset var stEmailCheck = structnew() />
		<cfset var bEmailChallenge = false />

		<cfif not len(arguments.code)>
			<cfset stResult.reason = "noSubmission" />
			<cfreturn stResult />
		</cfif>

		<cfif len(arguments.code) eq 6 and isNumeric(arguments.code)>
			<!--- a 6 digit code is either an emailed one-time code or an authenticator (TOTP) code --->
			<cfset stTOTPFactor = getFactorType().getActiveFactor(userKey=arguments.userKey, userDirectory=this.key, factorType="totp") />
			<cfset hasTOTP = not structIsEmpty(stTOTPFactor) />
			<!--- email is in play only when the lever allows it for this user (soleFactor rejects it once a strong factor exists) and a code has actually been issued into the pending context --->
			<cfset bEmailChallenge = isEmailFactorUsable(arguments.userKey) and structKeyExists(stContext, "emailOTP") />

			<cfif bEmailChallenge>
				<cfset stEmailCheck = checkEmailCode(stCodeState=stContext.emailOTP, code=arguments.code) />
				<cfif stEmailCheck.matched>
					<cfset stResult.method = "emailOTP" />
					<cfif stEmailCheck.expired>
						<cfset stResult.reason = "codeExpired" />
						<cfset stResult.message = "That code has expired. Request a new one." />
						<cfreturn stResult />
					</cfif>
					<!--- valid emailed code: single use, so clear it and stamp the factor lastUsed --->
					<cfset structDelete(stContext, "emailOTP") />
					<cfset stEmailFactor = getFactorType().getActiveFactor(userKey=arguments.userKey, userDirectory=this.key, factorType="emailOTP") />
					<cfif not structIsEmpty(stEmailFactor)>
						<cfset getFactorType().updateFactorPayload(objectid=stEmailFactor.objectid, stPayload=stEmailFactor.stPayload) />
					</cfif>
					<cfset resetLoginFailures(arguments.userKey) />
					<cfset stResult.verified = true />
					<cfset stResult.reason = "" />
					<cfreturn stResult />
				<cfelseif not hasTOTP>
					<!--- the emailed code is the only 6 digit factor in play and it did not match --->
					<cfset stResult.method = "emailOTP" />
					<cfset stResult.message = "The code was not recognised." />
					<cfset stResult.bLocked = recordMFAFailure(userKey=arguments.userKey) />
					<cfreturn stResult />
				</cfif>
				<!--- did not match, but the user also has an authenticator: fall through and try it as a TOTP code --->
			</cfif>

			<cfif not hasTOTP>
				<!--- no authenticator, and no usable emailed code matched --->
				<cfset stResult.method = bEmailChallenge ? "emailOTP" : "totp" />
				<cfset stResult.message = "The code was not recognised." />
				<cfset stResult.bLocked = recordMFAFailure(userKey=arguments.userKey) />
				<cfreturn stResult />
			</cfif>

			<!--- authenticator (TOTP) code --->
			<cfset stResult.method = "totp" />
			<cfset stFactor = stTOTPFactor />

			<cftry>
				<cfset secret = variables.oMFACrypto.decryptSecret(stFactor.stPayload.secret) />
				<cfcatch>
					<cfset application.security.logSecurityEvent(event="mfaUnavailable", level="error", message="mfa secret decryption failed", userid="#arguments.userid#_#this.key#") />
					<cfset stResult.reason = "mfaUnavailable" />
					<cfset stResult.message = "Your authenticator code cannot be checked right now. Use a recovery code, or contact your administrator." />
					<cfreturn stResult />
				</cfcatch>
			</cftry>

			<cfset stVerify = variables.oMFACrypto.verifyTOTP(secretB32=secret, code=arguments.code, lastAcceptedStep=(structKeyExists(stFactor.stPayload, "lastStep") ? stFactor.stPayload.lastStep : 0)) />

			<cfif stVerify.verified>
				<cfset stFactor.stPayload.lastStep = stVerify.step />
				<!--- key rotation: if this secret is sealed under an old or unversioned key, re-wrap it with the current key now that the plaintext is in hand (lazy migration). Best-effort - a re-wrap failure must not block a valid login. --->
				<cfif variables.oMFACrypto.needsRewrap(stFactor.stPayload.secret)>
					<cftry>
						<cfset stFactor.stPayload.secret = variables.oMFACrypto.encryptSecret(secret) />
						<cfcatch><!--- keep the existing, still-valid envelope; re-wrap will be retried on the next successful verification ---></cfcatch>
					</cftry>
				</cfif>
				<cfset getFactorType().updateFactorPayload(objectid=stFactor.objectid, stPayload=stFactor.stPayload, keyId=variables.oMFACrypto.envelopeKeyId(stFactor.stPayload.secret)) />
				<cfset resetLoginFailures(arguments.userKey) />
				<cfset stResult.verified = true />
				<cfset stResult.reason = "" />
			<cfelse>
				<cfset stResult.reason = stVerify.reason />
				<cfset stResult.message = (stVerify.reason eq "replayedCode") ? "That code has already been used. Wait for your app to show a new code." : "The code was not recognised." />
				<cfset stResult.bLocked = recordMFAFailure(userKey=arguments.userKey) />
			</cfif>
		<cfelse>
			<!--- recovery code --->
			<cfset stResult.method = "recoveryCode" />
			<cfset stRedeem = getFactorType().redeemRecoveryCode(userKey=arguments.userKey, userDirectory=this.key, code=arguments.code) />

			<cfif stRedeem.redeemed>
				<cfset resetLoginFailures(arguments.userKey) />
				<cfset stResult.verified = true />
				<cfset stResult.reason = "" />
				<cfset stResult.recoveryRemaining = stRedeem.remaining />
			<cfelse>
				<cfset stResult.reason = "badRecoveryCode" />
				<cfset stResult.message = "The code was not recognised." />
				<cfset stResult.bLocked = recordMFAFailure(userKey=arguments.userKey) />
			</cfif>
		</cfif>

		<cfreturn stResult />
	</cffunction>

	<cffunction name="migrateStoredSecrets" access="public" output="false" returntype="struct" hint="Starts a background re-wrap of this directory's stored totp secrets onto the current encryption key - the bulk counterpart to the lazy re-wrap on verify. Returns immediately: seeds a server-scope progress record (server.farcryMFAMigration['<applicationname>|<directory>']) and spawns a thread that pages through only the factors still needing migration. Guarded so at most one migration runs per application+directory; a wedged flag from a killed thread ages out after 30 minutes. Idempotent, so a re-run after an interruption simply resumes.">
		<cfargument name="startedBy" type="string" required="false" default="" />
		<cfargument name="batchSize" type="numeric" required="false" default="200" />

		<cfset var appName = application.applicationname />
		<cfset var flagKey = appName & "|" & this.key />
		<cfset var currentId = variables.oMFACrypto.getCurrentKeyId() />
		<cfset var stStats = "" />
		<cfset var stResult = { started = false, reason = "" } />

		<cflock name="mfaMigration_#flagKey#" type="exclusive" timeout="10">
			<cfif not structKeyExists(server, "farcryMFAMigration")>
				<cfset server.farcryMFAMigration = structnew() />
			</cfif>
			<!--- refuse a second run only while one is genuinely live (running + active within the last 30 minutes); a wedged flag ages out --->
			<cfif structKeyExists(server.farcryMFAMigration, flagKey) and server.farcryMFAMigration[flagKey].running and migrationIsLive(server.farcryMFAMigration[flagKey])>
				<cfset stResult.reason = "alreadyRunning" />
				<cfreturn stResult />
			</cfif>

			<cfset stStats = getFactorType().getTOTPMigrationStats(currentKeyId=currentId, userDirectory=this.key) />
			<cfset server.farcryMFAMigration[flagKey] = {
				running = true, directory = this.key, keyId = currentId,
				startedBy = arguments.startedBy, startedAt = now(), finishedAt = "",
				total = stStats.needsMigration, done = 0, failed = 0,
				lastObjectId = "", lastRecordAt = "", lastError = ""
			} />
			<cfset stResult.started = true />
		</cflock>

		<cfthread action="run" name="mfaMigrate_#flagKey#_#createUUID()#" tdKey="#this.key#" tdCurrentId="#currentId#" tdBatch="#arguments.batchSize#" tdFlag="#flagKey#">
			<cfset stF = server.farcryMFAMigration[attributes.tdFlag] />
			<cfset lastId = "" />
			<cfset bMore = true />
			<cfset qPage = "" />
			<cfset stRow = "" />
			<cfset secret = "" />
			<cfset envId = "" />
			<cfset newSecret = "" />
			<cfset oFactor = "" />
			<cfset oCrypto = "" />
			<cfset batches = 0 />
			<cfset maxBatches = 0 />

			<cftry>
				<!--- acquire dependencies inside the try so a setup failure still clears the running flag (below) --->
				<cfset oFactor = application.fapi.getContentType("farMFAFactor") />
				<cfset oCrypto = createObject("component", application.factory.oUtils.getPath("security", "mfaCrypto")).init() />

				<!--- runaway backstop: the working set only shrinks (migrated rows drop out; new enrolments already seal with the current key), so in normal operation the loop ends on a short page well before this - it just bounds an unforeseen stuck cursor. Stopping early is safe: the migration is idempotent, so a re-run resumes. --->
				<cfset maxBatches = int(stF.total / attributes.tdBatch) + 50 />

				<cfloop condition="bMore">
					<cfset batches = batches + 1 />
					<cfif batches gt maxBatches>
						<cfset stF.lastError = "stopped at the safety cap (" & maxBatches & " batches) - re-run to finish" />
						<cfset application.fapi.logEvent("mfa", "warning", "mfa migration hit its safety cap; re-run to continue", { directory = attributes.tdKey, batches = batches }) />
						<cfbreak />
					</cfif>
					<cfset qPage = oFactor.getActiveTOTPMigrationPage(currentKeyId=attributes.tdCurrentId, userDirectory=attributes.tdKey, lastObjectId=lastId, maxRows=attributes.tdBatch) />

					<cfif qPage.recordcount eq 0>
						<cfset bMore = false />
					<cfelse>
						<cfloop query="qPage">
							<cfset lastId = qPage.objectid />
							<cftry>
								<cfif isJSON(qPage.payload)>
									<cfset stRow = deserializeJSON(qPage.payload) />
									<cfset secret = structKeyExists(stRow, "secret") ? stRow.secret : "" />
									<cfset envId = oCrypto.envelopeKeyId(secret) />
									<cfif len(secret) and oCrypto.needsRewrap(secret)>
										<!--- stale key: re-seal the plaintext onto the current key --->
										<cfset newSecret = oCrypto.encryptSecret(oCrypto.decryptSecret(secret)) />
										<cfif oFactor.writeFactorSecret(objectid=qPage.objectid, newSecret=newSecret, keyId=oCrypto.envelopeKeyId(newSecret)) gt 0>
											<cfset stF.done = stF.done + 1 />
										</cfif>
									<cfelseif len(envId)>
										<!--- envelope already on the current key; only the denormalised keyId column had drifted - reconcile it --->
										<cfif oFactor.writeFactorSecret(objectid=qPage.objectid, newSecret=secret, keyId=envId) gt 0>
											<cfset stF.done = stF.done + 1 />
										</cfif>
									<cfelse>
										<cfset stF.failed = stF.failed + 1 />
										<cfset application.fapi.logEvent("mfa", "warning", "mfa migration skipped a factor with no readable secret", { objectid = qPage.objectid, directory = attributes.tdKey }) />
									</cfif>
								<cfelse>
									<cfset stF.failed = stF.failed + 1 />
								</cfif>
								<cfcatch>
									<cfset stF.failed = stF.failed + 1 />
									<cfset application.fapi.logEvent("mfa", "warning", "mfa secret migration failed for a factor", { objectid = qPage.objectid, directory = attributes.tdKey, error = cfcatch.message }) />
								</cfcatch>
							</cftry>
							<cfset stF.lastObjectId = lastId />
							<cfset stF.lastRecordAt = now() />
						</cfloop>

						<cfif qPage.recordcount lt attributes.tdBatch>
							<cfset bMore = false />
						</cfif>
					</cfif>
				</cfloop>
				<cfset stF.finishedAt = now() />
				<cfcatch>
					<cfset stF.lastError = cfcatch.message />
					<cfset stF.finishedAt = now() />
				</cfcatch>
			</cftry>

			<cfset stF.running = false />
		</cfthread>

		<cfreturn stResult />
	</cffunction>

	<cffunction name="migrationIsLive" access="private" output="false" returntype="boolean" hint="True when a running migration flag has shown activity in the last 30 minutes; a wedged flag left by a killed thread ages out so a fresh run can start.">
		<cfargument name="stFlag" type="struct" required="true" />

		<cfset var lastActivity = "" />

		<cfif structKeyExists(arguments.stFlag, "lastRecordAt") and isDate(arguments.stFlag.lastRecordAt)>
			<cfset lastActivity = arguments.stFlag.lastRecordAt />
		<cfelseif structKeyExists(arguments.stFlag, "startedAt") and isDate(arguments.stFlag.startedAt)>
			<cfset lastActivity = arguments.stFlag.startedAt />
		</cfif>

		<cfif not isDate(lastActivity)>
			<cfreturn false />
		</cfif>

		<cfreturn dateDiff("n", lastActivity, now()) lt 30 />
	</cffunction>

	<cffunction name="issueRecoveryCodes" access="private" output="false" returntype="array" hint="Generates a fresh recovery code set, stores the hashes and returns the plain codes for one-time display">
		<cfargument name="userKey" type="string" required="true" />

		<cfset var aCodes = variables.oMFACrypto.generateRecoveryCodes(10) />
		<cfset var aHashes = arraynew(1) />
		<cfset var code = "" />

		<cfloop array="#aCodes#" index="code">
			<!--- hash the normalised form (no dash/case) so redemption matches regardless of how the user types it --->
			<cfset arrayAppend(aHashes, application.security.cryptlib.encodePassword(password=reReplace(ucase(code), "[^A-Z0-9]", "", "all"), hashname=getOutputHashName())) />
		</cfloop>

		<cfset getFactorType().saveRecoveryCodes(userKey=arguments.userKey, userDirectory=this.key, aHashes=aHashes) />

		<cfreturn aCodes />
	</cffunction>

	<cffunction name="getFactorType" access="private" output="false" returntype="any" hint="Returns the farMFAFactor type component">
		<cfreturn application.fapi.getContentType("farMFAFactor") />
	</cffunction>

	<cffunction name="getMFAMode" access="private" output="false" returntype="string" hint="The effective mfa mode: off / optional / required">
		<cfreturn application.fapi.getConfig("security", "mfaMode", "off") />
	</cffunction>

	<!--- ============= Email OTP internals ============= --->

	<cffunction name="getEmailOTPMode" access="private" output="false" returntype="string" hint="The email OTP policy: off / soleFactor / anyFactor (mfaEmailOTP config)">
		<cfreturn application.fapi.getConfig("security", "mfaEmailOTP", "off") />
	</cffunction>

	<cffunction name="isEmailFactorUsable" access="private" output="false" returntype="boolean" hint="Whether email OTP may be offered and accepted for this user right now, per the mfaEmailOTP lever: off never; anyFactor always; soleFactor only when the user has no strong factor (totp/passkey).">
		<cfargument name="userKey" type="string" required="true" />

		<cfset var mode = getEmailOTPMode() />

		<cfif mode eq "anyFactor">
			<cfreturn true />
		</cfif>
		<cfif mode eq "soleFactor">
			<cfreturn not getFactorType().hasStrongAuthFactor(userKey=arguments.userKey, userDirectory=this.key) />
		</cfif>
		<cfreturn false />
	</cffunction>

	<cffunction name="sendEmailOTPCode" access="private" output="false" returntype="struct" hint="Generates a one-time code, stores its hash and expiry (epoch seconds) in the given context struct in place, and emails the plaintext to the user. Throttled by mfaEmailResendSeconds; the code is stashed only on a successful send. Returns { sent, reason: throttled/noEmail/mailError }.">
		<cfargument name="userid" type="string" required="true" />
		<cfargument name="stContext" type="struct" required="true" hint="Context to stash the code state in (the pending mfa context for a challenge, or the enrol stash)" />
		<cfargument name="contextKey" type="string" required="false" default="emailOTP" hint="Key within the context (emailOTP for a challenge, enrolEmailOTP for enrolment)" />

		<cfset var stResult = { sent = false, reason = "" } />
		<cfset var email = "" />
		<cfset var code = "" />
		<cfset var hashedCode = "" />
		<cfset var timeoutMin = int(application.fapi.getConfig("security", "mfaChallengeTimeout", 10)) />
		<cfset var throttle = int(application.fapi.getConfig("security", "mfaEmailResendSeconds", 60)) />
		<cfset var nowEpoch = variables.oMFACrypto.epochSeconds() />
		<cfset var prevCount = 0 />

		<!--- everything that can throw (the profile read, hashing, the mail send) is inside the try, so a failure returns { sent=false } and can never bubble up to block login --->
		<cftry>
			<cfset email = getUserEmail(arguments.userid) />

			<cfif not len(email)>
				<cfset stResult.reason = "noEmail" />
				<cfreturn stResult />
			</cfif>

			<!--- throttle resends off the last successful send --->
			<cfif structKeyExists(arguments.stContext, arguments.contextKey)
					and structKeyExists(arguments.stContext[arguments.contextKey], "sentAt")
					and (nowEpoch - arguments.stContext[arguments.contextKey].sentAt) lt throttle>
				<cfset stResult.reason = "throttled" />
				<cfreturn stResult />
			</cfif>

			<cfif structKeyExists(arguments.stContext, arguments.contextKey) and structKeyExists(arguments.stContext[arguments.contextKey], "count")>
				<cfset prevCount = arguments.stContext[arguments.contextKey].count />
			</cfif>

			<!--- hash before sending, so a crypto failure never sends a code that can't be verified --->
			<cfset code = variables.oMFACrypto.generateNumericCode(6) />
			<cfset hashedCode = application.security.cryptlib.encodePassword(password=code, hashname=getOutputHashName()) />

			<cfset sendEmailOTPMessage(userid=arguments.userid, email=email, code=code) />

			<!--- stash only after a successful send --->
			<cfset arguments.stContext[arguments.contextKey] = {
				hash = hashedCode,
				expiresAt = nowEpoch + (timeoutMin * 60),
				sentAt = nowEpoch,
				count = prevCount + 1
			} />

			<cfset stResult.sent = true />

			<cfcatch>
				<cfset application.security.logSecurityEvent(event="mfaUnavailable", level="error", message="email one-time code send failed", userid="#arguments.userid#_#this.key#") />
				<cfset stResult.sent = false />
				<cfset stResult.reason = "mailError" />
			</cfcatch>
		</cftry>

		<cfreturn stResult />
	</cffunction>

	<cffunction name="sendEmailOTPMessage" access="private" output="false" returntype="void" hint="Emails a one-time code to the user (HTML mail from the configured admin address)">
		<cfargument name="userid" type="string" required="true" />
		<cfargument name="email" type="string" required="true" />
		<cfargument name="code" type="string" required="true" />

		<cfset var fromAddr = application.fapi.getConfig("general", "adminemail", "") />
		<cfset var subject = application.fapi.getResource("coapi.mfa.emailcode@subject", "Your verification code") />
		<cfset var timeoutMin = int(application.fapi.getConfig("security", "mfaChallengeTimeout", 10)) />
		<cfset var body = "" />

		<cfsavecontent variable="body"><cfoutput><p>Your verification code is:</p>
<p style="font-size:22px; font-weight:bold; letter-spacing:3px;">#arguments.code#</p>
<p>Enter this code to finish signing in. It expires in #timeoutMin# minutes. If you did not try to sign in, you can ignore this email.</p></cfoutput></cfsavecontent>

		<cfmail to="#arguments.email#" from="#fromAddr#" subject="#subject#" type="html">#body#</cfmail>
	</cffunction>

	<!--- ============= Grace period (staged rollout): the deadline hook and its check ============= --->

	<cffunction name="getMFAGraceUntil" access="private" output="false" returntype="string" hint="HOOK: the enrolment grace deadline for this user as a date, or empty to enforce immediately. Default reads the mfaGraceUntil config; override to vary the deadline by organisation, cohort or a staged schedule (the userid lets an override resolve the user's group).">
		<cfargument name="userid" type="string" required="true" />
		<cfreturn application.fapi.getConfig("security", "mfaGraceUntil", "") />
	</cffunction>

	<cffunction name="inMFAGrace" access="private" output="false" returntype="boolean" hint="True when an enrolment grace deadline is set and still in the future for this user; before the deadline a mandatory-but-not-enrolled user may skip enrolment, on and after it enrolment is enforced.">
		<cfargument name="userid" type="string" required="true" />

		<cfset var graceUntil = getMFAGraceUntil(arguments.userid) />

		<cfreturn len(trim(graceUntil)) and isDate(graceUntil) and dateCompare(now(), graceUntil) lt 0 />
	</cffunction>

	<cffunction name="verifyPasskeyAssertion" access="private" output="false" returntype="struct" hint="Verifies a passkey get() response against a stored credential; feeds failures to the shared lockout like a bad code does">
		<cfargument name="userid" type="string" required="true" />
		<cfargument name="userKey" type="string" required="true" />

		<cfset var stResult = { verified = false, reason = "badPasskey", message = "", method = "passkey" } />
		<cfset var stContext = getEnrolContext() />
		<cfset var stPasskey = structnew() />
		<cfset var stVerify = structnew() />

		<cfif not structKeyExists(stContext, "passkeyChallenge")>
			<cfset stResult.reason = "noCandidate" />
			<cfset stResult.message = "Your sign in attempt has expired. Please try again." />
			<cfreturn stResult />
		</cfif>

		<!--- the WebAuthn blobs are opaque, read straight from the form post --->
		<cfset stPasskey = getFactorType().getPasskeyByCredentialId(userKey=arguments.userKey, userDirectory=this.key, credentialId=(structKeyExists(form, "credentialId") ? form.credentialId : "")) />

		<cfif structIsEmpty(stPasskey)>
			<cfset stResult.message = "That security key is not registered to your account." />
			<cfset stResult.bLocked = recordMFAFailure(userKey=arguments.userKey) />
			<cfreturn stResult />
		</cfif>

		<cfset stVerify = variables.oWebAuthn.verifyAssertion(
			clientDataJSON = (structKeyExists(form, "clientDataJSON") ? form.clientDataJSON : ""),
			authenticatorData = (structKeyExists(form, "authenticatorData") ? form.authenticatorData : ""),
			signature = (structKeyExists(form, "signature") ? form.signature : ""),
			expectedChallenge = stContext.passkeyChallenge,
			aExpectedOrigins = getExpectedOrigins(),
			rpId = getRpId(),
			stStoredKey = stPasskey.stPayload,
			storedSignCount = (structKeyExists(stPasskey.stPayload, "signCount") ? stPasskey.stPayload.signCount : 0),
			bRequireUserVerification = getPasskeyUVPolicy().bRequireUV
		) />

		<!--- one-shot: consume the challenge whatever the outcome, so a captured assertion cannot be replayed within the pending window; a fresh challenge is minted on the next render --->
		<cfset structDelete(stContext, "passkeyChallenge") />

		<cfif stVerify.verified>
			<cfset stPasskey.stPayload.signCount = stVerify.signCount />
			<cfset getFactorType().updateFactorPayload(objectid=stPasskey.objectid, stPayload=stPasskey.stPayload) />
			<cfset resetLoginFailures(arguments.userKey) />
			<cfset stResult.verified = true />
			<cfset stResult.reason = "" />
		<cfelse>
			<cfset stResult.reason = stVerify.reason />
			<cfset stResult.message = stVerify.message />
			<cfset stResult.bLocked = recordMFAFailure(userKey=arguments.userKey) />
		</cfif>

		<cfreturn stResult />
	</cffunction>

	<cffunction name="getRpId" access="private" output="false" returntype="string" hint="The WebAuthn relying party id (an effective domain). Config mfaRpId, else the request host. Passkeys are cryptographically bound to this - a credential registered under one rp id will not verify under another.">
		<cfset var rpId = trim(application.fapi.getConfig("security", "mfaRpId", "")) />
		<cfreturn len(rpId) ? rpId : cgi.server_name />
	</cffunction>

	<cffunction name="getRpName" access="private" output="false" returntype="string" hint="The relying party display name shown in the authenticator prompt. Config mfaRpName, else the site title.">
		<cfset var rpName = trim(application.fapi.getConfig("security", "mfaRpName", "")) />
		<cfreturn len(rpName) ? rpName : getIssuer() />
	</cffunction>

	<cffunction name="getExpectedOrigins" access="private" output="false" returntype="array" hint="Origins the browser-signed clientData.origin is checked against. Config mfaOrigin (comma list), else https://<host>. WebAuthn requires a secure context, so the scheme is always https - derived from the request host and never from the (possibly proxy-rewritten) backend scheme, so TLS termination does not break the check.">
		<cfset var lOrigins = trim(application.fapi.getConfig("security", "mfaOrigin", "")) />
		<cfset var aResult = arraynew(1) />
		<cfset var o = "" />

		<cfif len(lOrigins)>
			<cfloop list="#lOrigins#" index="o">
				<cfset arrayAppend(aResult, trim(o)) />
			</cfloop>
		<cfelse>
			<cfset arrayAppend(aResult, "https://" & cgi.server_name) />
		</cfif>

		<cfreturn aResult />
	</cffunction>

	<cffunction name="getPasskeyUVPolicy" access="private" output="false" returntype="struct" hint="User-verification policy for a passkey ceremony, bundling the client-side request (userVerification) and the server-side enforcement (bRequireUV) so the two cannot drift. bPrimaryFactor=true (passwordless - a passkey used instead of the password) ALWAYS requires user verification and ignores config: a passwordless passkey without UV is a single factor. The mfaPasskeyUserVerification config governs only the second-factor case.">
		<cfargument name="bPrimaryFactor" type="boolean" required="false" default="false" />

		<cfset var uv = "" />

		<!--- passwordless: UV is an invariant, not a setting - the config is deliberately not read here, so it cannot be left relaxed for primary-factor sign-in --->
		<cfif arguments.bPrimaryFactor>
			<cfreturn { userVerification = "required", bRequireUV = true } />
		</cfif>

		<!--- second factor: the password already supplies "something you know", so the admin chooses. Enforce server-side only when they require it - a client request alone cannot be trusted to have been honoured --->
		<cfset uv = lcase(trim(application.fapi.getConfig("security", "mfaPasskeyUserVerification", "preferred"))) />
		<cfif not listFindNoCase("discouraged,preferred,required", uv)>
			<cfset uv = "preferred" />
		</cfif>
		<cfreturn { userVerification = uv, bRequireUV = (uv eq "required") } />
	</cffunction>

	<cffunction name="getIssuer" access="private" output="false" returntype="string" hint="The otpauth issuer shown in the authenticator app: the site title, qualified with the environment label outside production so entries from different environments stay distinguishable">
		<cfset var issuer = application.fapi.getConfig("security", "mfaIssuer", "") />
		<cfset var oEnv = "" />
		<cfset var env = "" />

		<!--- explicit override wins --->
		<cfif len(issuer)>
			<cfreturn issuer />
		</cfif>

		<!--- default: the site title (not the project folder name) --->
		<cfset issuer = application.fapi.getConfig("general", "sitetitle", "") />
		<cfif not len(issuer)>
			<cfset issuer = application.applicationname />
		</cfif>

		<!--- append the environment label for non-production envs, e.g. the site title followed by "Development" or "Staging" --->
		<cfif structKeyExists(application, "stCOAPI") and structKeyExists(application.stCOAPI, "configEnvironment")>
			<cfset oEnv = application.fapi.getContentType("configEnvironment") />
			<cfset env = oEnv.getEnvironment() />
			<cfif not listFindNoCase("production,unknown", env) and len(oEnv.getLabel(env))>
				<cfset issuer = issuer & " " & oEnv.getLabel(env) />
			</cfif>
		</cfif>

		<cfreturn issuer />
	</cffunction>

	<cffunction name="getEnrolContext" access="private" output="false" returntype="struct" hint="Returns the session stash for an in-progress enrolment: the pending interstitial context when one exists, otherwise a self-service stash">
		<cfif structKeyExists(session, "fc") and structKeyExists(session.fc, "mfaPending")>
			<cfparam name="session.fc.mfaPending.context" default="#structnew()#" />
			<cfreturn session.fc.mfaPending.context />
		</cfif>

		<cfparam name="session.fc" default="#structnew()#" />
		<cfparam name="session.fc.stMFAEnrol" default="#structnew()#" />
		<cfreturn session.fc.stMFAEnrol />
	</cffunction>



	<!--- =============================
	  Account hooks

	  The seam a concrete credential directory implements. The engine above calls
	  these to reach the directory's own user store. getOutputHashName has a safe
	  platform default; the rest throw on the abstract base so a directory that
	  forgets one fails loudly rather than silently weakening a security control.
	============================== --->

	<cffunction name="getOutputHashName" access="public" output="false" returntype="string" hint="HOOK: hash name used to one-way-hash recovery codes. Defaults to the platform default; a credential directory may override to align recovery-code hashing with its password hashing.">
		<cfreturn application.security.cryptlib.getDefaultHashName() />
	</cffunction>

	<cffunction name="getUserEmail" access="private" output="false" returntype="string" hint="HOOK: the user's email address, for an emailed one-time code; empty string when none. Defaults to empty (email OTP then has nowhere to send and is unavailable for that user); a directory that enables the email OTP factor overrides this to resolve the address.">
		<cfargument name="userid" type="string" required="true" />
		<cfreturn "" />
	</cffunction>

	<cffunction name="getUserKey" access="private" output="false" returntype="string" hint="HOOK: resolve a login userid to this directory's stable user key; empty string when not found.">
		<cfargument name="userid" type="string" required="true" />
		<cfthrow type="MFAUserDirectory.notImplemented" message="MFAUserDirectory subclass must implement getUserKey()." detail="The concrete user directory must resolve a login userid to its own stable user key." />
	</cffunction>

	<cffunction name="getUserRoleIDs" access="private" output="false" returntype="string" hint="HOOK: the user's role objectids (comma list) for the MFA role policy.">
		<cfargument name="userid" type="string" required="true" />
		<cfthrow type="MFAUserDirectory.notImplemented" message="MFAUserDirectory subclass must implement getUserRoleIDs()." detail="The concrete user directory must resolve a login userid to its role objectids." />
	</cffunction>

	<cffunction name="recordMFAFailure" access="private" output="false" returntype="boolean" hint="HOOK: feed a failed second factor into the directory's login lockout; returns true when the account is now locked.">
		<cfargument name="userKey" type="string" required="true" />
		<cfthrow type="MFAUserDirectory.notImplemented" message="MFAUserDirectory subclass must implement recordMFAFailure()." detail="The concrete user directory must feed second factor failures into its account lockout." />
	</cffunction>

	<cffunction name="resetLoginFailures" access="private" output="false" returntype="void" hint="HOOK: clear the login-failure counter after a successful second factor.">
		<cfargument name="userKey" type="string" required="true" />
		<cfthrow type="MFAUserDirectory.notImplemented" message="MFAUserDirectory subclass must implement resetLoginFailures()." detail="The concrete user directory must clear its login-failure counter after a successful second factor." />
	</cffunction>

	<cffunction name="getUseridForKey" access="private" output="false" returntype="string" hint="HOOK: resolve a stable user key back to the login userid for event logging; empty string when not found.">
		<cfargument name="userKey" type="string" required="true" />
		<cfthrow type="MFAUserDirectory.notImplemented" message="MFAUserDirectory subclass must implement getUseridForKey()." detail="The concrete user directory must resolve a user key to its login userid for logging." />
	</cffunction>

</cfcomponent>
