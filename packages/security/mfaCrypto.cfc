<cfcomponent displayname="MFA Crypto" hint="Stateless helpers for multi-factor authentication: Base32 (RFC 4648), TOTP (RFC 6238), AES-GCM secret storage keyed from the environment, constant time comparison and recovery code generation. JVM built-ins only; runs on Lucee and Adobe ColdFusion. See docs/0014." output="false">

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

	<cffunction name="getKey" access="private" output="false" returntype="any" hint="Returns an AES SecretKeySpec built from the configured key (security.mfaEncryptKey, set read-only via FARCRY_CONFIG_SECURITY_MFAENCRYPTKEY); throws when missing or malformed">
		<cfset var b64Key = application.fapi.getConfig("security", "mfaEncryptKey", "") />
		<cfset var binKey = "" />

		<cfif not len(trim(b64Key))>
			<cfthrow message="The MFA encryption key is not configured" detail="Multi-factor authentication stores shared secrets encrypted at rest. Set the FARCRY_CONFIG_SECURITY_MFAENCRYPTKEY environment variable to a base64 encoded 128, 192 or 256 bit key." />
		</cfif>

		<cftry>
			<cfset binKey = binaryDecode(trim(b64Key), "base64") />
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


	<!--- secret storage (AES-GCM) --->

	<cffunction name="encryptSecret" access="public" output="false" returntype="string" hint="Encrypts a secret for storage at rest: gcm1.base64(iv).base64(ciphertext)">
		<cfargument name="plaintext" type="string" required="true" />

		<cfset var iv = randomBytes(12) />
		<!--- class handle for the static ENCRYPT_MODE constant + the getInstance factory (instance-field access is not reliable on ACF) --->
		<cfset var cipherClass = createObject("java", "javax.crypto.Cipher") />
		<cfset var oCipher = cipherClass.getInstance("AES/GCM/NoPadding") />

		<cfset oCipher.init(cipherClass.ENCRYPT_MODE, getKey(), createObject("java", "javax.crypto.spec.GCMParameterSpec").init(javacast("int", 128), iv)) />

		<cfreturn "gcm1." & binaryEncode(iv, "base64") & "." & binaryEncode(oCipher.doFinal(charsetDecode(arguments.plaintext, "utf-8")), "base64") />
	</cffunction>

	<cffunction name="decryptSecret" access="public" output="false" returntype="string" hint="Decrypts a secret stored by encryptSecret">
		<cfargument name="sealed" type="string" required="true" />

		<cfset var cipherClass = createObject("java", "javax.crypto.Cipher") />
		<cfset var oCipher = "" />

		<cfif listLen(arguments.sealed, ".") neq 3 or listFirst(arguments.sealed, ".") neq "gcm1">
			<cfthrow message="Unrecognised sealed secret format" />
		</cfif>

		<cfset oCipher = cipherClass.getInstance("AES/GCM/NoPadding") />
		<cfset oCipher.init(cipherClass.DECRYPT_MODE, getKey(), createObject("java", "javax.crypto.spec.GCMParameterSpec").init(javacast("int", 128), binaryDecode(listGetAt(arguments.sealed, 2, "."), "base64"))) />

		<cfreturn charsetEncode(oCipher.doFinal(binaryDecode(listGetAt(arguments.sealed, 3, "."), "base64")), "utf-8") />
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

</cfcomponent>
