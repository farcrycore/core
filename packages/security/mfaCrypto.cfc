<cfcomponent displayname="MFA Crypto" hint="Stateless helpers for multi-factor authentication: Base32 (RFC 4648), TOTP (RFC 6238), AES-GCM secret storage keyed from the environment, constant time comparison and recovery code generation. JVM built-ins only; runs on Lucee and Adobe ColdFusion." output="false">

	<cfset variables.BASE32_ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567" />
	<!--- recovery code alphabet omits easily confused characters (I, L, O, 0, 1) --->
	<cfset variables.RECOVERY_ALPHABET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789" />

	<cffunction name="init" access="public" output="false" returntype="any" hint="Constructor">
		<cfreturn this />
	</cffunction>


	<!--- key handling --->

	<cffunction name="isKeyConfigured" access="public" output="false" returntype="boolean" hint="Returns true when the environment holds a usable AES key">
		<cftry>
			<cfset getKey() />
			<cfreturn true />
			<cfcatch>
				<cfreturn false />
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="keyFromB64" access="private" output="false" returntype="any" hint="Builds an AES SecretKeySpec from a base64 key; throws when missing or malformed">
		<cfargument name="b64Key" type="string" required="true" />
		<cfset var binKey = "" />

		<cfif not len(trim(arguments.b64Key))>
			<cfthrow message="The MFA encryption key is not configured" detail="Multi-factor authentication stores shared secrets encrypted at rest. Set the FARCRY_CONFIG_SECURITY_MFAENCRYPTKEY environment variable to a base64 encoded 128, 192 or 256 bit key." />
		</cfif>

		<cftry>
			<cfset binKey = binaryDecode(trim(arguments.b64Key), "base64") />
			<cfcatch>
				<cfthrow message="The MFA encryption key is not valid base64" />
			</cfcatch>
		</cftry>

		<!--- byte length via hex render: arrayLen on a Java byte[] is not reliable across engines --->
		<cfif not listFind("16,24,32", len(binaryEncode(binKey, "hex")) / 2)>
			<cfthrow message="The MFA encryption key must decode to a 128, 192 or 256 bit key" />
		</cfif>

		<cfreturn createObject("java", "javax.crypto.spec.SecretKeySpec").init(binKey, "AES") />
	</cffunction>

	<cffunction name="getKey" access="private" output="false" returntype="any" hint="The current AES key (security.mfaEncryptKey, set read-only via FARCRY_CONFIG_SECURITY_MFAENCRYPTKEY) - the key new secrets are sealed with">
		<cfreturn keyFromB64(application.fapi.getConfig("security", "mfaEncryptKey", "")) />
	</cffunction>

	<cffunction name="getCurrentKeyId" access="public" output="false" returntype="string" hint="Identifier for the current key, stamped into new envelopes (security.mfaEncryptKeyId). Alphanumeric; defaults to 1">
		<cfset var id = reReplace(trim(application.fapi.getConfig("security", "mfaEncryptKeyId", "1")), "[^A-Za-z0-9]", "", "all") />
		<cfreturn len(id) ? id : "1" />
	</cffunction>

	<cffunction name="envelopeKeyId" access="public" output="false" returntype="string" hint="The key id a sealed secret is stamped with (the gcm envelope's second segment), or empty for anything that is not a recognised gcm envelope">
		<cfargument name="sealed" type="string" required="true" />

		<cfif listFirst(arguments.sealed, ".") neq "gcm" or listLen(arguments.sealed, ".") neq 4>
			<cfreturn "" />
		</cfif>
		<cfreturn listGetAt(arguments.sealed, 2, ".") />
	</cffunction>

	<cffunction name="retainedKeyCount" access="public" output="false" returntype="numeric" hint="How many old keys are currently retained for decryption during a rotation (security.mfaEncryptKeysOld); structurally valid pairs only">
		<cfset var raw = trim(application.fapi.getConfig("security", "mfaEncryptKeysOld", "")) />
		<cfset var pair = "" />
		<cfset var n = 0 />

		<cfloop list="#raw#" index="pair" delimiters=",">
			<cfif find(":", pair) and len(reReplace(trim(listFirst(pair, ":")), "[^A-Za-z0-9]", "", "all")) and len(trim(listRest(pair, ":")))>
				<cfset n = n + 1 />
			</cfif>
		</cfloop>

		<cfreturn n />
	</cffunction>

	<cffunction name="getKeySet" access="private" output="false" returntype="struct" hint="Every key available for decryption, keyed by id: the current key plus any old keys retained for a rotation (security.mfaEncryptKeysOld, 'id:base64,id:base64'). All key material is read from the environment, never the DB. The current key always holds its own id; a retained key that happens to share that id is kept under a distinct synthetic id so it is never dropped from the decrypt set (a decrypt-with-any safety net - keyRotationSelfTest flags the id collision so the operator bumps mfaEncryptKeyId and secrets can migrate).">
		<cfset var stKeys = structNew() />
		<cfset var oldRaw = trim(application.fapi.getConfig("security", "mfaEncryptKeysOld", "")) />
		<cfset var pair = "" />
		<cfset var pid = "" />
		<cfset var pkey = "" />
		<cfset var dup = 0 />

		<!--- current key first, under its own id, so a gcm.<currentid> secret resolves straight to it --->
		<cfset stKeys[getCurrentKeyId()] = getKey() />

		<cfloop list="#oldRaw#" index="pair" delimiters=",">
			<cfif find(":", pair)>
				<cfset pid = reReplace(trim(listFirst(pair, ":")), "[^A-Za-z0-9]", "", "all") />
				<cfset pkey = trim(listRest(pair, ":")) />
				<cfif len(pid) and len(pkey)>
					<cftry>
						<!--- never overwrite a key already in the set (the current key, or an earlier retained key) that shares this id: keep this one under a distinct id so decrypt-with-any can still try it. Synthetic ids carry a "~" which a real (alphanumeric) envelope id never has. --->
						<cfif structKeyExists(stKeys, pid)>
							<cfset dup = dup + 1 />
							<cfset stKeys[pid & "~" & dup] = keyFromB64(pkey) />
						<cfelse>
							<cfset stKeys[pid] = keyFromB64(pkey) />
						</cfif>
						<cfcatch><!--- skip a malformed retained key rather than break every decryption ---></cfcatch>
					</cftry>
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn stKeys />
	</cffunction>


	<!--- primitives --->

	<cffunction name="randomBytes" access="private" output="false" returntype="binary" hint="Returns n cryptographically random bytes">
		<cfargument name="n" type="numeric" required="true" />

		<!--- build a hex string byte by byte, then decode: avoids any engine difference in whether nextBytes(byte[]) mutates a CFML-owned array in place --->
		<cfset var oRandom = createObject("java", "java.security.SecureRandom").init() />
		<cfset var hexOut = "" />
		<cfset var i = 0 />

		<cfloop from="1" to="#arguments.n#" index="i">
			<cfset hexOut = hexOut & right("0" & formatBaseN(oRandom.nextInt(javacast("int", 256)), 16), 2) />
		</cfloop>

		<cfreturn binaryDecode(hexOut, "hex") />
	</cffunction>

	<cffunction name="constantTimeEquals" access="public" output="false" returntype="boolean" hint="Compares two strings in constant time">
		<cfargument name="a" type="string" required="true" />
		<cfargument name="b" type="string" required="true" />

		<cfreturn createObject("java", "java.security.MessageDigest").isEqual(charsetDecode(arguments.a, "utf-8"), charsetDecode(arguments.b, "utf-8")) />
	</cffunction>

	<cffunction name="base32Encode" access="public" output="false" returntype="string" hint="Encodes binary data as unpadded RFC 4648 Base32">
		<cfargument name="data" type="binary" required="true" />

		<cfset var result = "" />
		<cfset var buffer = 0 />
		<cfset var bitsLeft = 0 />
		<cfset var i = 0 />
		<!--- iterate a hex rendering rather than indexing the byte array - consistent across engines --->
		<cfset var hexData = lcase(binaryEncode(arguments.data, "hex")) />

		<cfloop from="1" to="#len(hexData) / 2#" index="i">
			<cfset buffer = bitOr(bitSHLN(buffer, 8), inputBaseN(mid(hexData, i * 2 - 1, 2), 16)) />
			<cfset bitsLeft = bitsLeft + 8 />
			<cfloop condition="bitsLeft gte 5">
				<cfset result = result & mid(variables.BASE32_ALPHABET, bitAnd(bitSHRN(buffer, bitsLeft - 5), 31) + 1, 1) />
				<cfset bitsLeft = bitsLeft - 5 />
			</cfloop>
			<!--- keep the working buffer inside 32 bit integer range --->
			<cfset buffer = bitAnd(buffer, bitSHLN(1, bitsLeft) - 1) />
		</cfloop>

		<cfif bitsLeft gt 0>
			<cfset result = result & mid(variables.BASE32_ALPHABET, bitAnd(bitSHLN(buffer, 5 - bitsLeft), 31) + 1, 1) />
		</cfif>

		<cfreturn result />
	</cffunction>

	<cffunction name="base32Decode" access="public" output="false" returntype="binary" hint="Decodes RFC 4648 Base32 (padding and whitespace tolerated) to binary">
		<cfargument name="data" type="string" required="true" />

		<cfset var cleaned = ucase(reReplace(arguments.data, "[\s=-]", "", "all")) />
		<cfset var hexOut = "" />
		<cfset var buffer = 0 />
		<cfset var bitsLeft = 0 />
		<cfset var i = 0 />
		<cfset var idx = 0 />

		<cfloop from="1" to="#len(cleaned)#" index="i">
			<cfset idx = find(mid(cleaned, i, 1), variables.BASE32_ALPHABET) />
			<cfif idx eq 0>
				<cfthrow message="Invalid Base32 character in input" />
			</cfif>
			<cfset buffer = bitOr(bitSHLN(buffer, 5), idx - 1) />
			<cfset bitsLeft = bitsLeft + 5 />
			<cfif bitsLeft gte 8>
				<cfset hexOut = hexOut & right("0" & formatBaseN(bitAnd(bitSHRN(buffer, bitsLeft - 8), 255), 16), 2) />
				<cfset bitsLeft = bitsLeft - 8 />
				<cfset buffer = bitAnd(buffer, bitSHLN(1, bitsLeft) - 1) />
			</cfif>
		</cfloop>

		<cfif not len(hexOut)>
			<cfthrow message="Base32 input decoded to no data" />
		</cfif>

		<cfreturn binaryDecode(hexOut, "hex") />
	</cffunction>


	<!--- TOTP (RFC 6238) --->

	<cffunction name="generateTOTPSecret" access="public" output="false" returntype="string" hint="Returns a new 160 bit shared secret as Base32">
		<cfreturn base32Encode(randomBytes(20)) />
	</cffunction>

	<cffunction name="epochSeconds" access="public" output="false" returntype="numeric" hint="Seconds since the Unix epoch">
		<cfreturn int(getTickCount() / 1000) />
	</cffunction>

	<cffunction name="currentTimestep" access="public" output="false" returntype="numeric" hint="The current 30 second TOTP timestep">
		<cfreturn int(epochSeconds() / 30) />
	</cffunction>

	<cffunction name="totpCode" access="public" output="false" returntype="string" hint="Computes the TOTP code for a secret and timestep (HMAC-SHA1, RFC 6238)">
		<cfargument name="secretB32" type="string" required="true" hint="Base32 shared secret" />
		<cfargument name="timestep" type="numeric" required="true" hint="Counter value, floor(epochSeconds/30)" />
		<cfargument name="digits" type="numeric" required="false" default="6" />

		<cfset var binKey = base32Decode(arguments.secretB32) />
		<cfset var counterHex = right(repeatString("0", 16) & ucase(formatBaseN(arguments.timestep, 16)), 16) />
		<cfset var oMac = createObject("java", "javax.crypto.Mac").getInstance("HmacSHA1") />
		<cfset var hmacHex = "" />
		<cfset var offset = 0 />
		<cfset var binCode = 0 />

		<cfset oMac.init(createObject("java", "javax.crypto.spec.SecretKeySpec").init(binKey, "HmacSHA1")) />
		<cfset hmacHex = lcase(binaryEncode(oMac.doFinal(binaryDecode(counterHex, "hex")), "hex")) />

		<!--- dynamic truncation: low nibble of the last byte selects a 4 byte window; hex string reads keep this engine safe --->
		<cfset offset = bitAnd(inputBaseN(right(hmacHex, 2), 16), 15) />
		<cfset binCode = bitAnd(inputBaseN(mid(hmacHex, offset * 2 + 1, 2), 16), 127) * 16777216
						+ inputBaseN(mid(hmacHex, offset * 2 + 3, 6), 16) />

		<cfreturn right(repeatString("0", arguments.digits) & (binCode mod (10 ^ arguments.digits)), arguments.digits) />
	</cffunction>

	<cffunction name="verifyTOTP" access="public" output="false" returntype="struct" hint="Verifies a submitted TOTP code within a +/- 1 step window, with replay protection">
		<cfargument name="secretB32" type="string" required="true" />
		<cfargument name="code" type="string" required="true" hint="The submitted code" />
		<cfargument name="lastAcceptedStep" type="numeric" required="false" default="0" hint="Highest timestep already accepted for this secret" />
		<cfargument name="window" type="numeric" required="false" default="1" hint="Steps of clock drift tolerated either side" />

		<cfset var stResult = { verified = false, reason = "badCode", step = 0 } />
		<cfset var submitted = trim(arguments.code) />
		<cfset var base = currentTimestep() />
		<cfset var i = 0 />
		<cfset var step = 0 />

		<cfif not (len(submitted) eq 6 and isNumeric(submitted))>
			<cfreturn stResult />
		</cfif>

		<cfloop from="#0 - arguments.window#" to="#arguments.window#" index="i">
			<cfset step = base + i />
			<cfif constantTimeEquals(totpCode(arguments.secretB32, step), submitted)>
				<cfif step lte arguments.lastAcceptedStep>
					<cfset stResult.reason = "replayedCode" />
				<cfelse>
					<cfset stResult.verified = true />
					<cfset stResult.reason = "" />
					<cfset stResult.step = step />
				</cfif>
				<cfbreak />
			</cfif>
		</cfloop>

		<cfreturn stResult />
	</cffunction>

	<cffunction name="otpauthURI" access="public" output="false" returntype="string" hint="Builds the otpauth:// provisioning URI rendered as a QR code client side">
		<cfargument name="issuer" type="string" required="true" />
		<cfargument name="account" type="string" required="true" />
		<cfargument name="secretB32" type="string" required="true" />

		<cfreturn "otpauth://totp/#urlEncodedFormat(arguments.issuer)#:#urlEncodedFormat(arguments.account)#?secret=#arguments.secretB32#&issuer=#urlEncodedFormat(arguments.issuer)#&algorithm=SHA1&digits=6&period=30" />
	</cffunction>

	<cffunction name="rfc6238SelfTest" access="public" output="false" returntype="struct" hint="Runs the RFC 6238 Appendix B HMAC-SHA1 test vectors; returns { pass, results }">
		<cfset var stResult = { pass = true, results = arraynew(1) } />
		<cfset var secretB32 = base32Encode(charsetDecode("12345678901234567890", "utf-8")) />
		<cfset var aVectors = [
			{ t = 59, expected = "94287082" },
			{ t = 1111111109, expected = "07081804" },
			{ t = 1111111111, expected = "14050471" },
			{ t = 1234567890, expected = "89005924" },
			{ t = 2000000000, expected = "69279037" },
			{ t = 20000000000, expected = "65353130" }
		] />
		<cfset var stVector = "" />
		<cfset var computed = "" />

		<cfloop array="#aVectors#" index="stVector">
			<cfset computed = totpCode(secretB32, int(stVector.t / 30), 8) />
			<cfset arrayAppend(stResult.results, { t = stVector.t, expected = stVector.expected, computed = computed, pass = (computed eq stVector.expected) }) />
			<cfif computed neq stVector.expected>
				<cfset stResult.pass = false />
			</cfif>
		</cfloop>

		<cfreturn stResult />
	</cffunction>


	<!--- secret storage (AES-GCM, versioned envelope for key rotation) --->

	<cffunction name="gcmSeal" access="private" output="false" returntype="string" hint="AES-GCM encrypt with a given key; returns base64(iv).base64(ciphertext) using a fresh 96 bit IV and a 128 bit tag">
		<cfargument name="oKey" type="any" required="true" />
		<cfargument name="plaintext" type="string" required="true" />

		<cfset var iv = randomBytes(12) />
		<!--- class handle for the static ENCRYPT_MODE constant + the getInstance factory (instance-field access is not reliable on ACF) --->
		<cfset var cipherClass = createObject("java", "javax.crypto.Cipher") />
		<cfset var oCipher = cipherClass.getInstance("AES/GCM/NoPadding") />

		<cfset oCipher.init(cipherClass.ENCRYPT_MODE, arguments.oKey, createObject("java", "javax.crypto.spec.GCMParameterSpec").init(javacast("int", 128), iv)) />

		<cfreturn binaryEncode(iv, "base64") & "." & binaryEncode(oCipher.doFinal(charsetDecode(arguments.plaintext, "utf-8")), "base64") />
	</cffunction>

	<cffunction name="gcmDecrypt" access="private" output="false" returntype="string" hint="AES-GCM decrypt with a given key; throws on a bad tag (wrong key or tampered data)">
		<cfargument name="oKey" type="any" required="true" />
		<cfargument name="ivB64" type="string" required="true" />
		<cfargument name="ctB64" type="string" required="true" />

		<cfset var cipherClass = createObject("java", "javax.crypto.Cipher") />
		<cfset var oCipher = cipherClass.getInstance("AES/GCM/NoPadding") />

		<cfset oCipher.init(cipherClass.DECRYPT_MODE, arguments.oKey, createObject("java", "javax.crypto.spec.GCMParameterSpec").init(javacast("int", 128), binaryDecode(arguments.ivB64, "base64"))) />

		<cfreturn charsetEncode(oCipher.doFinal(binaryDecode(arguments.ctB64, "base64")), "utf-8") />
	</cffunction>

	<cffunction name="encryptSecret" access="public" output="false" returntype="string" hint="Encrypts a secret for storage at rest, sealed with the current key: gcm.keyid.base64(iv).base64(ciphertext)">
		<cfargument name="plaintext" type="string" required="true" />

		<cfreturn "gcm." & getCurrentKeyId() & "." & gcmSeal(getKey(), arguments.plaintext) />
	</cffunction>

	<cffunction name="decryptSecret" access="public" output="false" returntype="string" hint="Decrypts a secret sealed by encryptSecret (gcm.keyid.base64(iv).base64(ciphertext)); prefers the stamped key, then falls back to any configured key (the GCM tag identifies the right one).">
		<cfargument name="sealed" type="string" required="true" />

		<cfset var scheme = listFirst(arguments.sealed, ".") />
		<cfset var stKeys = getKeySet() />
		<cfset var keyid = "" />
		<cfset var ivB64 = "" />
		<cfset var ctB64 = "" />

		<cfif scheme eq "gcm" and listLen(arguments.sealed, ".") eq 4>
			<cfset keyid = listGetAt(arguments.sealed, 2, ".") />
			<cfset ivB64 = listGetAt(arguments.sealed, 3, ".") />
			<cfset ctB64 = listGetAt(arguments.sealed, 4, ".") />
			<!--- prefer the stamped key, then fall through to trying every key --->
			<cfif structKeyExists(stKeys, keyid)>
				<cftry>
					<cfreturn gcmDecrypt(stKeys[keyid], ivB64, ctB64) />
					<cfcatch><!--- stamped key did not work; fall through to decrypt-with-any ---></cfcatch>
				</cftry>
			</cfif>
		<cfelse>
			<cfthrow message="Unrecognised sealed secret format" />
		</cfif>

		<cfreturn decryptWithAnyKey(stKeys, ivB64, ctB64) />
	</cffunction>

	<cffunction name="decryptWithAnyKey" access="private" output="false" returntype="string" hint="Tries every configured key; the AES-GCM tag ensures only the correct key yields plaintext. Throws when none match.">
		<cfargument name="stKeys" type="struct" required="true" />
		<cfargument name="ivB64" type="string" required="true" />
		<cfargument name="ctB64" type="string" required="true" />

		<cfset var aIds = structKeyArray(arguments.stKeys) />
		<cfset var i = 0 />

		<cfloop from="1" to="#arrayLen(aIds)#" index="i">
			<cftry>
				<cfreturn gcmDecrypt(arguments.stKeys[aIds[i]], arguments.ivB64, arguments.ctB64) />
				<cfcatch><!--- wrong key; try the next ---></cfcatch>
			</cftry>
		</cfloop>

		<cfthrow message="No configured MFA key could decrypt the secret" detail="The key that sealed this secret is not among the current or retained keys (security.mfaEncryptKey / security.mfaEncryptKeysOld)." />
	</cffunction>

	<cffunction name="needsRewrap" access="public" output="false" returntype="boolean" hint="True when a sealed secret is not sealed under the current key (an unrecognised envelope, or a gcm envelope stamped with a non-current key id), so it should be re-encrypted the next time the plaintext is in hand.">
		<cfargument name="sealed" type="string" required="true" />

		<cfif listFirst(arguments.sealed, ".") neq "gcm" or listLen(arguments.sealed, ".") neq 4>
			<cfreturn true />
		</cfif>

		<cfreturn listGetAt(arguments.sealed, 2, ".") neq getCurrentKeyId() />
	</cffunction>

	<cffunction name="keyRotationSelfTest" access="public" output="false" returntype="struct" hint="Exercises the versioned envelope: current-key round-trip, an old-key-id read, re-wrap detection and decrypt-with-any across a key set (using the live current key plus ephemeral keys). Returns { pass, results }.">
		<cfset var stResult = { pass = true, results = arraynew(1) } />
		<cfset var plain = "JBSWY3DPEHPK3PXP" />
		<cfset var sealed = "" />
		<cfset var body = "" />
		<cfset var kEphemeral = "" />
		<cfset var stSetWith = structNew() />
		<cfset var stSetWithout = structNew() />
		<cfset var ok = false />
		<cfset var threw = false />
		<cfset var currentId = "" />
		<cfset var oldRaw = "" />
		<cfset var clash = false />
		<cfset var pair = "" />

		<!--- 1. current key: seal -> open round-trips, stamps the gcm envelope, and does not want a re-wrap --->
		<cftry>
			<cfset sealed = encryptSecret(plain) />
			<cfset ok = (decryptSecret(sealed) eq plain) and (listFirst(sealed, ".") eq "gcm") and (not needsRewrap(sealed)) />
			<cfset arrayAppend(stResult.results, { test = "current key round-trip, gcm envelope, no re-wrap", pass = ok }) />
			<cfif not ok><cfset stResult.pass = false /></cfif>
			<cfcatch>
				<cfset arrayAppend(stResult.results, { test = "current key round-trip", pass = false, error = cfcatch.message }) />
				<cfset stResult.pass = false />
			</cfcatch>
		</cftry>

		<!--- 2. a secret stamped with a non-current key id (as during a rotation) still decrypts via the key set, and is flagged for re-wrap --->
		<cftry>
			<cfset sealed = "gcm.retired." & gcmSeal(getKey(), plain) />
			<cfset ok = (decryptSecret(sealed) eq plain) and needsRewrap(sealed) />
			<cfset arrayAppend(stResult.results, { test = "old-key-id envelope decrypts via the key set + flagged for re-wrap", pass = ok }) />
			<cfif not ok><cfset stResult.pass = false /></cfif>
			<cfcatch>
				<cfset arrayAppend(stResult.results, { test = "old-key-id envelope read", pass = false, error = cfcatch.message }) />
				<cfset stResult.pass = false />
			</cfcatch>
		</cftry>

		<!--- 3. decrypt-with-any finds a retained key and rejects a secret whose key is absent --->
		<cftry>
			<cfset kEphemeral = keyFromB64(binaryEncode(randomBytes(32), "base64")) />
			<cfset body = gcmSeal(kEphemeral, plain) />
			<cfset stSetWith["retired"] = kEphemeral />
			<cfset stSetWith["current"] = getKey() />
			<cfset stSetWithout["current"] = getKey() />

			<cfset threw = false />
			<cftry>
				<cfset decryptWithAnyKey(stSetWithout, listFirst(body, "."), listLast(body, ".")) />
				<cfcatch><cfset threw = true /></cfcatch>
			</cftry>

			<cfset ok = (decryptWithAnyKey(stSetWith, listFirst(body, "."), listLast(body, ".")) eq plain) and threw />
			<cfset arrayAppend(stResult.results, { test = "decrypt-with-any finds a retained key, rejects when absent", pass = ok }) />
			<cfif not ok><cfset stResult.pass = false /></cfif>
			<cfcatch>
				<cfset arrayAppend(stResult.results, { test = "decrypt-with-any", pass = false, error = cfcatch.message }) />
				<cfset stResult.pass = false />
			</cfcatch>
		</cftry>

		<!--- 4. config sanity: a retained key id must not equal the current key id, or its secrets cannot be told apart from current-key secrets and will not migrate. Fails safe (decrypt-with-any still reads them) but must be corrected by bumping mfaEncryptKeyId. --->
		<cftry>
			<cfset currentId = getCurrentKeyId() />
			<cfset oldRaw = trim(application.fapi.getConfig("security", "mfaEncryptKeysOld", "")) />
			<cfset clash = false />
			<cfloop list="#oldRaw#" index="pair" delimiters=",">
				<cfif find(":", pair) and reReplace(trim(listFirst(pair, ":")), "[^A-Za-z0-9]", "", "all") eq currentId>
					<cfset clash = true />
				</cfif>
			</cfloop>
			<cfset arrayAppend(stResult.results, { test = "no retained key id collides with the current key id (" & currentId & ")", pass = (not clash) }) />
			<cfif clash><cfset stResult.pass = false /></cfif>
			<cfcatch>
				<cfset arrayAppend(stResult.results, { test = "retained-id collision check", pass = false, error = cfcatch.message }) />
				<cfset stResult.pass = false />
			</cfcatch>
		</cftry>

		<cfreturn stResult />
	</cffunction>


	<!--- recovery codes --->

	<cffunction name="generateRecoveryCodes" access="public" output="false" returntype="array" hint="Returns single-use recovery codes in the form XXXXX-XXXXX">
		<cfargument name="count" type="numeric" required="false" default="10" />

		<cfset var aCodes = arraynew(1) />
		<cfset var oRandom = createObject("java", "java.security.SecureRandom").init() />
		<cfset var code = "" />
		<cfset var i = 0 />
		<cfset var c = 0 />

		<cfloop from="1" to="#arguments.count#" index="i">
			<cfset code = "" />
			<cfloop from="1" to="10" index="c">
				<cfset code = code & mid(variables.RECOVERY_ALPHABET, oRandom.nextInt(javacast("int", len(variables.RECOVERY_ALPHABET))) + 1, 1) />
			</cfloop>
			<cfset arrayAppend(aCodes, left(code, 5) & "-" & right(code, 5)) />
		</cfloop>

		<cfreturn aCodes />
	</cffunction>

	<cffunction name="generateNumericCode" access="public" output="false" returntype="string" hint="Returns a cryptographically random numeric code of the given length (default 6), for an emailed one-time code; leading zeros are preserved">
		<cfargument name="digits" type="numeric" required="false" default="6" />

		<cfset var oRandom = createObject("java", "java.security.SecureRandom").init() />
		<cfset var code = "" />
		<cfset var i = 0 />

		<cfloop from="1" to="#int(arguments.digits)#" index="i">
			<cfset code = code & oRandom.nextInt(javacast("int", 10)) />
		</cfloop>

		<cfreturn code />
	</cffunction>

	<cffunction name="numericCodeSelfTest" access="public" output="false" returntype="struct" hint="Checks generateNumericCode: correct length, only digits, leading zeros preserved, codes vary, and every digit 0-9 appears. Returns { pass, results }">
		<cfset var stResult = { pass = true, results = arraynew(1) } />
		<cfset var aLens = [4, 6, 8] />
		<cfset var d = 0 />
		<cfset var code = "" />
		<cfset var samples = 500 />
		<cfset var s = 0 />
		<cfset var j = 0 />
		<cfset var ch = "" />
		<cfset var distinct = structnew() />
		<cfset var digitsSeen = structnew() />
		<cfset var sawZero = false />
		<cfset var lenOk = true />
		<cfset var onlyDigits = true />
		<cfset var allTen = true />
		<cfset var r = "" />

		<!--- length + charset across several digit counts --->
		<cfloop array="#aLens#" index="d">
			<cfset code = generateNumericCode(d) />
			<cfif len(code) neq d><cfset lenOk = false /></cfif>
			<cfif reFind("[^0-9]", code)><cfset onlyDigits = false /></cfif>
		</cfloop>
		<cfset arrayAppend(stResult.results, { name = "length matches requested digits", pass = lenOk }) />
		<cfset arrayAppend(stResult.results, { name = "only digits 0-9", pass = onlyDigits }) />

		<!--- sample many 6 digit codes: leading zeros, variety, full digit coverage --->
		<cfloop from="1" to="#samples#" index="s">
			<cfset code = generateNumericCode(6) />
			<cfif left(code, 1) eq "0"><cfset sawZero = true /></cfif>
			<cfset distinct[code] = 1 />
			<cfloop from="1" to="6" index="j">
				<cfset ch = mid(code, j, 1) />
				<cfset digitsSeen[ch] = 1 />
			</cfloop>
		</cfloop>
		<cfset arrayAppend(stResult.results, { name = "leading zeros preserved", pass = sawZero }) />
		<cfset arrayAppend(stResult.results, { name = "codes vary (not stuck)", pass = (structCount(distinct) gt (samples * 0.9)) }) />

		<cfloop from="0" to="9" index="j">
			<cfif not structKeyExists(digitsSeen, j)><cfset allTen = false /></cfif>
		</cfloop>
		<cfset arrayAppend(stResult.results, { name = "every digit 0-9 appears", pass = allTen }) />

		<cfloop array="#stResult.results#" index="r">
			<cfif not r.pass><cfset stResult.pass = false /></cfif>
		</cfloop>

		<cfreturn stResult />
	</cffunction>

</cfcomponent>
