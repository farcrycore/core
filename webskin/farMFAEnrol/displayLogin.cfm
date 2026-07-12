<cfsetting enablecfoutputonly="true">
<!--- @@displayname: MFA enrolment --->
<!--- @@description: Interstitial enrolment wizard rendered by the login flow when policy requires a second factor the user has not yet set up. Offers a passkey and / or an authenticator app. See docs/0014. --->

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<skin:view typename="farLogin" template="displayHeaderLogin" />

<cfif not (structKeyExists(session, "fc") and structKeyExists(session.fc, "mfaPending"))>

	<cfoutput>
		<div class="alert alert-warning"><admin:resource key="security.mfa.enrol.expired">Your login expired. Please log in again.</admin:resource></div>
		<p><a href="#application.url.webtoplogin#"><admin:resource key="security.mfa.enrol.backtologin">Back to login</admin:resource></a></p>
	</cfoutput>

<cfelseif isdefined("stParam.bShowRecovery") and stParam.bShowRecovery and isdefined("stParam.aRecoveryCodes")>

	<!--- step 2: the factor is active; show the recovery codes once, then complete the login --->
	<cfset request.fc.aMFARecoveryCodes = stParam.aRecoveryCodes />

	<cfoutput>
		<p><strong><admin:resource key="security.mfa.enrol.recoverytitle">Save your recovery codes</admin:resource></strong></p>
		<p><admin:resource key="security.mfa.enrol.recoveryhelp">Your second factor is now active. If you lose access to it, a recovery code is the only way back into your account.</admin:resource></p>
	</cfoutput>

	<skin:view typename="farMFAFactor" template="displayRecoveryCodes" />

	<ft:form bAddFormCSS="false" class="clearfix" action="#application.fapi.fixURL(removeValues='mfacancel')#">
		<cfoutput>
			<div class="pull-right">
				<ft:button rendertype="button" class="btn btn-primary btn-large" rbkey="security.mfa.buttons.recoveryack" value="mfaRecoveryAck" text="I've saved my recovery codes" />
			</div>
		</cfoutput>
	</ft:form>

<cfelse>

	<!--- step 1: provision a factor and prove it. A passkey needs no encryption key; the authenticator app path needs one, so it is offered only when that is configured. --->
	<cfset oUD = application.security.userdirectories[session.fc.mfaPending.ud] />
	<cfset stTOTP = oUD.startTOTPEnrolment(userid=session.fc.mfaPending.userid) />
	<cfset stPasskey = oUD.startPasskeyEnrolment(userid=session.fc.mfaPending.userid) />

	<cfif not stTOTP.bSuccess and not stPasskey.bSuccess>

		<cfoutput>
			<div class="alert alert-error">#encodeForHTML(stTOTP.message)#</div>
			<p class="help-inline">
				<a href="#application.url.webtoplogin#?mfacancel=1"><admin:resource key="security.mfa.challenge.cancel">Sign in as a different user</admin:resource></a>
			</p>
		</cfoutput>

	<cfelse>

		<ft:form bAddFormCSS="false" class="clearfix" bFocusFirstField="true" action="#application.fapi.fixURL(removeValues='mfacancel')#">

			<cfif isdefined("stParam.message") and len(stParam.message)>
				<cfoutput><div class="alert alert-warning"><admin:resource key="security.message.#rereplace(stParam.message,'[^\w]','','ALL')#">#encodeForHTML(stParam.message)#</admin:resource></div></cfoutput>
			</cfif>

			<cfoutput>
				<p><strong><admin:resource key="security.mfa.enrol.title">Set up multi-factor authentication</admin:resource></strong></p>
				<p><admin:resource key="security.mfa.enrol.choose">This site requires a second factor for your account. Set up one of the methods below to finish signing in.</admin:resource></p>
			</cfoutput>

			<cfif stPasskey.bSuccess>
				<cfoutput>
					<p><strong><admin:resource key="security.mfa.passkey.heading">Passkey</admin:resource></strong> <span class="help-inline"><admin:resource key="security.mfa.passkey.recommended">recommended - use your device fingerprint or face, or a security key</admin:resource></span></p>
				</cfoutput>
				<cfset request.fc.stPasskeyEnrol = { stOptions = stPasskey.stOptions } />
				<skin:view typename="farMFAFactor" template="displayEnrolPasskey" />
			</cfif>

			<cfif stTOTP.bSuccess>
				<cfif stPasskey.bSuccess>
					<cfoutput><p class="mfa-or"><admin:resource key="security.mfa.enrol.oralt">or use an authenticator app</admin:resource></p></cfoutput>
				</cfif>

				<cfoutput>
					<p><admin:resource key="security.mfa.enrol.help">Scan the QR code with an authenticator app (such as Google Authenticator, 1Password or Authy), then enter the 6 digit code it shows.</admin:resource></p>
				</cfoutput>

				<cfset request.fc.stMFAEnrol = stTOTP />
				<skin:view typename="farMFAFactor" template="displayEnrolTOTP" />

				<ft:object typename="farMFAEnrol" lFields="code" prefix="mfa" legend="" focusField="code" r_stFields="stFields" />

				<cfoutput>
					<fieldset>
						<label for="#stFields.code.formfieldname#">#stFields.code.ftLabel#</label>
						#stFields.code.html#
					</fieldset>

					<div class="pull-right">
						<ft:button rendertype="button" id="mfaActivateBtn" class="btn btn-primary btn-large" rbkey="security.mfa.buttons.activate" value="Activate" />
					</div>
				</cfoutput>
			</cfif>

			<cfoutput>
				<div class="clearfix"></div>
				<hr />
				<p><a href="#application.url.webtoplogin#?mfacancel=1"><admin:resource key="security.mfa.challenge.cancel">Sign in as a different user</admin:resource></a></p>
			</cfoutput>

		</ft:form>

	</cfif>

</cfif>

<skin:view typename="farLogin" template="displayFooterLogin" />

<cfsetting enablecfoutputonly="false">
