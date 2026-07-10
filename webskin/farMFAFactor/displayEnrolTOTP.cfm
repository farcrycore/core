<cfsetting enablecfoutputonly="true">
<!--- @@displayname: TOTP enrolment block --->
<!--- @@description: Composable fragment: renders the enrolment QR code (drawn client side; the secret never leaves the page) and the manual entry key. Expects request.fc.stMFAEnrol = { secret, otpauthURI } from the composing view. --->

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfparam name="request.fc.stMFAEnrol" default="#structnew()#" />

<cfif structKeyExists(request.fc.stMFAEnrol, "otpauthURI")>
	<cfoutput>
		<div class="mfa-enrol">
			<div class="mfa-enrol-qr" id="mfaEnrolQR"></div>
			<!--- ordered synchronous includes: the library is defined before the init runs, independent of head/inHead timing or render context --->
			<script type="text/javascript" src="#application.url.webtop#/thirdparty/qrcode/qrcode.min.js"></script>
			<script type="text/javascript">
				(function(){
					if (typeof QRCode === "undefined") { return; }
					new QRCode(document.getElementById("mfaEnrolQR"), {
						text: "#encodeForJavaScript(request.fc.stMFAEnrol.otpauthURI)#",
						width: 180,
						height: 180,
						correctLevel: QRCode.CorrectLevel.M
					});
				})();
			</script>
			<p class="help-block">
				<admin:resource key="security.mfa.enrol.manualentry">Can't scan the code? Enter this key into your app instead:</admin:resource>
				<br />
				<code class="mfa-enrol-secret">#encodeForHTML(rereplace(request.fc.stMFAEnrol.secret, "(.{4})", "\1 ", "all"))#</code>
			</p>
		</div>
	</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">
