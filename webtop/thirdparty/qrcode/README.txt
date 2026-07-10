qrcode.js (qrcodejs) v1.0.0 - minified
======================================

Source: https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js
Downloaded: 2026-07-10
Licence: MIT (see MIT-LICENSE.txt) - compatible with FarCry Core (GPL v3)
Project: https://github.com/davidshimjs/qrcodejs

Client-side QR code renderer. Exposes a single global, window.QRCode, which
draws a QR code into a container element using canvas (with a table fallback):

    new QRCode(document.getElementById("el"), {
        text: "otpauth://totp/...",
        width: 180, height: 180,
        correctLevel: QRCode.CorrectLevel.M
    });

Used by MFA (docs/0014) to render the TOTP enrolment otpauth:// URI in the
browser, so the shared secret is never sent to a third-party chart service.
Loaded by webskin/farMFAFactor/displayEnrolTOTP.cfm (direct <script src>) and
registered as "fc-qrcode" in packages/lib/registerLibraries.cfc for reuse.

To update:
  1. Pick the new version from https://github.com/davidshimjs/qrcodejs
  2. Download qrcode.min.js (cdnjs or the repo) and replace this file
  3. Update the version above
  4. Re-check the license text has not changed
