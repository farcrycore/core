<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Passkey enrolment block --->
<!--- @@description: Composable fragment: a button that runs a WebAuthn create() ceremony client side and posts the result into the surrounding ft:form. Expects request.fc.stPasskeyEnrol = { stOptions, submitId (optional - id of a submit control to click), bAllowLabel (optional) }. The secret never applies (a passkey is public key), so this needs no encryption key. See docs/0014. --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfparam name="request.fc.stPasskeyEnrol" default="#structnew()#" />

<cfif structKeyExists(request.fc.stPasskeyEnrol, "stOptions")>
	<cfset stPkParam = request.fc.stPasskeyEnrol />
	<cfparam name="stPkParam.submitId" default="" />
	<cfparam name="stPkParam.bAllowLabel" default="false" />

	<cfoutput>
		<!--- ordered synchronous include: the helper is defined before the button is used, independent of head timing or render context (matches the QR fragment) --->
		<script type="text/javascript" src="#application.url.webtop#/js/mfa/webauthn.js"></script>

		<div class="mfa-passkey">
			<cfif stPkParam.bAllowLabel>
				<fieldset class="mfa-passkey-name">
					<label for="mfaPasskeyLabel"><admin:resource key="security.mfa.passkey.namefield">Name for this passkey (optional)</admin:resource></label>
					<input type="text" id="mfaPasskeyLabel" name="passkeyLabel" maxlength="255" autocomplete="off" />
				</fieldset>
			</cfif>

			<button type="button" class="btn btn-primary" data-mfa-webauthn="register"<cfif len(stPkParam.submitId)> data-mfa-submit="#encodeForHTMLAttribute(stPkParam.submitId)#"</cfif> data-mfa-error="mfaPasskeyError" data-mfa-options="#encodeForHTMLAttribute(serializeJSON(stPkParam.stOptions))#"><i class="fa fa-key"></i> <admin:resource key="security.mfa.passkey.setup">Set up a passkey</admin:resource></button>

			<p class="help-block mfa-error" id="mfaPasskeyError"></p>
		</div>
	</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">
