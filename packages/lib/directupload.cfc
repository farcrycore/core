<cfcomponent displayname="Direct Upload" hint="Server held authorization for direct browser-to-bucket uploads. A sign request describes one exact object key and the context it was issued for, signs that description, and hands it back as an opaque token; a finalize request presents the token, the signature is verified, and the accepted value is read out of the verified description rather than off the request. Nothing is stored: the signature is what makes the description the server's word, so an authorization needs no state on any node and resolves the same on all of them. It carries the actor it was issued to and the record a finalize may create, so it does not resolve for another user and a finalize that arrives twice writes the same record rather than a second one." output="false" persistent="false">

	<cfset this.defaultGraceMinutes = 10 />
	<cfset this.defaultPolicyMinutes = 60 />

	<cffunction name="init" access="public" output="false" returntype="any">
		<cfreturn this />
	</cffunction>


	<!--- ------------------------------------------------------------------
	      Upload authorizations
	      ------------------------------------------------------------------ --->

	<cffunction name="issue" access="public" output="false" returntype="string" hint="Signs an upload authorization and returns it as an opaque token. bind holds the server resolved facts a finalize request must re-present exactly; grant holds what the authorization confers. Both travel inside the token: the signature is what stops the browser editing either, which is the same guarantee holding them server side gave and needs nothing stored. bind.location sizes the expiry against that location's signing policy window. The token also names the record a finalize may create, so two finalizes of one upload write one record.">
		<cfargument name="bind" type="struct" required="true" />
		<cfargument name="grant" type="struct" required="true" />

		<cfset var location = structKeyExists(arguments.bind,"location") ? arguments.bind.location : "" />
		<cfset var minutes = getPolicyMinutes(location) + getNumericSetting("graceMinutes",this.defaultGraceMinutes,0) />

		<cfreturn signToken({
			"bind" = arguments.bind,
			"grant" = arguments.grant,
			"actor" = getActor(),
			"recordid" = application.fapi.getUUID(),
			"expires" = getTickCount() + (minutes * 60000)
		}) />
	</cffunction>


	<cffunction name="claim" access="public" output="false" returntype="struct" hint="Verifies a presented token and returns what it authorises. Returns { status, bind, grant, recordid } where status is ok, notfound, expired or mismatch. Only status ok authorises side effects. notfound covers absent, malformed and unsigned tokens alike - a token that does not verify describes nothing, so there is no distinction to draw.">
		<cfargument name="uploadid" type="string" required="false" default="" />
		<cfargument name="expect" type="struct" required="true" />

		<cfset var stResult = { "status" = "notfound", "bind" = structnew(), "grant" = structnew(), "recordid" = "" } />
		<cfset var stToken = verifyToken(arguments.uploadid) />

		<!--- a token that does not verify keeps the notfound this started as and falls
		      through to the same reporting every other refusal goes through. returning here
		      instead would make the commonest refusal the only one an operator cannot see --->
		<cfif stToken.bValid>
			<cfif getTickCount() gt val(stToken.payload.expires)>
				<cfset stResult["status"] = "expired" />

			<cfelseif not sameActor(stToken.payload.actor) or not sameContext(stToken.payload.bind, arguments.expect)>
				<cfset stResult["status"] = "mismatch" />

			<cfelse>
				<cfset stResult["status"] = "ok" />
				<cfset stResult["bind"] = stToken.payload.bind />
				<cfset stResult["grant"] = stToken.payload.grant />
				<cfset stResult["recordid"] = stToken.payload.recordid />
			</cfif>
		</cfif>

		<!--- a refused finalize is the failure an operator gets asked about, and the message
		      the uploader shows deliberately does not say which of the reasons applied.
		      whether a token was presented at all separates a client that never received one
		      from one presenting a token this server will not accept. the token itself is not
		      logged - it is a live capability for as long as it has left to run --->
		<cfif stResult.status neq "ok">
			<cfset application.fapi.logEvent("cdn", "warning", "direct upload finalize refused", {
				reason = stResult.status,
				bTokenPresented = (len(trim(arguments.uploadid)) gt 0),
				typename = structKeyExists(arguments.expect,"typename") ? arguments.expect.typename : "",
				property = structKeyExists(arguments.expect,"property") ? arguments.expect.property : "",
				surface = structKeyExists(arguments.expect,"surface") ? arguments.expect.surface : ""
			}) />
		</cfif>

		<cfreturn stResult />
	</cffunction>


	<cffunction name="claimAndVerify" access="public" output="false" returntype="struct" hint="The whole finalize precondition in one call: verifies the token, takes the accepted value out of it, re-asserts the value's shape, and confirms the object is in the bucket within the size the server signed for - all before the caller has any side effect. Returns { status, value, recordid, message }: ok means proceed with value and create at recordid, failed means return message and do nothing. Every direct upload surface goes through this, so the sequence cannot drift between them.">
		<cfargument name="uploadid" type="string" required="false" default="" />
		<cfargument name="expect" type="struct" required="true" hint="the context this surface resolved for the finalize request, compared against the token" />
		<cfargument name="clientValue" type="string" required="false" default="" hint="the value the request echoed back; compared as a consistency check and otherwise ignored" />
		<cfargument name="noun" type="string" required="false" default="file" hint="what to call the object in a user facing message" />

		<cfset var stClaim = claim(uploadid=arguments.uploadid, expect=arguments.expect) />
		<cfset var stResult = { "status" = "failed", "value" = "", "recordid" = "", "message" = "" } />
		<cfset var location = "" />
		<cfset var value = "" />
		<cfset var maxsize = 0 />

		<cfif stClaim.status neq "ok">
			<cfset stResult["message"] = statusMessage(stClaim.status) />
			<cfreturn stResult />
		</cfif>

		<!--- everything from here is read out of the verified token, never off the request --->
		<cfset location = stClaim.bind.location />
		<cfset value = stClaim.grant.value />
		<cfset maxsize = val(stClaim.grant.maxsize) />

		<!--- containment asserted at the point of use, not only at the point of issue --->
		<cfset application.fc.lib.cdn.validateDirectUploadPath(value) />

		<cfif len(arguments.clientValue) and compare(arguments.clientValue,value) neq 0>
			<cfset stResult["message"] = statusMessage("mismatch") />
			<cfreturn stResult />
		</cfif>

		<!--- the bucket enforces the policy for an object that arrived through that POST.
		      the finalizer must not assume one did, so it re-establishes both facts itself --->
		<cfif not application.fc.lib.cdn.ioFileExists(location=location, file=value)>
			<cfset stResult["message"] = "Uploaded #arguments.noun# could not be found" />
			<cfreturn stResult />
		</cfif>
		<cfif maxsize gt 0 and application.fc.lib.cdn.ioGetFileSize(location=location, file=value) gt maxsize>
			<cfset stResult["message"] = "Uploaded #arguments.noun# is not within the file size limit of #application.fapi.humanFileSize(maxsize)#" />
			<cfreturn stResult />
		</cfif>

		<cfset stResult["status"] = "ok" />
		<cfset stResult["value"] = value />
		<cfset stResult["recordid"] = stClaim.recordid />

		<cfreturn stResult />
	</cffunction>


	<cffunction name="statusMessage" access="public" output="false" returntype="string" hint="The client facing message for a claim status. One wording across all four upload surfaces, so a caller sees the same failure whichever field it came from.">
		<cfargument name="status" type="string" required="true" />

		<cfswitch expression="#arguments.status#">
			<cfcase value="expired">
				<cfreturn "This upload took too long to complete. Upload the file again." />
			</cfcase>
			<cfdefaultcase>
				<!--- one wording for a token that will not verify and for one that verifies
				      against a context this request does not present, so a caller learns that
				      the upload was refused and not which of the two it was --->
				<cfreturn "Upload authorization not found or already used" />
			</cfdefaultcase>
		</cfswitch>
	</cffunction>


	<!--- ------------------------------------------------------------------
	      Permissions
	      ------------------------------------------------------------------ --->

	<cffunction name="checkUploadPermission" access="public" output="false" returntype="boolean" hint="The permission for the content operation an upload performs, expressed in the existing security semantics: Edit on the type when the record already exists, Create on the type when the upload is making one. joinTypename is the type an upload additionally creates a record of (arrayupload) and is required as well as the target permission when supplied. Type scoped by design - see the note below before adding an object scoped check.">
		<cfargument name="typename" type="string" required="true" hint="server resolved typename of the object being uploaded against" />
		<cfargument name="objectid" type="string" required="false" default="" hint="empty, or an id that is new or session only, means the operation is a create" />
		<cfargument name="joinTypename" type="string" required="false" default="" hint="type a joined record is created in, checked for Create" />

		<cfif not len(arguments.typename)>
			<cfreturn false />
		</cfif>

		<cfif len(arguments.joinTypename) and not application.security.checkPermission(permission="Create", type=arguments.joinTypename)>
			<cfreturn false />
		</cfif>

		<!--- Type scoped, both arms. checkPermission with a type resolves <typename><permission>
		      and falls back to generic<permission>, then reads the role's right with a barnacle
		      override against that type's farCoapi object - which is the content type permission
		      model, and is the level an upload belongs at.

		      Deliberately NOT also checking with objectid=. That form asks a different question:
		      it consults only object attached barnacles, the site tree and webtop navigation
		      model, and it is not what gates editing elsewhere - the object admin's live path
		      (objectadmin.cfc#getBasePermissions) is type scoped too. Adding it would be
		      stricter than the form the user would otherwise edit the record through, and on a
		      type where the bare permission is related to that type it would deny anyone
		      without an explicit per object grant. A project that genuinely wants per object
		      upload rules overrides this library. --->
		<cfif isPersisted(typename=arguments.typename, objectid=arguments.objectid)>
			<cfreturn application.security.checkPermission(permission="Edit", type=arguments.typename) />
		</cfif>

		<cfreturn application.security.checkPermission(permission="Create", type=arguments.typename) />
	</cffunction>


	<cffunction name="isPersisted" access="private" output="false" returntype="boolean" hint="True when the id names a record that exists in the database. isPersistedObject bypasses the session temp store and the object broker, so a session only object reports false and the upload against it is treated as a create.">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="objectid" type="string" required="false" default="" />

		<cfif not len(arguments.objectid) or not structKeyExists(application.stCOAPI,arguments.typename)>
			<cfreturn false />
		</cfif>

		<cftry>
			<cfreturn application.fapi.getContentType(arguments.typename).isPersistedObject(objectid=arguments.objectid) />

			<cfcatch type="any">
				<!--- a malformed id names nothing, so there is no record to edit --->
				<cfreturn false />
			</cfcatch>
		</cftry>
	</cffunction>


	<!--- ------------------------------------------------------------------
	      Internals
	      ------------------------------------------------------------------ --->

	<cffunction name="signToken" access="private" output="false" returntype="string" hint="Renders an authorization as base64url payload plus a keyed digest of that payload. The digest covers the encoded form rather than the struct, so verification never has to reproduce a serialization byte for byte to agree.">
		<cfargument name="payload" type="struct" required="true" />

		<cfset var encoded = toBase64Url(serializeJSON(arguments.payload)) />

		<cfreturn encoded & "." & hmac(encoded, getSigningKey(), "HMACSHA256") />
	</cffunction>


	<cffunction name="verifyToken" access="private" output="false" returntype="struct" hint="Returns { bValid, payload }. bValid is true only for a token this server signed and whose payload still reads as an authorization; a token that is absent, misshapen, re-signed or edited is simply not valid, with no distinction drawn between those. Nothing in the payload is trusted until this has passed.">
		<cfargument name="token" type="string" required="true" />

		<cfset var stResult = { "bValid" = false, "payload" = structnew() } />
		<cfset var token = trim(arguments.token) />
		<cfset var encoded = "" />
		<cfset var presented = "" />
		<cfset var expected = "" />
		<cfset var stPayload = "" />

		<cfif not len(token) or listlen(token,".") neq 2>
			<cfreturn stResult />
		</cfif>

		<cfset encoded = listfirst(token,".") />
		<cfset presented = listlast(token,".") />

		<cftry>
			<cfset expected = hmac(encoded, getSigningKey(), "HMACSHA256") />

			<!--- compared as digests of the two strings rather than the strings themselves, so
			      how soon they differ is not observable in how long the comparison takes --->
			<cfif compare(hash(presented,"SHA-256"), hash(expected,"SHA-256")) neq 0>
				<cfreturn stResult />
			</cfif>

			<cfset stPayload = deserializeJSON(fromBase64Url(encoded)) />

			<!--- a payload that verifies but does not carry the parts an authorization is made
			      of cannot be acted on, so it is refused here rather than further in --->
			<cfif not isStruct(stPayload)
					or not structKeyExists(stPayload,"bind") or not isStruct(stPayload.bind)
					or not structKeyExists(stPayload,"grant") or not isStruct(stPayload.grant)
					or not structKeyExists(stPayload,"actor") or not isStruct(stPayload.actor)
					or not structKeyExists(stPayload,"recordid")
					or not structKeyExists(stPayload,"expires") or not isnumeric(stPayload.expires)>
				<cfreturn stResult />
			</cfif>

			<cfset stResult["bValid"] = true />
			<cfset stResult["payload"] = stPayload />

			<cfcatch type="any">
				<!--- an unreadable token names nothing --->
			</cfcatch>
		</cftry>

		<cfreturn stResult />
	</cffunction>


	<cffunction name="getSigningKey" access="private" output="false" returntype="string" hint="The key authorizations are signed with. Held in configuration so every node answering a finalize signs and verifies with the same one - the config form generates it on first use, and FARCRY_CONFIG_DIRECTUPLOAD_SIGNINGKEY overrides it for a deployment that would rather it did not sit in the database. Throws when it is empty: an unsigned authorization is one anyone could write, so this fails rather than issuing something that only looks signed.">
		<cfset var key = getSetting("signingKey","") />

		<cfif not isSimpleValue(key) or not len(trim(key))>
			<cfset application.fapi.throw(message="Direct uploads have no signing key configured. Set the Upload Signing Key in the CDN Direct Upload Configuration.",type="uploaderror") />
		</cfif>

		<cfreturn trim(key) />
	</cffunction>


	<cffunction name="toBase64Url" access="private" output="false" returntype="string" hint="base64url of a UTF-8 string: the two characters standard base64 spends on + and / are the two a URL reads as something else, and the padding carries no information. Encoded through the charset explicitly so a payload is the same bytes whatever an engine's default happens to be.">
		<cfargument name="text" type="string" required="true" />

		<cfset var b64 = binaryEncode(charsetDecode(arguments.text,"utf-8"),"base64") />

		<cfreturn replace(replace(replace(b64,"+","-","all"),"/","_","all"),"=","","all") />
	</cffunction>


	<cffunction name="fromBase64Url" access="private" output="false" returntype="string" hint="Reverses toBase64Url, restoring the padding base64 decoding needs.">
		<cfargument name="encoded" type="string" required="true" />

		<cfset var b64 = replace(replace(arguments.encoded,"-","+","all"),"_","/","all") />

		<cfloop condition="len(b64) mod 4 neq 0">
			<cfset b64 = b64 & "=" />
		</cfloop>

		<cfreturn charsetEncode(binaryDecode(b64,"base64"),"utf-8") />
	</cffunction>


	<cffunction name="getActor" access="private" output="false" returntype="struct" hint="The authenticated user an authorization is issued to. A stable per directory user key is not exposed at request time, so identity is the login userid plus the user directory, with the profile record id when there is one.">
		<cfset var stActor = { "userid" = application.security.getCurrentUserID(), "userdirectory" = "", "profileid" = "" } />

		<cfif structKeyExists(session,"dmProfile")>
			<cfif structKeyExists(session.dmProfile,"userdirectory")>
				<cfset stActor["userdirectory"] = session.dmProfile.userdirectory />
			</cfif>
			<cfif structKeyExists(session.dmProfile,"objectid")>
				<cfset stActor["profileid"] = session.dmProfile.objectid />
			</cfif>
		</cfif>

		<cfreturn stActor />
	</cffunction>


	<cffunction name="sameActor" access="private" output="false" returntype="boolean" hint="True when the current request's authenticated user is the one the authorization was issued to.">
		<cfargument name="actor" type="struct" required="true" />

		<cfreturn sameContext(arguments.actor, getActor()) />
	</cffunction>


	<cffunction name="sameContext" access="private" output="false" returntype="boolean" hint="True when every key the record stored is present in what was presented and compares equal. Presenting extra keys is allowed; omitting or changing a stored one is not.">
		<cfargument name="stored" type="struct" required="true" />
		<cfargument name="presented" type="struct" required="true" />

		<cfset var key = "" />

		<cfloop collection="#arguments.stored#" item="key">
			<cfif not structKeyExists(arguments.presented,key)>
				<cfreturn false />
			</cfif>
			<cfif not isSimpleValue(arguments.stored[key]) or not isSimpleValue(arguments.presented[key])>
				<cfreturn false />
			</cfif>
			<!--- these are identifiers - typenames, property names, ids, locations - so the
			      comparison is case insensitive, matching how the rest of the framework
			      treats them and avoiding a spurious mismatch on casing alone --->
			<cfif compareNoCase(trim(arguments.stored[key]), trim(arguments.presented[key])) neq 0>
				<cfreturn false />
			</cfif>
		</cfloop>

		<cfreturn true />
	</cffunction>


	<cffunction name="getPolicyMinutes" access="private" output="false" returntype="numeric" hint="The location's signing policy window in minutes, so an authorization expires alongside the capability the bucket already enforces rather than on an unrelated clock.">
		<cfargument name="location" type="string" required="true" />

		<cfset var stLocation = "" />

		<cfif not len(arguments.location)>
			<cfreturn this.defaultPolicyMinutes />
		</cfif>

		<cftry>
			<cfset stLocation = application.fc.lib.cdn.getLocation(arguments.location) />
			<!--- the same window the signer put in the policy, so the two expire together --->
			<cfif structKeyExists(stLocation,"uploadExpiry") and isnumeric(stLocation.uploadExpiry) and val(stLocation.uploadExpiry) gt 0>
				<cfreturn val(stLocation.uploadExpiry) />
			</cfif>

			<cfcatch type="any">
				<!--- an unknown location gets the same window the signer defaults to --->
			</cfcatch>
		</cftry>

		<cfreturn this.defaultPolicyMinutes />
	</cffunction>


	<cffunction name="getNumericSetting" access="private" output="false" returntype="numeric" hint="A configured numeric setting, normalized by one rule for all of them: a value that is not a number - which includes never configured and saved blank - or that falls below this setting's minimum is replaced by the shipped default. Keeps a misconfigured value from taking the feature offline or from expiring an authorization before the policy it describes.">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="default" type="numeric" required="true" />
		<cfargument name="minimum" type="numeric" required="true" />

		<cfset var configured = getSetting(arguments.name, arguments.default) />

		<cfif not isnumeric(configured) or val(configured) lt arguments.minimum>
			<cfreturn arguments.default />
		</cfif>

		<cfreturn val(configured) />
	</cffunction>


	<cffunction name="getSetting" access="private" output="false" returntype="any" hint="Reads a direct upload config value, falling back to the shipped default before the config form is available.">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="default" type="any" required="true" />

		<cftry>
			<cfreturn application.fapi.getConfig("directupload", arguments.name, arguments.default) />

			<cfcatch type="any">
				<cfreturn arguments.default />
			</cfcatch>
		</cftry>
	</cffunction>


	<!--- ------------------------------------------------------------------
	      Self test
	      ------------------------------------------------------------------ --->

	<cffunction name="authorizationSelfTest" access="public" output="false" returntype="struct" hint="Exercises what an authorization rests on, in process and against no stored state: a token this server signed verifies and reports what it granted, and one that is absent, edited, re-signed, expired, issued to another user or bound to another field does not. Needs an authenticated request because an authorization is issued to an actor. Each refused claim emits a cdn warning event, as a real refusal does. Returns { pass, results }.">
		<cfset var stOut = { pass = true, results = arraynew(1) } />
		<cfset var stBind = { "typename" = "dmFile", "property" = "filename", "location" = "selftestloc", "surface" = "file" } />
		<cfset var stGrant = { "value" = "/dmfile/probe.pdf", "key" = "selftest/dmfile/probe.pdf", "maxsize" = 1000000 } />
		<cfset var token1 = "" />
		<cfset var token2 = "" />
		<cfset var edited = "" />
		<cfset var st = "" />
		<cfset var st2 = "" />

		<cftry>
			<cfset token1 = issue(bind=stBind, grant=stGrant) />
			<cfset token2 = issue(bind=stBind, grant=stGrant) />

			<cfset selfTestRecord(stOut, "a token is a payload and a digest", listlen(token1,".") eq 2, listlen(token1,".") & " parts") />
			<cfset selfTestRecord(stOut, "a token carries no character needing url escaping", refind("[^A-Za-z0-9._-]", token1) eq 0) />
			<cfset selfTestRecord(stOut, "two authorizations differ", token1 neq token2) />

			<cfset st = claim(uploadid=token1, expect=stBind) />
			<cfset selfTestRecord(stOut, "a token this server signed verifies", st.status eq "ok", st.status) />
			<cfset selfTestRecord(stOut, "the grant is read out of the token", structKeyExists(st.grant,"value") and st.grant.value eq stGrant.value) />
			<cfset selfTestRecord(stOut, "the token names a record to create", len(st.recordid) gt 0, st.recordid) />

			<cfset st2 = claim(uploadid=token2, expect=stBind) />
			<cfset selfTestRecord(stOut, "two authorizations name different records", st.recordid neq st2.recordid) />

			<!--- nothing is consumed, so the same token verifying twice is the intended
			      behaviour: what stops a second finalize writing a second record is that both
			      write the record the token names --->
			<cfset st2 = claim(uploadid=token1, expect=stBind) />
			<cfset selfTestRecord(stOut, "verifying twice names the same record both times", st2.status eq "ok" and st2.recordid eq st.recordid, st2.status) />

			<cfset st = claim(uploadid="", expect=stBind) />
			<cfset selfTestRecord(stOut, "an omitted token is refused as notfound", st.status eq "notfound", st.status) />

			<cfset st = claim(uploadid="not-a-token", expect=stBind) />
			<cfset selfTestRecord(stOut, "a malformed token is refused as notfound", st.status eq "notfound", st.status) />

			<!--- the payload of one token with the digest of another: each half is something
			      this server produced, and neither is a signature of the other half --->
			<cfset edited = listfirst(token1,".") & "." & listlast(token2,".") />
			<cfset st = claim(uploadid=edited, expect=stBind) />
			<cfset selfTestRecord(stOut, "a digest from another token is refused as notfound", st.status eq "notfound", st.status) />

			<!--- an edited payload: a grant naming a different object, presented with the
			      digest of the grant that was actually issued --->
			<cfset edited = toBase64Url(serializeJSON({
				"bind" = stBind,
				"grant" = { "value" = "/dmfile/somebodyelse.pdf", "key" = "selftest/dmfile/somebodyelse.pdf", "maxsize" = 1000000 },
				"actor" = getActor(),
				"recordid" = application.fapi.getUUID(),
				"expires" = getTickCount() + 60000
			})) & "." & listlast(token1,".") />
			<cfset st = claim(uploadid=edited, expect=stBind) />
			<cfset selfTestRecord(stOut, "an edited grant is refused as notfound", st.status eq "notfound", st.status) />

			<!--- signed by this server, so the digest is right, but it is not an authorization --->
			<cfset edited = signToken({ "bind" = stBind, "actor" = getActor(), "recordid" = "x", "expires" = getTickCount() + 60000 }) />
			<cfset st = claim(uploadid=edited, expect=stBind) />
			<cfset selfTestRecord(stOut, "a signed payload that is not an authorization is refused", st.status eq "notfound", st.status) />

			<cfset edited = signToken({ "bind" = stBind, "grant" = stGrant, "actor" = getActor(), "recordid" = application.fapi.getUUID(), "expires" = getTickCount() - 1000 }) />
			<cfset st = claim(uploadid=edited, expect=stBind) />
			<cfset selfTestRecord(stOut, "a past expiry is refused as expired", st.status eq "expired", st.status) />

			<cfset edited = signToken({ "bind" = stBind, "grant" = stGrant, "actor" = { "userid" = "someoneelse", "userdirectory" = "", "profileid" = "" }, "recordid" = application.fapi.getUUID(), "expires" = getTickCount() + 60000 }) />
			<cfset st = claim(uploadid=edited, expect=stBind) />
			<cfset selfTestRecord(stOut, "another user's authorization is refused as mismatch", st.status eq "mismatch", st.status) />

			<cfset st = claim(uploadid=token1, expect={ "typename" = "dmFile", "property" = "OTHER", "location" = "selftestloc", "surface" = "file" }) />
			<cfset selfTestRecord(stOut, "a changed bound key is refused as mismatch", st.status eq "mismatch", st.status) />

			<cfset st = claim(uploadid=token1, expect={ "typename" = "dmFile", "location" = "selftestloc", "surface" = "file" }) />
			<cfset selfTestRecord(stOut, "an omitted bound key is refused as mismatch", st.status eq "mismatch", st.status) />

			<cfset edited = signToken({ "bind" = { "typename" = "dmFile" }, "grant" = stGrant, "actor" = getActor(), "recordid" = application.fapi.getUUID(), "expires" = getTickCount() + 60000 }) />
			<cfset st = claim(uploadid=edited, expect={ "typename" = "dmFile", "property" = "filename", "extra" = "x" }) />
			<cfset selfTestRecord(stOut, "presenting extra keys is allowed", st.status eq "ok", st.status) />

			<cfset selfTestRecord(stOut, "an expired authorization gets the retry wording", findnocase("took too long", statusMessage("expired")) gt 0, statusMessage("expired")) />
			<cfset selfTestRecord(stOut, "notfound and mismatch are indistinguishable to the client", statusMessage("notfound") eq statusMessage("mismatch"), statusMessage("notfound")) />

			<cfcatch type="any">
				<cfset selfTestRecord(stOut, "self test threw", false, cfcatch.message) />
			</cfcatch>
		</cftry>

		<cfreturn stOut />
	</cffunction>

	<cffunction name="selfTestRecord" access="private" output="false" returntype="void" hint="Appends a self test result">
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
