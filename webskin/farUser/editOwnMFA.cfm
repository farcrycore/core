<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Security (multi-factor) --->
<!--- @@description: Self-service management of the current user's second factor: enrol, view status, regenerate recovery codes, remove. CLIENTUD self-service surface (see docs/0014). --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif not application.security.isLoggedIn() or application.security.getCurrentUD() neq "CLIENTUD">
	<skin:view typename="farCOAPI" webskin="webtopBodyNotFound" />
	<cfexit method="exittemplate">
</cfif>

<cfset oUD = application.security.userdirectories["CLIENTUD"] />
<cfset userid = application.factory.oUtils.listSlice(session.security.userid, 1, -2, "_") />

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

<!--- regenerate recovery codes --->
<ft:processform action="Regenerate recovery codes">
	<cfset stRegen = oUD.regenerateRecoveryCodes(userid=userid) />
	<cfif stRegen.bSuccess>
		<cfset request.fc.aMFARecoveryCodes = stRegen.aRecoveryCodes />
		<skin:bubble title="New recovery codes generated" tags="security,info" />
	</cfif>
</ft:processform>

<!--- remove second factor (self-service); server-side check blocks removal when MFA is required (the hidden button is not the enforcement) --->
<ft:processform action="Remove multi-factor">
	<cfset stRemoveStatus = oUD.getMFAStatus(userid=userid) />
	<cfif stRemoveStatus.bRequired>
		<cfset request.mfaError = "Multi-factor authentication is required for your account and cannot be removed." />
	<cfelse>
		<cfset oUD.resetMFA(userKey=stRemoveStatus.userKey, by="self") />
		<skin:bubble title="Multi-factor authentication removed" tags="security,info" />
	</cfif>
</ft:processform>

<cfset stStatus = oUD.getMFAStatus(userid=userid) />

<!-----------------------------
VIEW
------------------------------>
<admin:header>

<cfoutput><h1><admin:resource key="security.mfa.manage.title">Multi-factor authentication</admin:resource></h1></cfoutput>

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
	<cfoutput><p><a class="btn" href="#application.url.webtop#/?id=dashboard&typename=farUser&bodyView=editOwnMFA"><admin:resource key="security.mfa.manage.done">Done</admin:resource></a></p></cfoutput>

<cfelseif stStatus.bEnrolled>

	<cfoutput>
		<div class="alert alert-success"><admin:resource key="security.mfa.manage.active">Multi-factor authentication is active on your account.</admin:resource></div>
	</cfoutput>

	<ft:form>
		<cfoutput>
			<ft:buttonPanel>
				<ft:button value="Regenerate recovery codes" text="Regenerate recovery codes" validate="false" />
				<cfif not stStatus.bRequired>
					<ft:button value="Remove multi-factor" text="Remove multi-factor" color="red" validate="false" />
				</cfif>
			</ft:buttonPanel>
		</cfoutput>
	</ft:form>

<cfelse>

	<!--- not enrolled: offer setup --->
	<cfset stEnrol = oUD.startTOTPEnrolment(userid=userid) />

	<cfif not stEnrol.bSuccess>
		<cfoutput><div class="alert alert-error">#encodeForHTML(stEnrol.message)#</div></cfoutput>
	<cfelse>
		<cfoutput>
			<p><admin:resource key="security.mfa.manage.setuphelp">Protect your account with an authenticator app. Scan the QR code, then enter the 6 digit code to confirm.</admin:resource></p>
		</cfoutput>

		<ft:form>
			<cfset request.fc.stMFAEnrol = stEnrol />
			<skin:view typename="farMFAFactor" template="displayEnrolTOTP" />

			<cfset stMetadata = structnew() />
			<cfset stMetadata.code.ftLabel = "Confirmation code" />
			<ft:object typename="farMFAEnrol" lfields="code" stPropMetadata="#stMetadata#" IncludeFieldSet="true" />

			<ft:buttonPanel>
				<ft:button value="Confirm" text="Confirm and activate" color="orange" />
			</ft:buttonPanel>
		</ft:form>
	</cfif>

</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="false" />
