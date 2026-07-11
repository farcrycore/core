<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Security (multi-factor) --->
<!--- @@description: Self-service management of the current user's second factor: view status, set up a method, regenerate recovery codes, turn off. CLIENTUD self-service surface (see docs/0014). --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif not application.security.isLoggedIn() or application.security.getCurrentUD() neq "CLIENTUD">
	<skin:view typename="farCOAPI" webskin="webtopBodyNotFound" />
	<cfexit method="exittemplate">
</cfif>

<cfset oUD = application.security.userdirectories["CLIENTUD"] />
<cfset userid = application.factory.oUtils.listSlice(session.security.userid, 1, -2, "_") />
<cfset setupFactor = structKeyExists(url, "setup") ? url.setup : "" /><!--- factor type the user chose to set up (currently only "totp"); drives the setup flow for both first enrolment and replacement, since confirmTOTPEnrolment is idempotent --->
<cfset bRemoveConfirm = structKeyExists(url, "removeconfirm") and url.removeconfirm eq "1" /><!--- two-step confirm before turning MFA off (the only destructive action that warrants one) --->

<!--- second-factor methods a user can set up: one today, the seam for passkey / email OTP in later phases (see docs/0014). Add a row here plus a setup branch below to offer a new method. --->
<cfset aFactorMethods = [
	{ type = "totp", name = "Authenticator app", description = "Use an app such as Google Authenticator, 1Password or Authy to generate a 6 digit code at each login." }
] />


<!-----------------------------
ACTION
------------------------------>
<cfset stProperties = structnew() />

<!--- confirm enrolment --->
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

<!--- regenerate recovery codes (one click; the resulting screen shows the new set and notes the old ones no longer work) --->
<ft:processform action="Regenerate recovery codes">
	<cfset stRegen = oUD.regenerateRecoveryCodes(userid=userid) />
	<cfif stRegen.bSuccess>
		<cfset request.fc.aMFARecoveryCodes = stRegen.aRecoveryCodes />
		<skin:bubble title="New recovery codes generated" tags="security,info" />
	</cfif>
</ft:processform>

<!--- turn off the second factor (self-service); server-side check blocks it when MFA is mandatory for the user (the hidden control is not the enforcement) --->
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
	<cfoutput><p><a class="btn btn-primary" href="#application.url.webtop#/?id=dashboard&typename=farUser&bodyView=editOwnMFA"><admin:resource key="security.mfa.buttons.recoveryack">I've saved my recovery codes</admin:resource></a></p></cfoutput>

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

		<ft:form>
			<cfset request.fc.stMFAEnrol = stEnrol />
			<skin:view typename="farMFAFactor" template="displayEnrolTOTP" />

			<cfset stMetadata = structnew() />
			<cfset stMetadata.code.ftLabel = "Confirmation code" />
			<ft:object typename="farMFAEnrol" lfields="code" stPropMetadata="#stMetadata#" IncludeFieldSet="true" />

			<cfoutput>
				<div class="pull-right">
					<ft:button rendertype="button" value="Confirm" text="Confirm and activate" color="orange" />
					<a href="#application.url.webtop#/?id=dashboard&typename=farUser&bodyView=editOwnMFA" class="btn"><admin:resource key="security.mfa.manage.cancelsetup">Cancel</admin:resource></a>
				</div>
			</cfoutput>
		</ft:form>
	</cfif>

<cfelseif stStatus.bEnrolled and bRemoveConfirm>

	<cfoutput>
		<div class="alert alert-warning"><admin:resource key="security.mfa.manage.removeconfirmwarn"><strong>Turn off multi-factor authentication?</strong> This removes your authenticator app and your recovery codes. You will sign in with just your password until you set it up again.</admin:resource></div>
	</cfoutput>

	<ft:form>
		<cfoutput>
			<div class="pull-right">
				<ft:button rendertype="button" value="Remove multi-factor" text="Turn off multi-factor authentication" color="red" validate="false" />
				<a href="#application.url.webtop#/?id=dashboard&typename=farUser&bodyView=editOwnMFA" class="btn"><admin:resource key="security.mfa.manage.cancelremove">Cancel</admin:resource></a>
			</div>
		</cfoutput>
	</ft:form>

<cfelseif stStatus.bEnrolled>

	<cfset oFactor = application.fapi.getContentType("farMFAFactor") />
	<cfset qFactors = oFactor.getFactors(userKey=stStatus.userKey, userDirectory="CLIENTUD", status="active") />
	<cfset recoveryRemaining = oFactor.getRecoveryCodesRemaining(userKey=stStatus.userKey, userDirectory="CLIENTUD") />

	<cfoutput><div class="alert alert-success"><admin:resource key="security.mfa.manage.active">Multi-factor authentication is active on your account.</admin:resource></div></cfoutput>

	<!--- one row per factor, each owning its action. Every action is styled as a button (class="btn"): the safe navigations are links, the one state-changing action (Regenerate) is a form button so it never mutates on a GET - they render identically. --->
	<ft:form>
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
				<cfloop query="qFactors">
					<cfoutput>
					<tr>
						<td>#encodeForHTML(len(qFactors.label) ? qFactors.label : qFactors.factorType)#<cfif qFactors.factorType eq "recoveryCodes"> (#recoveryRemaining# <admin:resource key="security.mfa.manage.remaining">remaining</admin:resource>)</cfif></td>
						<td>#dateformat(qFactors.datetimecreated, "d mmm yyyy")#</td>
						<td><cfif isDate(qFactors.lastUsed)>#dateformat(qFactors.lastUsed, "d mmm yyyy")#, #timeformat(qFactors.lastUsed, "h:mm tt")#<cfelse><admin:resource key="security.mfa.manage.never">never</admin:resource></cfif></td>
						<td>
							<cfif qFactors.factorType eq "totp">
								<a class="btn" href="#application.url.webtop#/?id=dashboard&typename=farUser&bodyView=editOwnMFA&setup=totp"><admin:resource key="security.mfa.manage.replace">Set up a new one</admin:resource></a>
							<cfelseif qFactors.factorType eq "recoveryCodes">
								<ft:button rendertype="button" class="btn" value="Regenerate recovery codes" text="Regenerate" validate="false" />
							</cfif>
						</td>
					</tr>
					</cfoutput>
				</cfloop>
			</tbody>
		</table>

		<cfif not stStatus.bMandatory>
			<cfoutput><p><a class="btn btn-danger" href="#application.url.webtop#/?id=dashboard&typename=farUser&bodyView=editOwnMFA&removeconfirm=1"><admin:resource key="security.mfa.manage.remove">Turn off multi-factor authentication</admin:resource></a></p></cfoutput>
		</cfif>
	</ft:form>

<cfelse>

	<!--- not enrolled: offer the available second-factor methods (framing depends on whether policy requires it). one method today; passkey / email OTP become extra rows in aFactorMethods plus their own setup branch above --->
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
						<td><strong>#encodeForHTML(stMethod.name)#</strong><br />#encodeForHTML(stMethod.description)#</td>
						<td><a href="#application.url.webtop#/?id=dashboard&typename=farUser&bodyView=editOwnMFA&setup=#encodeForHTMLAttribute(stMethod.type)#" class="btn btn-primary"><admin:resource key="security.mfa.manage.setup">Set up</admin:resource></a></td>
					</tr>
				</cfloop>
			</tbody>
		</table>
	</cfoutput>

</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="false" />
