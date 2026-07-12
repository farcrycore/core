<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Passkey enrolment block --->
<!--- @@description: Composable fragment: a button that runs a WebAuthn create() ceremony client side and posts the result into the surrounding ft:form. Expects request.fc.stPasskeyEnrol = { stOptions, submitId (optional - id of a submit control to click), bAllowLabel (optional), cancelHref (optional - renders a Cancel beside the button) }. The secret never applies (a passkey is public key), so this needs no encryption key. See docs/0014. --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="request.fc.stPasskeyEnrol" default="#structnew()#" />

<cfif structKeyExists(request.fc.stPasskeyEnrol, "stOptions")>
	<cfset stPkParam = request.fc.stPasskeyEnrol />
	<cfparam name="stPkParam.submitId" default="" />
	<cfparam name="stPkParam.bAllowLabel" default="false" />
	<cfparam name="stPkParam.cancelHref" default="" />
	<cfparam name="stPkParam.buttonClass" default="btn btn-primary" /><!--- login passes btn-large for the hero; the webtop uses the normal size --->

	<!--- registered JS through the resource pipeline (cached / versioned); the helper self-defers to DOMContentLoaded, so head loading is fine --->
	<skin:loadJS id="fc-webauthn" />

	<cfoutput>
		<div class="mfa-passkey">
			<cfif stPkParam.bAllowLabel>
				<fieldset class="mfa-passkey-name">
					<label for="mfaPasskeyLabel"><admin:resource key="security.mfa.passkey.namefield">Name for this passkey (optional)</admin:resource></label>
					<input type="text" id="mfaPasskeyLabel" name="passkeyLabel" maxlength="255" autocomplete="off" placeholder="e.g. Work laptop, or a security key" />
				</fieldset>
			</cfif>

			<p>
				<button type="button" class="#stPkParam.buttonClass#" data-mfa-webauthn="register"<cfif len(stPkParam.submitId)> data-mfa-submit="#encodeForHTMLAttribute(stPkParam.submitId)#"</cfif> data-mfa-error="mfaPasskeyError" data-mfa-options="#encodeForHTMLAttribute(serializeJSON(stPkParam.stOptions))#"><i class="fa fa-key"></i> <admin:resource key="security.mfa.passkey.setup">Set up a passkey</admin:resource></button><cfif len(stPkParam.cancelHref)> <a href="#encodeForHTMLAttribute(stPkParam.cancelHref)#" class="btn"><admin:resource key="security.mfa.manage.cancelsetup">Cancel</admin:resource></a></cfif>
			</p>

			<p class="help-block mfa-error" id="mfaPasskeyError"></p>
		</div>
	</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">
