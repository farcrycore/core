<cfcomponent displayname="WebAuthn" hint="Server side WebAuthn / FIDO2 second factor verification: registration and assertion, CBOR / COSE parsing (com.upokecenter.cbor) and ES256 / RS256 signature checks via JCA. Public key material only, so nothing here needs the at-rest encryption key. Second factor use: attestation is requested 'none' and is not chain validated. JVM built-ins plus the bundled CBOR jar; runs on Lucee and Adobe ColdFusion." output="false">

	<!--- COSE identifiers (RFC 8152) --->
	<cfset variables.COSE_KTY = 1 />
	<cfset variables.COSE_ALG = 3 />
	<cfset variables.COSE_CRV = -1 />
	<cfset variables.COSE_EC_X = -2 />
	<cfset variables.COSE_EC_Y = -3 />
	<cfset variables.COSE_RSA_N = -1 />
	<cfset variables.COSE_RSA_E = -2 />
	<cfset variables.KTY_EC2 = 2 />
	<cfset variables.KTY_RSA = 3 />
	<cfset variables.ALG_ES256 = -7 />
	<cfset variables.ALG_RS256 = -257 />
	<cfset variables.CRV_P256 = 1 />

	<cffunction name="init" access="public" output="false" returntype="any" hint="Constructor">
		<cfreturn this />
	</cffunction>


	<!--- ============================================================
	  base64url (RFC 4648 section 5, unpadded - the WebAuthn wire form)
	============================================================ --->

	<cffunction name="base64UrlEncode" access="public" output="false" returntype="string" hint="Encodes binary as unpadded url-safe base64">
		<cfargument name="data" type="binary" required="true" />

		<cfset var s = binaryEncode(arguments.data, "base64") />
		<cfset s = replace(s, "+", "-", "all") />
		<cfset s = replace(s, "/", "_", "all") />
		<cfreturn replace(s, "=", "", "all") />
	</cffunction>

	<cffunction name="base64UrlDecode" access="public" output="false" returntype="binary" hint="Decodes unpadded url-safe base64 to binary">
		<cfargument name="data" type="string" required="true" />

		<cfset var s = replace(replace(trim(arguments.data), "-", "+", "all"), "_", "/", "all") />
		<cfset var remainder = len(s) mod 4 />

		<cfif remainder eq 2>
			<cfset s = s & "==" />
		<cfelseif remainder eq 3>
			<cfset s = s & "=" />
		<cfelseif remainder eq 1>
			<cfthrow message="Invalid base64url input" />
		</cfif>

		<cfreturn binaryDecode(s, "base64") />
	</cffunction>


	<!--- ============================================================
	  options for the browser (navigator.credentials create / get)
	============================================================ --->

	<cffunction name="newChallenge" access="public" output="false" returntype="string" hint="A fresh 32 byte challenge as base64url; store it with the pending state and check it at verify">
		<cfreturn base64UrlEncode(randomBytes(32)) />
	</cffunction>

	<cffunction name="buildRegistrationOptions" access="public" output="false" returntype="struct" hint="PublicKeyCredentialCreationOptions (minus the parts the browser fills in), ready to JSON encode for the client">
		<cfargument name="rpId" type="string" required="true" />
		<cfargument name="rpName" type="string" required="true" />
		<cfargument name="userKey" type="string" required="true" hint="Stable subject id; becomes user.id (base64url of its bytes)" />
		<cfargument name="userName" type="string" required="true" />
		<cfargument name="userDisplayName" type="string" required="false" default="#arguments.userName#" />
		<cfargument name="challenge" type="string" required="true" hint="base64url, from newChallenge()" />
		<cfargument name="aExcludeCredentials" type="array" required="false" default="#arraynew(1)#" hint="Array of {id (base64url), transports (array)} already registered" />
		<cfargument name="userVerification" type="string" required="false" default="preferred" />

		<cfset var stOptions = structnew() />
		<cfset var stRp = structnew() />
		<cfset var stUser = structnew() />
		<cfset var stAuthSel = structnew() />

		<!--- bracket / quoted keys so serializeJSON keeps the exact camelCase the WebAuthn API requires on both Lucee and ACF (ACF uppercases identifier-defined struct keys) --->
		<cfset stOptions["challenge"] = arguments.challenge />

		<cfset stRp["id"] = arguments.rpId />
		<cfset stRp["name"] = arguments.rpName />
		<cfset stOptions["rp"] = stRp />

		<cfset stUser["id"] = base64UrlEncode(charsetDecode(arguments.userKey, "utf-8")) />
		<cfset stUser["name"] = arguments.userName />
		<cfset stUser["displayName"] = arguments.userDisplayName />
		<cfset stOptions["user"] = stUser />

		<!--- ES256 first (near universal), RS256 as a fallback for authenticators that only do RSA --->
		<cfset stOptions["pubKeyCredParams"] = [ pubKeyCredParam(variables.ALG_ES256), pubKeyCredParam(variables.ALG_RS256) ] />
		<cfset stOptions["timeout"] = 120000 />
		<cfset stOptions["attestation"] = "none" />
		<cfset stOptions["excludeCredentials"] = mapCredentialDescriptors(arguments.aExcludeCredentials) />

		<cfset stAuthSel["userVerification"] = arguments.userVerification />
		<cfset stAuthSel["residentKey"] = "discouraged" />
		<cfset stAuthSel["requireResidentKey"] = false />
		<cfset stOptions["authenticatorSelection"] = stAuthSel />

		<cfreturn stOptions />
	</cffunction>

	<cffunction name="buildAssertionOptions" access="public" output="false" returntype="struct" hint="PublicKeyCredentialRequestOptions, ready to JSON encode for the client">
		<cfargument name="rpId" type="string" required="true" />
		<cfargument name="challenge" type="string" required="true" hint="base64url, from newChallenge()" />
		<cfargument name="aAllowCredentials" type="array" required="false" default="#arraynew(1)#" hint="Array of {id (base64url), transports (array)}" />
		<cfargument name="userVerification" type="string" required="false" default="preferred" />

		<cfset var stOptions = structnew() />

		<!--- bracket / quoted keys: keep exact case for the WebAuthn API on both engines --->
		<cfset stOptions["challenge"] = arguments.challenge />
		<cfset stOptions["rpId"] = arguments.rpId />
		<cfset stOptions["timeout"] = 120000 />
		<cfset stOptions["userVerification"] = arguments.userVerification />
		<cfset stOptions["allowCredentials"] = mapCredentialDescriptors(arguments.aAllowCredentials) />

		<cfreturn stOptions />
	</cffunction>

	<cffunction name="mapCredentialDescriptors" access="private" output="false" returntype="array" hint="Shapes stored {id, transports} into PublicKeyCredentialDescriptor entries">
		<cfargument name="aCredentials" type="array" required="true" />

		<cfset var aResult = arraynew(1) />
		<cfset var stCred = "" />
		<cfset var stDescriptor = "" />

		<cfloop array="#arguments.aCredentials#" index="stCred">
			<cfset stDescriptor = structnew() />
			<cfset stDescriptor["type"] = "public-key" />
			<cfset stDescriptor["id"] = stCred.id />
			<cfif structKeyExists(stCred, "transports") and isArray(stCred.transports) and arrayLen(stCred.transports)>
				<cfset stDescriptor["transports"] = stCred.transports />
			</cfif>
			<cfset arrayAppend(aResult, stDescriptor) />
		</cfloop>

		<cfreturn aResult />
	</cffunction>

	<cffunction name="pubKeyCredParam" access="private" output="false" returntype="struct" hint="A PublicKeyCredentialParameters entry with case-preserved keys">
		<cfargument name="alg" type="numeric" required="true" />

		<cfset var st = structnew() />
		<cfset st["type"] = "public-key" />
		<cfset st["alg"] = arguments.alg />
		<cfreturn st />
	</cffunction>


	<!--- ============================================================
	  registration verification (navigator.credentials.create)
	============================================================ --->

	<cffunction name="verifyRegistration" access="public" output="false" returntype="struct" hint="Verifies a create() response. On success stCredential holds everything to store: credentialId, the public key params, signCount, aaguid.">
		<cfargument name="clientDataJSON" type="string" required="true" hint="base64url" />
		<cfargument name="attestationObject" type="string" required="true" hint="base64url" />
		<cfargument name="expectedChallenge" type="string" required="true" hint="base64url" />
		<cfargument name="aExpectedOrigins" type="array" required="true" />
		<cfargument name="rpId" type="string" required="true" />
		<cfargument name="bRequireUserVerification" type="boolean" required="false" default="false" />

		<cfset var stResult = { verified = false, reason = "", message = "", stCredential = structnew() } />
		<cfset var stClient = structnew() />
		<cfset var attObjBytes = "" />
		<cfset var attObj = "" />
		<cfset var authDataBytes = "" />
		<cfset var stAuth = structnew() />

		<cfset stClient = verifyClientData(clientDataJSON=arguments.clientDataJSON, expectedType="webauthn.create", expectedChallenge=arguments.expectedChallenge, aExpectedOrigins=arguments.aExpectedOrigins) />
		<cfif not stClient.verified>
			<cfset stResult.reason = stClient.reason />
			<cfset stResult.message = stClient.message />
			<cfreturn stResult />
		</cfif>

		<cftry>
			<cfset attObjBytes = base64UrlDecode(arguments.attestationObject) />
			<cfset attObj = getCBOR().DecodeFromBytes(attObjBytes) />

			<cfif not attObj.ContainsKey("authData")>
				<cfset stResult.reason = "malformedAttestation" />
				<cfset stResult.message = "The security key response was not understood." />
				<cfreturn stResult />
			</cfif>

			<cfset authDataBytes = attObj.get("authData").GetByteString() />
			<cfset stAuth = parseAuthData(authDataBytes) />
			<cfcatch>
				<cfset stResult.reason = "malformedAttestation" />
				<cfset stResult.message = "The security key response was not understood." />
				<cfreturn stResult />
			</cfcatch>
		</cftry>

		<!--- bind to our relying party and check user presence / verification flags --->
		<cfif stAuth.rpIdHash neq lcase(binaryEncode(sha256(charsetDecode(arguments.rpId, "utf-8")), "hex"))>
			<cfset stResult.reason = "rpIdMismatch" />
			<cfset stResult.message = "This security key was set up for a different site." />
			<cfreturn stResult />
		</cfif>

		<cfif not stAuth.flags.up>
			<cfset stResult.reason = "userNotPresent" />
			<cfset stResult.message = "The security key did not confirm your presence. Try again." />
			<cfreturn stResult />
		</cfif>

		<cfif arguments.bRequireUserVerification and not stAuth.flags.uv>
			<cfset stResult.reason = "userNotVerified" />
			<cfset stResult.message = "Your security key must verify you (PIN or biometric) to be used here." />
			<cfreturn stResult />
		</cfif>

		<cfif not structKeyExists(stAuth, "stKey")>
			<cfset stResult.reason = "noAttestedKey" />
			<cfset stResult.message = "The security key did not return a credential." />
			<cfreturn stResult />
		</cfif>

		<cfset stResult.stCredential = {
			credentialId = stAuth.credentialId,
			signCount = stAuth.signCount,
			aaguid = stAuth.aaguid,
			keyType = stAuth.stKey.keyType,
			alg = stAuth.stKey.alg
		} />
		<cfset structAppend(stResult.stCredential, stAuth.stKey) />
		<cfset stResult.verified = true />

		<cfreturn stResult />
	</cffunction>


	<!--- ============================================================
	  assertion verification (navigator.credentials.get)
	============================================================ --->

	<cffunction name="verifyAssertion" access="public" output="false" returntype="struct" hint="Verifies a get() response against a stored credential. Returns { verified, reason, message, signCount } - signCount is the new value to persist.">
		<cfargument name="clientDataJSON" type="string" required="true" hint="base64url" />
		<cfargument name="authenticatorData" type="string" required="true" hint="base64url" />
		<cfargument name="signature" type="string" required="true" hint="base64url" />
		<cfargument name="expectedChallenge" type="string" required="true" hint="base64url" />
		<cfargument name="aExpectedOrigins" type="array" required="true" />
		<cfargument name="rpId" type="string" required="true" />
		<cfargument name="stStoredKey" type="struct" required="true" hint="The stored public key params (keyType, alg, x/y or n/e)" />
		<cfargument name="storedSignCount" type="numeric" required="false" default="0" />
		<cfargument name="bRequireUserVerification" type="boolean" required="false" default="false" />

		<cfset var stResult = { verified = false, reason = "", message = "", signCount = arguments.storedSignCount } />
		<cfset var stClient = structnew() />
		<cfset var authDataBytes = "" />
		<cfset var clientDataBytes = "" />
		<cfset var stAuth = structnew() />
		<cfset var signedBytes = "" />
		<cfset var oPublicKey = "" />

		<cfset stClient = verifyClientData(clientDataJSON=arguments.clientDataJSON, expectedType="webauthn.get", expectedChallenge=arguments.expectedChallenge, aExpectedOrigins=arguments.aExpectedOrigins) />
		<cfif not stClient.verified>
			<cfset stResult.reason = stClient.reason />
			<cfset stResult.message = stClient.message />
			<cfreturn stResult />
		</cfif>

		<cftry>
			<cfset authDataBytes = base64UrlDecode(arguments.authenticatorData) />
			<cfset stAuth = parseAuthData(authDataBytes) />
			<cfcatch>
				<cfset stResult.reason = "malformedAssertion" />
				<cfset stResult.message = "The security key response was not understood." />
				<cfreturn stResult />
			</cfcatch>
		</cftry>

		<cfif stAuth.rpIdHash neq lcase(binaryEncode(sha256(charsetDecode(arguments.rpId, "utf-8")), "hex"))>
			<cfset stResult.reason = "rpIdMismatch" />
			<cfset stResult.message = "This security key was set up for a different site." />
			<cfreturn stResult />
		</cfif>

		<cfif not stAuth.flags.up>
			<cfset stResult.reason = "userNotPresent" />
			<cfset stResult.message = "The security key did not confirm your presence. Try again." />
			<cfreturn stResult />
		</cfif>

		<cfif arguments.bRequireUserVerification and not stAuth.flags.uv>
			<cfset stResult.reason = "userNotVerified" />
			<cfset stResult.message = "Your security key must verify you (PIN or biometric) to sign in." />
			<cfreturn stResult />
		</cfif>

		<!--- signed data is authenticatorData || SHA-256(clientDataJSON) --->
		<cfset clientDataBytes = base64UrlDecode(arguments.clientDataJSON) />
		<cfset signedBytes = concatBytes(authDataBytes, sha256(clientDataBytes)) />

		<cftry>
			<cfset oPublicKey = coseKeyToPublicKey(arguments.stStoredKey) />

			<cfif not verifySignature(alg=arguments.stStoredKey.alg, oPublicKey=oPublicKey, signedBytes=signedBytes, signature=base64UrlDecode(arguments.signature))>
				<cfset stResult.reason = "badSignature" />
				<cfset stResult.message = "The code from your security key could not be verified." />
				<cfreturn stResult />
			</cfif>
			<cfcatch>
				<cfset stResult.reason = "badSignature" />
				<cfset stResult.message = "The code from your security key could not be verified." />
				<cfreturn stResult />
			</cfcatch>
		</cftry>

		<!--- cloned-authenticator guard: a counter that fails to advance is suspicious. Authenticators
		      that do not implement a counter always report 0 - only enforce when a counter is in use. --->
		<cfif (stAuth.signCount neq 0 or arguments.storedSignCount neq 0) and stAuth.signCount lte arguments.storedSignCount>
			<cfset stResult.reason = "signCountReuse" />
			<cfset stResult.message = "The security key could not be verified. Please try a different method." />
			<cfreturn stResult />
		</cfif>

		<cfset stResult.signCount = stAuth.signCount />
		<cfset stResult.verified = true />

		<cfreturn stResult />
	</cffunction>


	<!--- ============================================================
	  internal: client data, authenticator data, COSE, signatures
	============================================================ --->

	<cffunction name="verifyClientData" access="private" output="false" returntype="struct" hint="Common clientDataJSON checks: type, challenge (constant time) and origin">
		<cfargument name="clientDataJSON" type="string" required="true" />
		<cfargument name="expectedType" type="string" required="true" />
		<cfargument name="expectedChallenge" type="string" required="true" />
		<cfargument name="aExpectedOrigins" type="array" required="true" />

		<cfset var stResult = { verified = false, reason = "", message = "" } />
		<cfset var stClient = structnew() />
		<cfset var origin = "" />
		<cfset var bOriginOK = false />

		<cftry>
			<cfset stClient = deserializeJSON(charsetEncode(base64UrlDecode(arguments.clientDataJSON), "utf-8")) />
			<cfcatch>
				<cfset stResult.reason = "malformedClientData" />
				<cfset stResult.message = "The security key response was not understood." />
				<cfreturn stResult />
			</cfcatch>
		</cftry>

		<cfif not (structKeyExists(stClient, "type") and stClient.type eq arguments.expectedType)>
			<cfset stResult.reason = "badType" />
			<cfset stResult.message = "The security key response was not understood." />
			<cfreturn stResult />
		</cfif>

		<!--- the browser echoes our challenge back as base64url; compare in constant time --->
		<cfif not (structKeyExists(stClient, "challenge") and constantTimeEquals(stClient.challenge, arguments.expectedChallenge))>
			<cfset stResult.reason = "challengeMismatch" />
			<cfset stResult.message = "Your sign in attempt has expired. Please try again." />
			<cfreturn stResult />
		</cfif>

		<cfif structKeyExists(stClient, "origin")>
			<cfloop array="#arguments.aExpectedOrigins#" index="origin">
				<cfif len(origin) and stClient.origin eq origin>
					<cfset bOriginOK = true />
				</cfif>
			</cfloop>
		</cfif>

		<cfif not bOriginOK>
			<cfset stResult.reason = "originMismatch" />
			<cfset stResult.message = "This security key cannot be used from this address." />
			<cfreturn stResult />
		</cfif>

		<cfset stResult.verified = true />
		<cfreturn stResult />
	</cffunction>

	<cffunction name="parseAuthData" access="private" output="false" returntype="struct" hint="Parses authenticator data. Reads a hex rendering rather than indexing the byte array (consistent across engines). Attested credential data (with the COSE public key) is present only when the AT flag is set - i.e. at registration.">
		<cfargument name="authData" type="any" required="true" hint="binary or java byte[]" />

		<cfset var hex = lcase(binaryEncode(arguments.authData, "hex")) />
		<cfset var stResult = structnew() />
		<cfset var flags = 0 />
		<cfset var cursor = 0 />
		<cfset var credLen = 0 />

		<!--- minimum: rpIdHash(32) + flags(1) + signCount(4) = 37 bytes = 74 hex --->
		<cfif len(hex) lt 74>
			<cfthrow message="Authenticator data is too short" />
		</cfif>

		<cfset stResult.rpIdHash = mid(hex, 1, 64) />
		<cfset flags = inputBaseN(mid(hex, 65, 2), 16) />
		<cfset stResult.flags = {
			up = bitAnd(flags, 1) eq 1,
			uv = bitAnd(flags, 4) eq 4,
			at = bitAnd(flags, 64) eq 64,
			ed = bitAnd(flags, 128) eq 128
		} />
		<cfset stResult.signCount = inputBaseN(mid(hex, 67, 8), 16) />
		<cfset cursor = 75 /><!--- hex position of byte 37 --->

		<cfif stResult.flags.at>
			<!--- aaguid(16) + credentialIdLength(2) = 18 bytes = 36 hex --->
			<cfif len(hex) lt cursor + 35>
				<cfthrow message="Attested credential data is truncated" />
			</cfif>

			<cfset stResult.aaguid = mid(hex, cursor, 32) />
			<cfset cursor = cursor + 32 />
			<cfset credLen = inputBaseN(mid(hex, cursor, 4), 16) />
			<cfset cursor = cursor + 4 />

			<cfif len(hex) lt cursor + (credLen * 2) - 1>
				<cfthrow message="Credential id is truncated" />
			</cfif>

			<cfset stResult.credentialId = base64UrlEncode(binaryDecode(mid(hex, cursor, credLen * 2), "hex")) />
			<cfset cursor = cursor + (credLen * 2) />

			<!--- the remainder is the COSE public key (we request no extensions, so nothing trails it). mid() needs the explicit count - it is required on Adobe ColdFusion. --->
			<cfset stResult.stKey = parseCoseKey(binaryDecode(mid(hex, cursor, len(hex) - cursor + 1), "hex")) />
		</cfif>

		<cfreturn stResult />
	</cffunction>

	<cffunction name="parseCoseKey" access="private" output="false" returntype="struct" hint="Parses a COSE_Key (RFC 8152) into JCA ready params. EC2 (P-256) and RSA supported; x/y/n/e kept as base64url.">
		<cfargument name="keyBytes" type="binary" required="true" />

		<cfset var oKey = getCBOR().DecodeFromBytes(arguments.keyBytes) />
		<cfset var stResult = structnew() />
		<cfset var kty = coseInt(oKey, variables.COSE_KTY) />

		<cfset stResult.alg = coseInt(oKey, variables.COSE_ALG) />

		<cfif kty eq variables.KTY_EC2>
			<cfset stResult.keyType = "EC2" />
			<cfset stResult.crv = coseInt(oKey, variables.COSE_CRV) />
			<cfif stResult.crv neq variables.CRV_P256>
				<cfthrow message="Unsupported elliptic curve (only P-256 is supported)" />
			</cfif>
			<cfset stResult.x = base64UrlEncode(coseBytes(oKey, variables.COSE_EC_X)) />
			<cfset stResult.y = base64UrlEncode(coseBytes(oKey, variables.COSE_EC_Y)) />
		<cfelseif kty eq variables.KTY_RSA>
			<cfset stResult.keyType = "RSA" />
			<cfset stResult.n = base64UrlEncode(coseBytes(oKey, variables.COSE_RSA_N)) />
			<cfset stResult.e = base64UrlEncode(coseBytes(oKey, variables.COSE_RSA_E)) />
		<cfelse>
			<cfthrow message="Unsupported COSE key type" />
		</cfif>

		<cfreturn stResult />
	</cffunction>

	<cffunction name="coseKeyToPublicKey" access="private" output="false" returntype="any" hint="Rebuilds a JCA PublicKey from stored COSE params">
		<cfargument name="stKey" type="struct" required="true" />

		<cfset var oKeyFactory = "" />
		<cfset var oPoint = "" />
		<cfset var oEcParams = "" />
		<cfset var oAP = "" />

		<cfif arguments.stKey.keyType eq "EC2">
			<cfset oPoint = createObject("java", "java.security.spec.ECPoint").init(
				toPositiveBigInteger(base64UrlDecode(arguments.stKey.x)),
				toPositiveBigInteger(base64UrlDecode(arguments.stKey.y))
			) />
			<cfset oAP = createObject("java", "java.security.AlgorithmParameters").getInstance("EC") />
			<cfset oAP.init(createObject("java", "java.security.spec.ECGenParameterSpec").init("secp256r1")) />
			<cfset oEcParams = oAP.getParameterSpec(createObject("java", "java.lang.Class").forName("java.security.spec.ECParameterSpec")) />
			<cfset oKeyFactory = createObject("java", "java.security.KeyFactory").getInstance("EC") />
			<cfreturn oKeyFactory.generatePublic(createObject("java", "java.security.spec.ECPublicKeySpec").init(oPoint, oEcParams)) />
		</cfif>

		<cfif arguments.stKey.keyType eq "RSA">
			<cfset oKeyFactory = createObject("java", "java.security.KeyFactory").getInstance("RSA") />
			<cfreturn oKeyFactory.generatePublic(createObject("java", "java.security.spec.RSAPublicKeySpec").init(
				toPositiveBigInteger(base64UrlDecode(arguments.stKey.n)),
				toPositiveBigInteger(base64UrlDecode(arguments.stKey.e))
			)) />
		</cfif>

		<cfthrow message="Unsupported key type for public key reconstruction" />
	</cffunction>

	<cffunction name="verifySignature" access="private" output="false" returntype="boolean" hint="Verifies a WebAuthn signature. ES256 signatures are ASN.1 DER (r,s) - exactly what JCA SHA256withECDSA expects, so no conversion.">
		<cfargument name="alg" type="numeric" required="true" />
		<cfargument name="oPublicKey" type="any" required="true" />
		<cfargument name="signedBytes" type="binary" required="true" />
		<cfargument name="signature" type="binary" required="true" />

		<cfset var oSig = "" />

		<cfif arguments.alg eq variables.ALG_ES256>
			<cfset oSig = createObject("java", "java.security.Signature").getInstance("SHA256withECDSA") />
		<cfelseif arguments.alg eq variables.ALG_RS256>
			<cfset oSig = createObject("java", "java.security.Signature").getInstance("SHA256withRSA") />
		<cfelse>
			<cfthrow message="Unsupported signature algorithm" />
		</cfif>

		<cfset oSig.initVerify(arguments.oPublicKey) />
		<cfset oSig.update(arguments.signedBytes) />
		<cfreturn oSig.verify(arguments.signature) />
	</cffunction>


	<!--- ============================================================
	  small helpers
	============================================================ --->

	<cffunction name="getCBOR" access="private" output="false" returntype="any" hint="The upokecenter CBOR class handle (bundled jar, auto-loaded from packages/security/crypt)">
		<cfreturn createObject("java", "com.upokecenter.cbor.CBORObject") />
	</cffunction>

	<cffunction name="coseInt" access="private" output="false" returntype="numeric" hint="Reads an integer value from a COSE map by its (possibly negative) integer label">
		<cfargument name="oMap" type="any" required="true" />
		<cfargument name="label" type="numeric" required="true" />

		<cfset var oLabel = getCBOR().FromObject(javacast("int", arguments.label)) />

		<cfif not arguments.oMap.ContainsKey(oLabel)>
			<cfthrow message="COSE key is missing a required field" />
		</cfif>

		<cfreturn arguments.oMap.get(oLabel).AsInt32Value() />
	</cffunction>

	<cffunction name="coseBytes" access="private" output="false" returntype="binary" hint="Reads a byte string value from a COSE map by its integer label">
		<cfargument name="oMap" type="any" required="true" />
		<cfargument name="label" type="numeric" required="true" />

		<cfset var oLabel = getCBOR().FromObject(javacast("int", arguments.label)) />
		<cfset var hexOut = "" />

		<cfif not arguments.oMap.ContainsKey(oLabel)>
			<cfthrow message="COSE key is missing a required field" />
		</cfif>

		<!--- normalise the java byte[] through a hex render so the return is a CFML binary on both engines --->
		<cfset hexOut = binaryEncode(arguments.oMap.get(oLabel).GetByteString(), "hex") />
		<cfreturn binaryDecode(hexOut, "hex") />
	</cffunction>

	<cffunction name="toPositiveBigInteger" access="private" output="false" returntype="any" hint="An unsigned BigInteger from big-endian bytes (signum 1 so a high bit is not read as negative)">
		<cfargument name="data" type="binary" required="true" />

		<cfreturn createObject("java", "java.math.BigInteger").init(javacast("int", 1), arguments.data) />
	</cffunction>

	<cffunction name="sha256" access="private" output="false" returntype="binary" hint="SHA-256 digest">
		<cfargument name="data" type="binary" required="true" />

		<cfset var hexOut = binaryEncode(createObject("java", "java.security.MessageDigest").getInstance("SHA-256").digest(arguments.data), "hex") />
		<cfreturn binaryDecode(hexOut, "hex") />
	</cffunction>

	<cffunction name="concatBytes" access="private" output="false" returntype="binary" hint="Concatenates two byte sequences via a hex render (engine safe)">
		<cfargument name="a" type="any" required="true" />
		<cfargument name="b" type="any" required="true" />

		<cfreturn binaryDecode(binaryEncode(arguments.a, "hex") & binaryEncode(arguments.b, "hex"), "hex") />
	</cffunction>

	<cffunction name="constantTimeEquals" access="private" output="false" returntype="boolean" hint="Constant time string comparison">
		<cfargument name="a" type="string" required="true" />
		<cfargument name="b" type="string" required="true" />

		<cfreturn createObject("java", "java.security.MessageDigest").isEqual(charsetDecode(arguments.a, "utf-8"), charsetDecode(arguments.b, "utf-8")) />
	</cffunction>

	<cffunction name="randomBytes" access="private" output="false" returntype="binary" hint="n cryptographically random bytes, built through a hex string (engine safe)">
		<cfargument name="n" type="numeric" required="true" />

		<cfset var oRandom = createObject("java", "java.security.SecureRandom").init() />
		<cfset var hexOut = "" />
		<cfset var i = 0 />

		<cfloop from="1" to="#arguments.n#" index="i">
			<cfset hexOut = hexOut & right("0" & formatBaseN(oRandom.nextInt(javacast("int", 256)), 16), 2) />
		</cfloop>

		<cfreturn binaryDecode(hexOut, "hex") />
	</cffunction>


	<!--- ============================================================
	  self test: proves the parse + verify path and the jar load on the
	  live engine, without needing a physical authenticator. A real EC
	  keypair signs a synthetic assertion (positive + tamper cases); a
	  hand-assembled COSE key / attestation object exercises the decode
	  path that real authenticators drive. Device interop is the live spike.
	============================================================ --->

	<cffunction name="webAuthnSelfTest" access="public" output="false" returntype="struct" hint="Runs registration + assertion round-trips against a generated keypair; returns { pass, results }">
		<cfset var stOut = { pass = true, results = arraynew(1) } />
		<cfset var rpId = "example.test" />
		<cfset var aOrigins = ["https://example.test"] />
		<cfset var challenge = base64UrlEncode(charsetDecode("selftest-challenge-0123456789", "utf-8")) />
		<cfset var oKeyPair = "" />
		<cfset var oPub = "" />
		<cfset var xHex = "" />
		<cfset var yHex = "" />
		<cfset var stKey = structnew() />
		<cfset var rpIdHashHex = "" />
		<cfset var clientJSON = "" />
		<cfset var clientB64 = "" />
		<cfset var authAssertHex = "" />
		<cfset var signedHex = "" />
		<cfset var oSig = "" />
		<cfset var sigB64 = "" />
		<cfset var stVerify = structnew() />
		<cfset var coseHex = "" />
		<cfset var credIdHex = "aabbccddeeff00112233445566778899" />
		<cfset var authRegHex = "" />
		<cfset var attHex = "" />
		<cfset var authLenHex = "" />
		<cfset var stReg = structnew() />
		<cfset var clientRegJSON = "" />

		<cftry>
			<!--- a real P-256 keypair --->
			<cfset oKeyPair = generateTestEcKeyPair() />
			<cfset oPub = oKeyPair.getPublic() />
			<cfset xHex = leftPad(oPub.getW().getAffineX().toString(javacast("int", 16)), 64) />
			<cfset yHex = leftPad(oPub.getW().getAffineY().toString(javacast("int", 16)), 64) />
			<cfset stKey = { keyType = "EC2", alg = variables.ALG_ES256, crv = variables.CRV_P256, x = base64UrlEncode(binaryDecode(xHex, "hex")), y = base64UrlEncode(binaryDecode(yHex, "hex")) } />
			<cfset rpIdHashHex = lcase(binaryEncode(sha256(charsetDecode(rpId, "utf-8")), "hex")) />

			<!--- ---- assertion: sign a synthetic authenticatorData + clientDataHash ---- --->
			<cfset clientRegJSON = '{"type":"webauthn.get","challenge":"#challenge#","origin":"https://example.test"}' />
			<cfset clientB64 = base64UrlEncode(charsetDecode(clientRegJSON, "utf-8")) />
			<cfset authAssertHex = rpIdHashHex & "01" & "00000005" /><!--- UP flag, signCount 5 --->
			<cfset signedHex = authAssertHex & lcase(binaryEncode(sha256(base64UrlDecode(clientB64)), "hex")) />
			<cfset oSig = createObject("java", "java.security.Signature").getInstance("SHA256withECDSA") />
			<cfset oSig.initSign(oKeyPair.getPrivate()) />
			<cfset oSig.update(binaryDecode(signedHex, "hex")) />
			<cfset sigB64 = base64UrlEncode(binaryDecode(binaryEncode(oSig.sign(), "hex"), "hex")) />

			<cfset stVerify = verifyAssertion(clientDataJSON=clientB64, authenticatorData=base64UrlEncode(binaryDecode(authAssertHex, "hex")), signature=sigB64, expectedChallenge=challenge, aExpectedOrigins=aOrigins, rpId=rpId, stStoredKey=stKey, storedSignCount=1) />
			<cfset record(stOut, "assertion valid", stVerify.verified and stVerify.signCount eq 5, stVerify.reason) />

			<!--- tamper: wrong challenge --->
			<cfset stVerify = verifyAssertion(clientDataJSON=clientB64, authenticatorData=base64UrlEncode(binaryDecode(authAssertHex, "hex")), signature=sigB64, expectedChallenge=base64UrlEncode(charsetDecode("a-different-challenge-value-000", "utf-8")), aExpectedOrigins=aOrigins, rpId=rpId, stStoredKey=stKey, storedSignCount=1) />
			<cfset record(stOut, "assertion rejects wrong challenge", not stVerify.verified and stVerify.reason eq "challengeMismatch", stVerify.reason) />

			<!--- tamper: wrong origin --->
			<cfset stVerify = verifyAssertion(clientDataJSON=clientB64, authenticatorData=base64UrlEncode(binaryDecode(authAssertHex, "hex")), signature=sigB64, expectedChallenge=challenge, aExpectedOrigins=["https://evil.test"], rpId=rpId, stStoredKey=stKey, storedSignCount=1) />
			<cfset record(stOut, "assertion rejects wrong origin", not stVerify.verified and stVerify.reason eq "originMismatch", stVerify.reason) />

			<!--- tamper: wrong rpId --->
			<cfset stVerify = verifyAssertion(clientDataJSON=clientB64, authenticatorData=base64UrlEncode(binaryDecode(authAssertHex, "hex")), signature=sigB64, expectedChallenge=challenge, aExpectedOrigins=aOrigins, rpId="attacker.test", stStoredKey=stKey, storedSignCount=1) />
			<cfset record(stOut, "assertion rejects wrong rpId", not stVerify.verified and stVerify.reason eq "rpIdMismatch", stVerify.reason) />

			<!--- tamper: flipped signature byte --->
			<cfset stVerify = verifyAssertion(clientDataJSON=clientB64, authenticatorData=base64UrlEncode(binaryDecode(authAssertHex, "hex")), signature=flipLastChar(sigB64), expectedChallenge=challenge, aExpectedOrigins=aOrigins, rpId=rpId, stStoredKey=stKey, storedSignCount=1) />
			<cfset record(stOut, "assertion rejects bad signature", not stVerify.verified and stVerify.reason eq "badSignature", stVerify.reason) />

			<!--- replay: signCount not advanced (5 <= stored 5) --->
			<cfset stVerify = verifyAssertion(clientDataJSON=clientB64, authenticatorData=base64UrlEncode(binaryDecode(authAssertHex, "hex")), signature=sigB64, expectedChallenge=challenge, aExpectedOrigins=aOrigins, rpId=rpId, stStoredKey=stKey, storedSignCount=5) />
			<cfset record(stOut, "assertion rejects counter reuse", not stVerify.verified and stVerify.reason eq "signCountReuse", stVerify.reason) />

			<!--- ---- registration: decode a hand-assembled attestation object ---- --->
			<cfset coseHex = "a5" & "0102" & "0326" & "2001" & "215820" & xHex & "225820" & yHex /><!--- COSE_Key EC2 P-256 --->
			<cfset authRegHex = rpIdHashHex & "41" & "00000000" & "00000000000000000000000000000000" /><!--- rpIdHash + UP|AT flags + signCount 0 + aaguid --->
			<cfset authRegHex = authRegHex & right("000" & formatBaseN(len(credIdHex) / 2, 16), 4) & credIdHex & coseHex /><!--- credIdLen + credId + COSE key --->
			<cfset authLenHex = right("0" & formatBaseN(len(authRegHex) / 2, 16), 2) /><!--- 1 byte length (< 256) --->
			<cfset attHex = "a3" & "63666d74" & "646e6f6e65" & "6761747453746d74" & "a0" & "686175746844617461" & "58" & authLenHex & authRegHex /><!--- {fmt:none, attStmt:{}, authData:bytes} --->
			<cfset clientRegJSON = '{"type":"webauthn.create","challenge":"#challenge#","origin":"https://example.test"}' />

			<cfset stReg = verifyRegistration(clientDataJSON=base64UrlEncode(charsetDecode(clientRegJSON, "utf-8")), attestationObject=base64UrlEncode(binaryDecode(attHex, "hex")), expectedChallenge=challenge, aExpectedOrigins=aOrigins, rpId=rpId) />
			<cfset record(stOut, "registration valid + key extracted", stReg.verified and stReg.stCredential.credentialId eq base64UrlEncode(binaryDecode(credIdHex, "hex")) and stReg.stCredential.x eq stKey.x and stReg.stCredential.y eq stKey.y, stReg.reason) />

			<!--- the extracted key verifies the earlier signature: proves decode -> store -> verify is consistent --->
			<cfset stVerify = verifyAssertion(clientDataJSON=clientB64, authenticatorData=base64UrlEncode(binaryDecode(authAssertHex, "hex")), signature=sigB64, expectedChallenge=challenge, aExpectedOrigins=aOrigins, rpId=rpId, stStoredKey=stReg.stCredential, storedSignCount=1) />
			<cfset record(stOut, "extracted key verifies assertion", stVerify.verified, stVerify.reason) />

			<cfcatch>
				<cfset record(stOut, "self test threw", false, cfcatch.message & " :: " & cfcatch.detail) />
			</cfcatch>
		</cftry>

		<cfreturn stOut />
	</cffunction>

	<cffunction name="generateTestEcKeyPair" access="private" output="false" returntype="any" hint="A P-256 keypair for the self test">
		<cfset var oKpg = createObject("java", "java.security.KeyPairGenerator").getInstance("EC") />
		<cfset oKpg.initialize(createObject("java", "java.security.spec.ECGenParameterSpec").init("secp256r1")) />
		<cfreturn oKpg.generateKeyPair() />
	</cffunction>

	<cffunction name="leftPad" access="private" output="false" returntype="string" hint="Left pads a hex string to a fixed width">
		<cfargument name="hex" type="string" required="true" />
		<cfargument name="width" type="numeric" required="true" />

		<cfreturn right(repeatString("0", arguments.width) & arguments.hex, arguments.width) />
	</cffunction>

	<cffunction name="flipLastChar" access="private" output="false" returntype="string" hint="Flips the last base64url char so a signature no longer validates">
		<cfargument name="s" type="string" required="true" />

		<cfset var last = right(arguments.s, 1) />
		<cfreturn left(arguments.s, len(arguments.s) - 1) & (last eq "A" ? "B" : "A") />
	</cffunction>

	<cffunction name="record" access="private" output="false" returntype="void" hint="Appends a self test result">
		<cfargument name="stOut" type="struct" required="true" />
		<cfargument name="name" type="string" required="true" />
		<cfargument name="pass" type="boolean" required="true" />
		<cfargument name="detail" type="string" required="false" default="" />

		<cfset arrayAppend(arguments.stOut.results, { name = arguments.name, pass = arguments.pass, detail = arguments.detail }) />
		<cfif not arguments.pass>
			<cfset arguments.stOut.pass = false />
		</cfif>
	</cffunction>

</cfcomponent>
