<cfsetting enablecfoutputonly="true">
<!--- @@displayname: TOTP enrolment block --->
<!--- @@description: Composable fragment: renders the enrolment QR code (drawn client side; the secret never leaves the page) and the manual entry key. Expects request.fc.stMFAEnrol = { secret, otpauthURI } from the composing view. --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="request.fc.stMFAEnrol" default="#structnew()#" />

<cfif structKeyExists(request.fc.stMFAEnrol, "otpauthURI")>
	<!--- registered JS through the resource pipeline (cached / versioned): the qrcodejs library, then the init that reads the otpauth URI off the container and draws it. qrcode-init self-defers to DOMContentLoaded, so head loading is fine and no inline script is emitted (CSP). --->
	<skin:loadJS id="fc-qrcode" />
	<skin:loadJS id="fc-qrcode-init" />

	<cfoutput>
		<div class="mfa-enrol">
			<!--- QR container is a paragraph so its natural bottom margin spaces it from the key below - no CSS needed. The otpauth URI rides a data attribute; qrcode-init.js reads it and draws the code. --->
			<p class="mfa-enrol-qr" id="mfaEnrolQR" data-mfa-otpauth="#encodeForHTMLAttribute(request.fc.stMFAEnrol.otpauthURI)#"></p>
			<p class="help-block">
				<admin:resource key="security.mfa.enrol.manualentry">Can't scan the code? Enter this key into your app instead:</admin:resource>
				<br />
				<code class="mfa-enrol-secret">#encodeForHTML(rereplace(request.fc.stMFAEnrol.secret, "(.{4})", "\1 ", "all"))#</code>
			</p>
		</div>
	</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">
