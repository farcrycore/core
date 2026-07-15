<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Passkey challenge block --->
<!--- @@description: Composable fragment: a button that runs a WebAuthn get() ceremony client side and posts the result into the surrounding ft:form. Expects request.fc.stPasskeyChallenge = { stOptions, submitId (optional - id of a submit control to click) }. --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="request.fc.stPasskeyChallenge" default="#structnew()#" />

<cfif structKeyExists(request.fc.stPasskeyChallenge, "stOptions")>
	<cfset stPkParam = request.fc.stPasskeyChallenge />
	<cfparam name="stPkParam.submitId" default="" />

	<!--- registered JS through the resource pipeline (cached / versioned); the helper self-defers to DOMContentLoaded, so head loading is fine --->
	<skin:loadJS id="fc-webauthn" />

	<cfoutput>
		<div class="mfa-passkey">
			<button type="button" class="btn btn-primary btn-large btn-block" data-mfa-webauthn="authenticate"<cfif len(stPkParam.submitId)> data-mfa-submit="#encodeForHTMLAttribute(stPkParam.submitId)#"</cfif> data-mfa-error="mfaPasskeyError" data-mfa-options="#encodeForHTMLAttribute(serializeJSON(stPkParam.stOptions))#"><i class="fa fa-key"></i> <admin:resource key="security.mfa.passkey.use">Use a passkey</admin:resource></button>

			<p class="help-block mfa-error" id="mfaPasskeyError"></p>
		</div>
	</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">
