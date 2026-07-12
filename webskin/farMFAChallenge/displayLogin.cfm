<cfsetting enablecfoutputonly="true">
<!--- @@displayname: MFA challenge --->
<!--- @@description: Second factor challenge rendered by the login flow while a login is pending verification. Offers a passkey (when the user has one) alongside the authenticator / recovery code field. See docs/0014. --->

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<skin:view typename="farLogin" template="displayHeaderLogin" />

<!--- offer a passkey only when the pending user has one; this also mints a fresh assertion challenge for verify --->
<cfset stPasskey = { bSuccess = false } />
<cfif structKeyExists(session, "fc") and structKeyExists(session.fc, "mfaPending")>
	<cfset stPasskey = application.security.userdirectories[session.fc.mfaPending.ud].getPasskeyAssertionOptions(userid=session.fc.mfaPending.userid) />
</cfif>

<ft:form bAddFormCSS="false" class="clearfix" bFocusFirstField="true" action="#application.fapi.fixURL(removeValues='mfacancel')#">

	<cfif isdefined("stParam.message") and len(stParam.message)>
		<cfoutput><div class="alert alert-warning"><admin:resource key="security.message.#rereplace(stParam.message,'[^\w]','','ALL')#">#encodeForHTML(stParam.message)#</admin:resource></div></cfoutput>
	</cfif>

	<cfoutput><p><strong><admin:resource key="security.mfa.challenge.title">Multi-factor verification</admin:resource></strong></p></cfoutput>

	<cfif stPasskey.bSuccess>
		<cfoutput><p><admin:resource key="security.mfa.challenge.passkeyhelp">Use your passkey, or enter a code from your authenticator app or a recovery code.</admin:resource></p></cfoutput>
		<cfset request.fc.stPasskeyChallenge = { stOptions = stPasskey.stOptions, submitId = "mfaVerifyBtn" } />
		<skin:view typename="farMFAFactor" template="displayChallengePasskey" />
		<cfoutput><p class="mfa-or"><admin:resource key="security.mfa.challenge.or">or enter a code</admin:resource></p></cfoutput>
	<cfelse>
		<cfoutput><p><admin:resource key="security.mfa.challenge.help">Enter the 6 digit code from your authenticator app, or one of your recovery codes.</admin:resource></p></cfoutput>
	</cfif>

	<ft:object typename="farMFAChallenge" lFields="code" prefix="mfa" legend="" focusField="code" r_stFields="stFields" />

	<cfoutput>
		<fieldset>
			<label for="#stFields.code.formfieldname#">#stFields.code.ftLabel#</label>
			#stFields.code.html#
		</fieldset>

		<div class="pull-right">
			<ft:button rendertype="button" id="mfaVerifyBtn" class="btn btn-primary btn-large" rbkey="security.mfa.buttons.verify" value="Verify" />
		</div>

		<p class="help-inline">
			<a href="#application.url.webtoplogin#?mfacancel=1"><admin:resource key="security.mfa.challenge.cancel">Sign in as a different user</admin:resource></a>
		</p>
	</cfoutput>

</ft:form>

<skin:view typename="farLogin" template="displayFooterLogin" />

<cfsetting enablecfoutputonly="false">
