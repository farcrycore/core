<cfsetting enablecfoutputonly="true">
<!--- @@displayname: MFA enrolment --->
<!--- @@description: Interstitial enrolment wizard rendered by the login flow when policy requires a second factor the user has not yet set up (see docs/0014) --->

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
		<p><admin:resource key="security.mfa.enrol.recoveryhelp">Your authenticator app is now active. If you lose access to it, a recovery code is the only way back into your account.</admin:resource></p>
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

	<!--- step 1: provision the authenticator app and prove one valid code --->
	<cfset oUD = application.security.userdirectories[session.fc.mfaPending.ud] />
	<cfset stEnrol = oUD.startTOTPEnrolment(userid=session.fc.mfaPending.userid) />

	<cfif not stEnrol.bSuccess>

		<cfoutput>
			<div class="alert alert-error">#encodeForHTML(stEnrol.message)#</div>
			<p class="help-inline">
				<a href="#application.url.webtoplogin#?mfacancel=1"><admin:resource key="security.mfa.challenge.cancel">Sign in as a different user</admin:resource></a>
			</p>
		</cfoutput>

	<cfelse>

		<ft:form bAddFormCSS="false" class="clearfix" action="#application.fapi.fixURL(removeValues='mfacancel')#">

			<cfif isdefined("stParam.message") and len(stParam.message)>
				<cfoutput><div class="alert alert-warning"><admin:resource key="security.message.#rereplace(stParam.message,'[^\w]','','ALL')#">#encodeForHTML(stParam.message)#</admin:resource></div></cfoutput>
			</cfif>

			<cfoutput>
				<p><strong><admin:resource key="security.mfa.enrol.title">Set up multi-factor authentication</admin:resource></strong></p>
				<p><admin:resource key="security.mfa.enrol.help">This site requires a second factor for your account. Scan the QR code with an authenticator app (such as Google Authenticator, 1Password or Authy), then enter the 6 digit code it shows to finish.</admin:resource></p>
			</cfoutput>

			<cfset request.fc.stMFAEnrol = stEnrol />
			<skin:view typename="farMFAFactor" template="displayEnrolTOTP" />

			<ft:object typename="farMFAEnrol" lFields="code" prefix="mfa" legend="" focusField="code" r_stFields="stFields" />

			<cfoutput>
				<fieldset>
					<label for="#stFields.code.formfieldname#">#stFields.code.ftLabel#</label>
					#stFields.code.html#
				</fieldset>

				<div class="pull-right">
					<ft:button rendertype="button" class="btn btn-primary btn-large" rbkey="security.mfa.buttons.activate" value="Activate" />
				</div>

				<p class="help-inline">
					<a href="#application.url.webtoplogin#?mfacancel=1"><admin:resource key="security.mfa.challenge.cancel">Sign in as a different user</admin:resource></a>
				</p>
			</cfoutput>

		</ft:form>

	</cfif>

</cfif>

<skin:view typename="farLogin" template="displayFooterLogin" />

<cfsetting enablecfoutputonly="false">
