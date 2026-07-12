/* FarCry MFA - WebAuthn (passkey) ceremony helper.
   Content-Security-Policy clean: external file, no inline handlers, no inline styles.
   Buttons opt in with data attributes and the module wires them up on load:
     data-mfa-webauthn = "register" | "authenticate"
     data-mfa-options  = JSON options from the server (base64url fields decoded here)
     data-mfa-submit   = id of the form submit control to click once the ceremony succeeds
     data-mfa-error    = id of an element to receive a failure message (optional)
   See docs/0014. */
(function () {
	"use strict";

	function supported() {
		return !!(window.PublicKeyCredential && navigator.credentials && navigator.credentials.create && navigator.credentials.get);
	}

	function b64urlToBuf(value) {
		var s = String(value).replace(/-/g, "+").replace(/_/g, "/");
		while (s.length % 4) { s += "="; }
		var bin = window.atob(s), buf = new Uint8Array(bin.length), i;
		for (i = 0; i < bin.length; i++) { buf[i] = bin.charCodeAt(i); }
		return buf.buffer;
	}

	function bufToB64url(buf) {
		var bytes = new Uint8Array(buf), bin = "", i;
		for (i = 0; i < bytes.length; i++) { bin += String.fromCharCode(bytes[i]); }
		return window.btoa(bin).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
	}

	function setField(form, name, value) {
		var el = form.querySelector('input[name="' + name + '"]');
		if (!el) {
			el = document.createElement("input");
			el.type = "hidden";
			el.name = name;
			form.appendChild(el);
		}
		el.value = value;
	}

	function showError(btn, message) {
		var id = btn.getAttribute("data-mfa-error"), box = id ? document.getElementById(id) : null;
		if (box) { box.textContent = message; }
	}

	function submitForm(btn, form) {
		var id = btn.getAttribute("data-mfa-submit"), sb = id ? document.getElementById(id) : null;
		// preferred: click the real submit control so the framework's own form handling runs
		if (sb) { sb.click(); return; }
		// otherwise synthesize the framework's "button clicked" marker (processform needs a button value
		// to run) so a native submit is processed. The token / form fields ride along on the submit.
		var submitted = form.querySelector('input[name="FarcryFormSubmitted"]');
		if (submitted && submitted.value) {
			setField(form, "FarcryFormSubmitButtonClicked" + submitted.value, "mfaPasskey");
		}
		if (form.requestSubmit) { form.requestSubmit(); } else { form.submit(); }
	}

	function run(btn) {
		var form = btn.closest ? btn.closest("form") : null;
		if (!form) { return; }
		var mode = btn.getAttribute("data-mfa-webauthn"), options;

		showError(btn, "");

		try {
			options = JSON.parse(btn.getAttribute("data-mfa-options") || "{}");
		} catch (e) {
			showError(btn, "Could not start. Please reload the page and try again.");
			return;
		}

		options.challenge = b64urlToBuf(options.challenge);
		if (mode === "register" && options.user) { options.user.id = b64urlToBuf(options.user.id); }
		["excludeCredentials", "allowCredentials"].forEach(function (key) {
			if (options[key] && options[key].length) {
				options[key].forEach(function (cred) { cred.id = b64urlToBuf(cred.id); });
			}
		});

		btn.disabled = true;

		var ceremony = mode === "register"
			? navigator.credentials.create({ publicKey: options })
			: navigator.credentials.get({ publicKey: options });

		ceremony.then(function (cred) {
			var r = cred.response;
			setField(form, "credentialId", bufToB64url(cred.rawId));
			setField(form, "clientDataJSON", bufToB64url(r.clientDataJSON));

			if (mode === "register") {
				setField(form, "attestationObject", bufToB64url(r.attestationObject));
				var transports = (r.getTransports ? r.getTransports() : []) || [];
				setField(form, "transports", transports.join(","));
			} else {
				setField(form, "authenticatorData", bufToB64url(r.authenticatorData));
				setField(form, "signature", bufToB64url(r.signature));
				if (r.userHandle) { setField(form, "userHandle", bufToB64url(r.userHandle)); }
			}

			submitForm(btn, form);
		}).catch(function (err) {
			btn.disabled = false;
			var message = (err && err.name === "NotAllowedError")
				? "No passkey was used. You can try again, or use another method."
				: "Your passkey could not be used. Please try again, or use another method.";
			showError(btn, message);
		});
	}

	function init() {
		var buttons = document.querySelectorAll("[data-mfa-webauthn]"), i, btn;
		for (i = 0; i < buttons.length; i++) {
			btn = buttons[i];
			if (btn.getAttribute("data-mfa-bound")) { continue; }
			btn.setAttribute("data-mfa-bound", "1");

			if (!supported()) {
				btn.disabled = true;
				btn.title = "This browser or device does not support passkeys.";
				continue;
			}

			btn.addEventListener("click", function (event) {
				event.preventDefault();
				run(this);
			});
		}
	}

	if (document.readyState === "loading") {
		document.addEventListener("DOMContentLoaded", init);
	} else {
		init();
	}

	// exposed so a view that injects passkey buttons after load (e.g. a modal) can re-scan; the data-mfa-bound guard makes it idempotent
	window.fcMfaWebAuthnInit = init;
})();
