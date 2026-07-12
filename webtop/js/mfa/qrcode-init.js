/* FarCry MFA - draws the enrolment TOTP QR code.
   External + registered (loaded via skin:loadJS / fc-qrcode-init) so a strict
   Content-Security-Policy can forbid inline script and the resource pipeline
   caches/versions the file. Reads the otpauth:// URI from the #mfaEnrolQR
   container's data attribute and renders it with the qrcodejs library
   (fc-qrcode), which loads immediately before this file. Self-defers to
   DOMContentLoaded, so loading from the head is fine. */
(function () {
	"use strict";

	function draw() {
		var el = document.getElementById("mfaEnrolQR");
		if (!el || typeof QRCode === "undefined") { return; }
		if (el.getAttribute("data-mfa-qr-drawn")) { return; }
		var uri = el.getAttribute("data-mfa-otpauth");
		if (!uri) { return; }
		el.setAttribute("data-mfa-qr-drawn", "1");
		new QRCode(el, { text: uri, width: 180, height: 180, correctLevel: QRCode.CorrectLevel.M });
	}

	if (document.readyState === "loading") {
		document.addEventListener("DOMContentLoaded", draw);
	} else {
		draw();
	}

	// exposed so a view that injects the enrolment fragment after load can redraw; the data-mfa-qr-drawn guard makes it idempotent
	window.fcMfaQrcodeInit = draw;
})();
