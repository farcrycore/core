<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Security (multi-factor) --->
<!--- @@description: Self-service management of the current user's second factors: view status, set up a passkey or authenticator app, regenerate recovery codes, remove a passkey, turn off. CLIENTUD self-service surface (see docs/0014). --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif not application.security.isLoggedIn() or application.security.getCurrentUD() neq "CLIENTUD">
	<skin:view typename="farCOAPI" webskin="webtopBodyNotFound" />
	<cfexit method="exittemplate">
</cfif>

<cfset oUD = application.security.userdirectories["CLIENTUD"] />
<cfset userid = application.factory.oUtils.listSlice(session.security.userid, 1, -2, "_") />
<cfset setupFactor = structKeyExists(url, "setup") ? url.setup : "" /><!--- factor type the user chose to set up (totp / passkey) --->
<cfset bRemoveConfirm = structKeyExists(url, "removeconfirm") and url.removeconfirm eq "1" /><!--- two-step confirm before turning MFA off entirely (the one destructive action that warrants it) --->

<!--- second-factor methods a user can set up: passkey first (recommended), then authenticator app. The seam for email OTP etc. later - add a row here plus a setup branch below to offer a new method. --->
<cfset aFactorMethods = [
	{ type = "passkey", icon = "fa-key", name = "Passkey", description = "Use your device's fingerprint, face or screen lock, or a security key. The most phishing resistant option, and nothing to type at login." },
	{ type = "totp", icon = "fa-mobile", name = "Authenticator app", description = "Use an app such as Google Authenticator, 1Password or Authy to generate a 6 digit code at each login." }
] />

<!--- icon for each factor type shown in the status / admin tables --->
<cfset stFactorIcons = { totp = "fa-mobile", passkey = "fa-key", recoveryCodes = "fa-life-ring" } />


<!-----------------------------
ACTION
------------------------------>
<cfset stProperties = structnew() />

<!--- confirm authenticator (TOTP) enrolment --->
<ft:processform action="Confirm">
	<ft:processformObjects typename="farMFAEnrol" r_stProperties="stProperties">
		<cfset stConfirm = oUD.confirmTOTPEnrolment(userid=userid, code=trim(stProperties.code)) />
		<cfif stConfirm.bSuccess>
			<cfset request.fc.aMFARecoveryCodes = stConfirm.aRecoveryCodes />
			<skin:bubble title="Multi-factor authentication is now active" tags="security,info" />
		<cfelse>
			<cfset request.mfaError = stConfirm.message />
		</cfif>
	</ft:processformObjects>
</ft:processform>

<!--- confirm passkey enrolment (the create() ceremony runs client side and posts its result into the form) --->
<ft:processform action="mfaPasskey">
	<cfset stConfirm = oUD.confirmPasskeyEnrolment(
		userid = userid,
		clientDataJSON = structKeyExists(form, "clientDataJSON") ? form.clientDataJSON : "",
		attestationObject = structKeyExists(form, "attestationObject") ? form.attestationObject : "",
		transports = structKeyExists(form, "transports") ? form.transports : "",
		label = (structKeyExists(form, "passkeyLabel") and len(trim(form.passkeyLabel))) ? form.passkeyLabel : "Passkey"
	) />
	<cfif stConfirm.bSuccess>
		<cfset setupFactor = "" /><!--- leave the setup flow; fall through to the recovery-codes display (first factor) or status --->
		<cfif arrayLen(stConfirm.aRecoveryCodes)>
			<cfset request.fc.aMFARecoveryCodes = stConfirm.aRecoveryCodes />
		</cfif>
		<skin:bubble title="Passkey added" tags="security,info" />
	<cfelse>
		<cfset request.mfaError = stConfirm.message />
	</cfif>
</ft:processform>

<!--- regenerate recovery codes (one click; the resulting screen shows the new set and notes the old ones no longer work) --->
<ft:processform action="Regenerate recovery codes">
	<cfset stRegen = oUD.regenerateRecoveryCodes(userid=userid) />
	<cfif stRegen.bSuccess>
		<cfset request.fc.aMFARecoveryCodes = stRegen.aRecoveryCodes />
		<skin:bubble title="New recovery codes generated" tags="security,info" />
	</cfif>
</ft:processform>

<!--- remove a single passkey (self-service); the button carries the row objectid via selectedObjectID. Read the label first (only used if the ownership-checked removal succeeds) so the toast names which one went. --->
<ft:processform action="Remove passkey">
	<cfif structKeyExists(form, "selectedObjectID") and isValid("uuid", form.selectedObjectID)>
		<cfset stRemovePk = application.fapi.getContentType("farMFAFactor").getData(objectid=form.selectedObjectID) />
		<cfset removedLabel = (isStruct(stRemovePk) and structKeyExists(stRemovePk, "label")) ? stRemovePk.label : "" />
		<cfif oUD.removePasskey(userid=userid, objectid=form.selectedObjectID)>
			<cfset bubbleTitle = len(trim(removedLabel)) ? ("Passkey '" & removedLabel & "' removed") : "Passkey removed" />
			<skin:bubble title="#bubbleTitle#" tags="security,info" />
		</cfif>
	</cfif>
</ft:processform>

<!--- turn off every second factor (self-service); server-side check blocks it when MFA is mandatory (the hidden control is not the enforcement) --->
<ft:processform action="Remove multi-factor">
	<cfset stRemoveStatus = oUD.getMFAStatus(userid=userid) />
	<cfif stRemoveStatus.bMandatory>
		<cfset request.mfaError = "Multi-factor authentication is required for your account and cannot be turned off." />
	<cfelse>
		<cfset oUD.resetMFA(userKey=stRemoveStatus.userKey, by="self") />
		<skin:bubble title="Multi-factor authentication turned off" tags="security,info" />
	</cfif>
</ft:processform>

<cfset stStatus = oUD.getMFAStatus(userid=userid) />

<!-----------------------------
VIEW
------------------------------>
<admin:header>

<cfoutput><h1><i class="fa fa-lock"></i> <admin:resource key="security.mfa.manage.title">Multi-factor authentication</admin:resource></h1></cfoutput>

<cfif structKeyExists(request, "mfaError")>
	<cfoutput><div class="alert alert-error">#encodeForHTML(request.mfaError)#</div></cfoutput>
</cfif>

<cfif not stStatus.bEnabled>

	<cfoutput><div class="alert alert-info"><admin:resource key="security.mfa.manage.disabled">Multi-factor authentication is not enabled on this site.</admin:resource></div></cfoutput>

<cfelseif not stStatus.bKeyConfigured>

	<cfoutput><div class="alert alert-error"><admin:resource key="security.mfa.manage.nokey">Multi-factor authentication is not fully configured on this site (missing encryption key). Please contact your administrator.</admin:resource></div></cfoutput>

<cfelseif structKeyExists(request.fc, "aMFARecoveryCodes")>

	<!--- just enrolled or regenerated: show codes once --->
	<skin:view typename="farMFAFactor" template="displayRecoveryCodes" />
	<cfoutput><p><a class="btn btn-primary" href="#application.url.webtop#/?id=dashboard&typename=farUser&bodyView=editOwnMFA"><i class="fa fa-check"></i> <admin:resource key="security.mfa.buttons.recoveryack">I've saved my recovery codes</admin:resource></a></p></cfoutput>

<cfelseif setupFactor eq "passkey">

	<!--- passkey setup: first enrolment or an additional passkey. A passkey is public key material, so this needs no encryption key. --->
	<cfset stPkEnrol = oUD.startPasskeyEnrolment(userid=userid) />

	<cfif not stPkEnrol.bSuccess>
		<cfoutput><div class="alert alert-error">#encodeForHTML(stPkEnrol.message)#</div></cfoutput>
	<cfelse>
		<cfoutput>
			<cfif stStatus.bEnrolled>
				<p><admin:resource key="security.mfa.manage.passkeyaddhelp">Add another passkey - for example a security key, or another device you sign in from.</admin:resource></p>
			<cfelse>
				<p><admin:resource key="security.mfa.manage.passkeyhelp">Set up a passkey to sign in with your device's fingerprint, face or screen lock, or a security key.</admin:resource></p>
			</cfif>
		</cfoutput>

		<ft:form>
			<cfset request.fc.stPasskeyEnrol = { stOptions = stPkEnrol.stOptions, bAllowLabel = true } />
			<skin:view typename="farMFAFactor" template="displayEnrolPasskey" />
			<cfoutput>
				<p><a href="#application.url.webtop#/?id=dashboard&typename=farUser&bodyView=editOwnMFA" class="btn"><admin:resource key="security.mfa.manage.cancelsetup">Cancel</admin:resource></a></p>
			</cfoutput>
		</ft:form>
	</cfif>

<cfelseif setupFactor eq "totp">

	<!--- authenticator (TOTP) setup: first enrolment or replacement. confirmTOTPEnrolment is idempotent - an existing factor keeps working until the new code is confirmed, then it is replaced and fresh recovery codes are issued --->
	<cfset stEnrol = oUD.startTOTPEnrolment(userid=userid) />

	<cfif not stEnrol.bSuccess>
		<cfoutput><div class="alert alert-error">#encodeForHTML(stEnrol.message)#</div></cfoutput>
	<cfelse>
		<cfoutput>
			<cfif stStatus.bEnrolled>
				<p><admin:resource key="security.mfa.manage.replacehelp">Set up a new authenticator app to replace your current one. Your existing authenticator keeps working until you confirm the new one, and a fresh set of recovery codes is issued.</admin:resource></p>
			<cfelse>
				<p><admin:resource key="security.mfa.manage.setuphelp">Scan the QR code with an authenticator app, then enter the 6 digit code it shows to finish.</admin:resource></p>
			</cfif>
		</cfoutput>

		<ft:form bFocusFirstField="true">
			<cfset request.fc.stMFAEnrol = stEnrol />
			<skin:view typename="farMFAFactor" template="displayEnrolTOTP" />

			<cfset stMetadata = structnew() />
			<cfset stMetadata.code.ftLabel = "Confirmation code" />
			<ft:object typename="farMFAEnrol" lfields="code" stPropMetadata="#stMetadata#" IncludeFieldSet="true" />

			<cfoutput>
				<div class="pull-right">
					<ft:button class="btn-primary" icon="fa-check" value="Confirm" text="Confirm and activate" />
					<a href="#application.url.webtop#/?id=dashboard&typename=farUser&bodyView=editOwnMFA" class="btn"><admin:resource key="security.mfa.manage.cancelsetup">Cancel</admin:resource></a>
				</div>
			</cfoutput>
		</ft:form>
	</cfif>

<cfelseif stStatus.bEnrolled and bRemoveConfirm>

	<cfoutput>
		<div class="alert alert-warning"><admin:resource key="security.mfa.manage.removeconfirmwarn"><strong>Turn off multi-factor authentication?</strong> This removes your passkeys, your authenticator app and your recovery codes. You will sign in with just your password until you set it up again.</admin:resource></div>
	</cfoutput>

	<ft:form>
		<cfoutput>
			<div class="pull-right">
				<ft:button class="btn-danger" icon="fa-power-off" value="Remove multi-factor" text="Turn off multi-factor authentication" validate="false" />
				<a href="#application.url.webtop#/?id=dashboard&typename=farUser&bodyView=editOwnMFA" class="btn"><admin:resource key="security.mfa.manage.cancelremove">Cancel</admin:resource></a>
			</div>
		</cfoutput>
	</ft:form>

<cfelseif stStatus.bEnrolled>

	<cfset oFactor = application.fapi.getContentType("farMFAFactor") />
	<cfset qFactors = oFactor.getFactors(userKey=stStatus.userKey, userDirectory="CLIENTUD", status="active") />
	<cfset recoveryRemaining = oFactor.getRecoveryCodesRemaining(userKey=stStatus.userKey, userDirectory="CLIENTUD") />
	<cfset bHasTOTP = false />

	<cfoutput><div class="alert alert-success"><admin:resource key="security.mfa.manage.active">Multi-factor authentication is active on your account.</admin:resource></div></cfoutput>

	<!--- one row per factor, each owning its action. Actions are all buttons (class="btn"): safe navigations are links, state-changing actions (Regenerate, Remove passkey) are form buttons so they never mutate on a GET. Table markup is wrapped in cfoutput because enablecfoutputonly is on. --->
	<ft:form>
		<cfoutput>
			<table class="table table-striped">
				<thead>
					<tr>
						<th><admin:resource key="security.mfa.manage.col.factor">Factor</admin:resource></th>
						<th><admin:resource key="security.mfa.manage.col.enrolled">Enrolled</admin:resource></th>
						<th><admin:resource key="security.mfa.manage.col.lastused">Last used</admin:resource></th>
						<th></th>
					</tr>
				</thead>
				<tbody>
		</cfoutput>
		<cfloop query="qFactors">
			<cfif qFactors.factorType eq "totp"><cfset bHasTOTP = true /></cfif>
			<cfoutput>
					<tr>
						<td><i class="fa #structKeyExists(stFactorIcons, qFactors.factorType) ? stFactorIcons[qFactors.factorType] : 'fa-lock'#"></i> #encodeForHTML(len(qFactors.label) ? qFactors.label : qFactors.factorType)#<cfif qFactors.factorType eq "recoveryCodes"> (#recoveryRemaining# <admin:resource key="security.mfa.manage.remaining">remaining</admin:resource>)</cfif></td>
						<td>#dateformat(qFactors.datetimecreated, "d mmm yyyy")#</td>
						<td><cfif isDate(qFactors.lastUsed)>#dateformat(qFactors.lastUsed, "d mmm yyyy")#, #timeformat(qFactors.lastUsed, "h:mm tt")#<cfelse><admin:resource key="security.mfa.manage.never">never</admin:resource></cfif></td>
						<td>
							<cfif qFactors.factorType eq "totp">
								<a class="btn" href="#application.url.webtop#/?id=dashboard&typename=farUser&bodyView=editOwnMFA&setup=totp"><i class="fa fa-refresh"></i> <admin:resource key="security.mfa.manage.replace">Set up a new one</admin:resource></a>
							<cfelseif qFactors.factorType eq "passkey">
								<ft:button value="Remove passkey" text="Remove" icon="fa-trash-o" selectedObjectID="#qFactors.objectid#" validate="false" />
							<cfelseif qFactors.factorType eq "recoveryCodes">
								<ft:button value="Regenerate recovery codes" text="Regenerate" icon="fa-refresh" validate="false" />
							</cfif>
						</td>
					</tr>
			</cfoutput>
		</cfloop>
		<cfoutput>
				</tbody>
			</table>

			<p>
				<a class="btn btn-primary" href="#application.url.webtop#/?id=dashboard&typename=farUser&bodyView=editOwnMFA&setup=passkey"><i class="fa fa-plus"></i> <admin:resource key="security.mfa.manage.addpasskey">Add a passkey</admin:resource></a>
				<cfif not bHasTOTP>
					<a class="btn" href="#application.url.webtop#/?id=dashboard&typename=farUser&bodyView=editOwnMFA&setup=totp"><i class="fa fa-mobile"></i> <admin:resource key="security.mfa.manage.addtotp">Set up an authenticator app</admin:resource></a>
				</cfif>
			</p>

			<cfif not stStatus.bMandatory>
				<hr />
				<div class="pull-right">
					<a class="btn btn-danger" href="#application.url.webtop#/?id=dashboard&typename=farUser&bodyView=editOwnMFA&removeconfirm=1"><i class="fa fa-power-off"></i> <admin:resource key="security.mfa.manage.remove">Turn off multi-factor authentication</admin:resource></a>
				</div>
				<div class="clearfix"></div>
			</cfif>
		</cfoutput>
	</ft:form>

<cfelse>

	<!--- not enrolled: offer the available second-factor methods (framing depends on whether policy requires it). passkey and authenticator app today; new methods become extra rows in aFactorMethods plus their own setup branch above --->
	<cfoutput>
		<cfif stStatus.bMandatory>
			<div class="alert alert-warning"><admin:resource key="security.mfa.manage.offerrequired"><strong>Your account requires multi-factor authentication.</strong> Add a second step to your login by setting up one of the methods below.</admin:resource></div>
		<cfelse>
			<div class="alert alert-info"><admin:resource key="security.mfa.manage.offeroptional"><strong>Multi-factor authentication is optional for your account.</strong> It adds a second step at login to help protect your account. Set up a method below, or leave it for now; you can come back any time.</admin:resource></div>
		</cfif>

		<table class="table">
			<tbody>
				<cfloop array="#aFactorMethods#" index="stMethod">
					<tr>
						<td><i class="fa #encodeForHTMLAttribute(stMethod.icon)#"></i> <strong>#encodeForHTML(stMethod.name)#</strong><br />#encodeForHTML(stMethod.description)#</td>
						<td><a href="#application.url.webtop#/?id=dashboard&typename=farUser&bodyView=editOwnMFA&setup=#encodeForHTMLAttribute(stMethod.type)#" class="btn btn-primary"><admin:resource key="security.mfa.manage.setup">Set up</admin:resource></a></td>
					</tr>
				</cfloop>
			</tbody>
		</table>
	</cfoutput>

</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="false" />
