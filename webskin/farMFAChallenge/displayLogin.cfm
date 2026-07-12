<cfsetting enablecfoutputonly="true">
<!--- @@displayname: MFA challenge --->
<!--- @@description: Second factor challenge rendered by the login flow while a login is pending verification. Offers a passkey (when the user has one) alongside the authenticator / recovery code field. See docs/0014. --->

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<skin:view typename="farLogin" template="displayHeaderLogin" />

<!--- offer a passkey only when the pending user has one (this also mints a fresh assertion challenge); label the code field for what they actually have --->
<cfset stPasskey = { bSuccess = false } />
<cfset bHasTOTP = false />
<cfif structKeyExists(session, "fc") and structKeyExists(session.fc, "mfaPending")>
	<cfset stPasskey = application.security.userdirectories[session.fc.mfaPending.ud].getPasskeyAssertionOptions(userid=session.fc.mfaPending.userid) />
	<cfset bHasTOTP = application.security.userdirectories[session.fc.mfaPending.ud].hasTOTPFactor(userid=session.fc.mfaPending.userid) />
</cfif>

<ft:form bAddFormCSS="false" class="clearfix" bFocusFirstField="true" action="#application.fapi.fixURL(removeValues='mfacancel')#">

	<cfif isdefined("stParam.message") and len(stParam.message)>
		<cfoutput><div class="alert alert-warning"><admin:resource key="security.message.#rereplace(stParam.message,'[^\w]','','ALL')#">#encodeForHTML(stParam.message)#</admin:resource></div></cfoutput>
	</cfif>

	<cfoutput><p><strong><admin:resource key="security.mfa.challenge.title">Multi-factor verification</admin:resource></strong></p></cfoutput>

	<cfif stPasskey.bSuccess>
		<cfoutput><p><admin:resource key="security.mfa.challenge.confirm">Confirm it's you to finish signing in.</admin:resource></p></cfoutput>
		<cfset request.fc.stPasskeyChallenge = { stOptions = stPasskey.stOptions, submitId = "mfaVerifyBtn" } />
		<skin:view typename="farMFAFactor" template="displayChallengePasskey" />
		<cfoutput><p class="help-block text-center"><admin:resource key="security.mfa.challenge.passkeyhint">Use your device's fingerprint, face or screen lock, or a security key.</admin:resource></p><p class="mfa-divider"><cfif bHasTOTP><admin:resource key="security.mfa.challenge.or">or use a code</admin:resource><cfelse><admin:resource key="security.mfa.challenge.oralt">or</admin:resource></cfif></p></cfoutput>
	<cfelseif bHasTOTP>
		<cfoutput><p><admin:resource key="security.mfa.challenge.entercode">Enter the code from your authenticator app to finish signing in.</admin:resource></p></cfoutput>
	<cfelse>
		<cfoutput><p><admin:resource key="security.mfa.challenge.enterrecovery">Enter one of your recovery codes to finish signing in.</admin:resource></p></cfoutput>
	</cfif>

	<ft:object typename="farMFAChallenge" lFields="code" prefix="mfa" legend="" focusField="code" r_stFields="stFields" />

	<cfoutput>
		<fieldset>
			<label for="#stFields.code.formfieldname#"><cfif bHasTOTP><admin:resource key="security.mfa.challenge.authcode">Authenticator code</admin:resource><cfelse><admin:resource key="security.mfa.challenge.recoverycode">Recovery code</admin:resource></cfif></label>
			#stFields.code.html#
			<cfif bHasTOTP><p class="help-block"><admin:resource key="security.mfa.challenge.recoveryhint">Lost your device? One of your recovery codes works here too.</admin:resource></p></cfif>
		</fieldset>

		<div class="pull-right">
			<ft:button rendertype="button" id="mfaVerifyBtn" class="btn#stPasskey.bSuccess ? '' : ' btn-primary'#" rbkey="security.mfa.buttons.verify" value="Verify" />
		</div>
		<div class="clearfix"></div>

		<hr />
		<p class="text-center"><a href="#application.url.webtoplogin#?mfacancel=1"><admin:resource key="security.mfa.challenge.cancel">Sign in as a different user</admin:resource></a></p>
	</cfoutput>

</ft:form>

<skin:view typename="farLogin" template="displayFooterLogin" />

<cfsetting enablecfoutputonly="false">
