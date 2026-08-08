<cfcomponent displayname="Direct Upload" hint="Server held authorization for direct browser-to-bucket uploads. A sign request issues a short lived record describing one exact object key and the context it was issued for; a finalize request presents the id, the record is claimed once, and the accepted value is read back off the record rather than off the request. Records live in session scope, so an authorization only resolves for the session and user it was issued to." output="false" persistent="false">

	<cfset this.defaultMaxPending = 32 />
	<cfset this.defaultGraceMinutes = 10 />
	<cfset this.defaultReplayMinutes = 10 />
	<cfset this.defaultPolicyMinutes = 60 />
	<cfset this.lockTimeout = 10 />

	<cffunction name="init" access="public" output="false" returntype="any">
		<cfreturn this />
	</cffunction>


	<!--- ------------------------------------------------------------------
	      Pending authorizations
	      ------------------------------------------------------------------ --->

	<cffunction name="issue" access="public" output="false" returntype="string" hint="Issues a pending upload authorization and returns its opaque id. bind holds the server resolved facts a finalize request must re-present exactly; grant holds what the authorization confers and is only ever read back off the record. bind.location sizes the expiry against that location's signing policy window. Throws when the session is already at its live ceiling.">
		<cfargument name="bind" type="struct" required="true" />
		<cfargument name="grant" type="struct" required="true" />

		<cfset var uploadid = newAuthorizationID() />
		<cfset var stStore = getStore() />
		<cfset var stActor = getActor() />
		<cfset var location = structKeyExists(arguments.bind,"location") ? arguments.bind.location : "" />
		<cfset var issuedAt = now() />
		<cfset var minutes = getPolicyMinutes(location) + getNumericSetting("graceMinutes",this.defaultGraceMinutes,0) />
		<cfset var maxPending = getNumericSetting("maxPending",this.defaultMaxPending,1) />

		<cfset prune() />

		<cfif countLive() gte maxPending>
			<cfset application.fapi.throw(message="Too many uploads in progress. Wait for the current uploads to finish and try again.",type="uploaderror") />
		</cfif>

		<cfset stStore[uploadid] = {
			"bind" = duplicate(arguments.bind),
			"grant" = duplicate(arguments.grant),
			"actor" = stActor,
			"issued" = issuedAt,
			"expires" = dateadd("n", minutes, issuedAt),
			"bConsumed" = false,
			"bHasResult" = false,
			"result" = ""
		} />

		<cfreturn uploadid />
	</cffunction>


	<cffunction name="claim" access="public" output="false" returntype="struct" hint="Compares the stored context against expect and atomically marks the record consumed. Returns { status, bind, grant, result } where status is ok, replay, notfound, expired or mismatch. Only status ok authorises side effects; replay carries the completed result of the finalize that already ran.">
		<cfargument name="uploadid" type="string" required="false" default="" />
		<cfargument name="expect" type="struct" required="true" />

		<cfset var stResult = { "status" = "notfound", "bind" = structnew(), "grant" = structnew(), "result" = "" } />
		<cfset var stStore = getStore() />
		<cfset var stRecord = "" />

		<!--- an id naming no record keeps the notfound this started as and falls through to
		      the same reporting every other refusal goes through. returning here instead
		      would make the commonest refusal the only one an operator cannot see --->
		<cfif len(trim(arguments.uploadid)) and structKeyExists(stStore,arguments.uploadid)>
			<!--- compare and consume under one lock so a repeated finalize cannot run the
			      side effects twice. the lock is JVM local, as every other named lock in
			      core is, so single use is not claimed across a cluster --->
			<cflock name="directUpload_#arguments.uploadid#_#application.applicationname#" type="exclusive" timeout="#this.lockTimeout#">
				<cfif structKeyExists(stStore,arguments.uploadid)>
					<cfset stRecord = stStore[arguments.uploadid] />

					<cfif datecompare(now(), stRecord.expires) gt 0>
						<cfset structDelete(stStore,arguments.uploadid) />
						<cfset stResult["status"] = "expired" />

					<cfelseif not sameActor(stRecord.actor) or not sameContext(stRecord.bind, arguments.expect)>
						<cfset stResult["status"] = "mismatch" />

					<cfelseif stRecord.bConsumed>
						<cfset stResult["status"] = "replay" />
						<cfset stResult["bind"] = duplicate(stRecord.bind) />
						<cfset stResult["grant"] = duplicate(stRecord.grant) />
						<cfif stRecord.bHasResult>
							<cfset stResult["result"] = stRecord.result />
						</cfif>

					<cfelse>
						<cfset stRecord.bConsumed = true />
						<!--- from here the record is carrying a finalize that is still running, so it
						      gets at least the shipped grace however short the retry window is set -
						      including zero. complete() resets it to the retry window proper. The
						      whole lifecycle lives in this one field: nothing else special cases a
						      consumed record, so none of them can outlive their clock. --->
						<cfset stRecord.expires = dateadd("n", max(getNumericSetting("replayMinutes",this.defaultReplayMinutes,0), this.defaultGraceMinutes), now()) />
						<cfset stResult["status"] = "ok" />
						<!--- copies, so a caller working with what it was granted cannot reach
						      back into the stored record --->
						<cfset stResult["bind"] = duplicate(stRecord.bind) />
						<cfset stResult["grant"] = duplicate(stRecord.grant) />
					</cfif>
				</cfif>
			</cflock>
		</cfif>

		<!--- a refused finalize is the failure an operator gets asked about, and the message
		      the uploader shows deliberately does not say which of the reasons applied. a
		      replay that hands back its stored result succeeded, so it is not a refusal --->
		<cfif stResult.status neq "ok" and not (stResult.status eq "replay" and len(stResult.result))>
			<cfset application.fapi.logEvent("cdn", "warning", "direct upload finalize refused", {
				reason = stResult.status,
				typename = structKeyExists(arguments.expect,"typename") ? arguments.expect.typename : "",
				property = structKeyExists(arguments.expect,"property") ? arguments.expect.property : "",
				surface = structKeyExists(arguments.expect,"surface") ? arguments.expect.surface : ""
			}) />
		</cfif>

		<cfreturn stResult />
	</cffunction>


	<cffunction name="claimAndVerify" access="public" output="false" returntype="struct" hint="The whole finalize precondition in one call: claims the authorization, takes the accepted value off the record, re-asserts the value's shape, and confirms the object is in the bucket within the size the server signed for - all before the caller has any side effect. Returns { status, value, message, result }: ok means proceed with value, replay means return result verbatim because the side effects already ran, failed means return message and do nothing. Every direct upload surface goes through this, so the sequence cannot drift between them.">
		<cfargument name="uploadid" type="string" required="false" default="" />
		<cfargument name="expect" type="struct" required="true" hint="the context this surface resolved for the finalize request, compared against the record" />
		<cfargument name="clientValue" type="string" required="false" default="" hint="the value the request echoed back; compared as a consistency check and otherwise ignored" />
		<cfargument name="noun" type="string" required="false" default="file" hint="what to call the object in a user facing message" />

		<cfset var stClaim = claim(uploadid=arguments.uploadid, expect=arguments.expect) />
		<cfset var stResult = { "status" = "failed", "value" = "", "message" = "", "result" = "" } />
		<cfset var location = "" />
		<cfset var value = "" />
		<cfset var maxsize = 0 />

		<!--- a repeat of a finalize that already reported a result gets that result back
		      rather than running the side effects a second time --->
		<cfif stClaim.status eq "replay" and len(stClaim.result)>
			<cfset stResult["status"] = "replay" />
			<cfset stResult["result"] = stClaim.result />
			<cfreturn stResult />
		</cfif>

		<cfif stClaim.status neq "ok">
			<cfset stResult["message"] = statusMessage(stClaim.status) />
			<cfreturn stResult />
		</cfif>

		<!--- everything from here is read off the record, never off the request --->
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

		<cfreturn stResult />
	</cffunction>


	<cffunction name="complete" access="public" output="false" returntype="void" hint="Stores a consumed record's serialized response so a repeated finalize within the replay window returns it verbatim instead of running the side effects again.">
		<cfargument name="uploadid" type="string" required="true" />
		<cfargument name="result" type="string" required="true" />

		<cfset var stStore = getStore() />

		<cflock name="directUpload_#arguments.uploadid#_#application.applicationname#" type="exclusive" timeout="#this.lockTimeout#">
			<!--- only a record this request claimed can carry a result, so an unclaimed
			      record cannot be given one to hand back --->
			<cfif structKeyExists(stStore,arguments.uploadid) and stStore[arguments.uploadid].bConsumed>
				<cfset stStore[arguments.uploadid].result = arguments.result />
				<cfset stStore[arguments.uploadid].bHasResult = true />
				<!--- restart the window here rather than leaving it running from the claim, so
				      a slow finalize does not spend the retry window it is meant to protect -
				      the image resize this cache exists for is exactly the slow case --->
				<cfset stStore[arguments.uploadid].expires = dateadd("n", getNumericSetting("replayMinutes",this.defaultReplayMinutes,0), now()) />
			</cfif>
		</cflock>
	</cffunction>


	<cffunction name="prune" access="public" output="false" returntype="void" hint="Removes expired records, on one plain expiry test. A claimed record carries a longer expiry while its finalize runs, so this needs no special case for it - which is what keeps a finalize that failed after claiming, and will therefore never complete, from lingering for the whole session.">
		<cfset var stStore = getStore() />
		<cfset var uploadid = "" />
		<cfset var checkedAt = now() />

		<cfloop list="#structKeyList(stStore)#" index="uploadid">
			<cfif structKeyExists(stStore,uploadid) and datecompare(checkedAt, stStore[uploadid].expires) gt 0>
				<cfset structDelete(stStore,uploadid) />
			</cfif>
		</cfloop>
	</cffunction>


	<cffunction name="statusMessage" access="public" output="false" returntype="string" hint="The client facing message for a claim status. One wording across all four upload surfaces, so a caller sees the same failure whichever field it came from.">
		<cfargument name="status" type="string" required="true" />

		<cfswitch expression="#arguments.status#">
			<cfcase value="expired">
				<cfreturn "This upload took too long to complete. Upload the file again." />
			</cfcase>
			<cfdefaultcase>
				<!--- a replay with no stored result is a finalize that did not report one, so
				      it is reported as used up rather than as a success --->
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

	<cffunction name="getStore" access="private" output="false" returntype="struct" hint="The session's pending authorization store, created on first use. Created once, under a lock: the create is a read then a write, so uploads signing at the same time in a session that has not signed anything yet would each build a store, and every record written into the ones that lost would be unreachable from the session by the time its finalize looked for it. The lock covers the create only - a store that already exists is returned without taking it - so it is contended once per session.">
		<cfif structKeyExists(session,"fc") and structKeyExists(session.fc,"directUploads")>
			<cfreturn session.fc.directUploads />
		</cfif>

		<cflock name="directUploadStore_#application.applicationname#" type="exclusive" timeout="#this.lockTimeout#">
			<cfparam name="session.fc" default="#structNew()#" />
			<cfparam name="session.fc.directUploads" default="#structNew()#" />
		</cflock>

		<cfreturn session.fc.directUploads />
	</cffunction>


	<cffunction name="countLive" access="private" output="false" returntype="numeric" hint="Number of records still awaiting their finalize. Consumed records are not counted, so the ceiling bounds upload concurrency rather than batch size.">
		<cfset var stStore = getStore() />
		<cfset var uploadid = "" />
		<cfset var count = 0 />
		<cfset var checkedAt = now() />

		<cfloop list="#structKeyList(stStore)#" index="uploadid">
			<cfif structKeyExists(stStore,uploadid) and not stStore[uploadid].bConsumed and datecompare(checkedAt, stStore[uploadid].expires) lte 0>
				<cfset count = count + 1 />
			</cfif>
		</cfloop>

		<cfreturn count />
	</cffunction>


	<cffunction name="newAuthorizationID" access="private" output="false" returntype="string" hint="An unguessable opaque id: 128 bits drawn from the platform CSPRNG, hashed to fixed length hex so the id is url safe without any character stripping. generateSecretKey is the native cross-engine CSPRNG on both supported engines.">
		<cfreturn lcase(left(hash(generateSecretKey("AES",256),"SHA-256"),32)) />
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

	<cffunction name="authorizationSelfTest" access="public" output="false" returntype="struct" hint="Exercises the whole pending authorization lifecycle in process, against an isolated store that is swapped in and restored: issue, single use, replay, context binding, expiry, pruning and the concurrency ceiling. Needs an authenticated request because an authorization is issued to an actor. Each refused claim emits a cdn warning event, as a real refusal does. Returns { pass, results }.">
		<cfset var stOut = { pass = true, results = arraynew(1) } />
		<cfset var stSaved = getStore() />
		<cfset var stStore = "" />
		<cfset var stBind = { "typename" = "dmFile", "property" = "filename", "location" = "selftestloc", "surface" = "file" } />
		<cfset var stGrant = { "value" = "/dmfile/probe.pdf", "key" = "selftest/dmfile/probe.pdf", "maxsize" = 1000000 } />
		<cfset var id1 = "" /><cfset var id2 = "" /><cfset var id3 = "" /><cfset var id4 = "" />
		<cfset var id5 = "" /><cfset var id6 = "" /><cfset var id7 = "" /><cfset var id8 = "" />
		<cfset var st = "" />
		<cfset var maxPending = 0 />
		<cfset var i = 0 />
		<cfset var uploadid = "" />
		<cfset var bThrew = false />
		<cfset var capMessage = "" />
		<cfset var bIssuedAfterConsuming = false />

		<!--- an isolated store, so a real upload in flight in this session is untouched --->
		<cfset session.fc.directUploads = structnew() />
		<cfset stStore = getStore() />

		<cftry>
			<cfset id1 = issue(bind=stBind, grant=stGrant) />
			<cfset id2 = issue(bind=stBind, grant=stGrant) />
			<cfset selfTestRecord(stOut, "issue returns a 32 char hex id", refindnocase("^[0-9a-f]{32}$", id1) gt 0, id1) />
			<cfset selfTestRecord(stOut, "two authorizations get distinct ids", id1 neq id2) />

			<cfset st = claim(uploadid="", expect=stBind) />
			<cfset selfTestRecord(stOut, "omitted uploadid is refused as notfound", st.status eq "notfound", st.status) />

			<cfset st = claim(uploadid=repeatstring("a",32), expect=stBind) />
			<cfset selfTestRecord(stOut, "a guessed uploadid is refused as notfound", st.status eq "notfound", st.status) />

			<cfset st = claim(uploadid=id1, expect=stBind) />
			<cfset selfTestRecord(stOut, "matching context claims ok", st.status eq "ok", st.status) />
			<cfset selfTestRecord(stOut, "the grant is read back off the record", structKeyExists(st.grant,"value") and st.grant.value eq stGrant.value) />

			<cfset st = claim(uploadid=id1, expect=stBind) />
			<cfset selfTestRecord(stOut, "a second claim is a replay, not a second ok", st.status eq "replay", st.status) />
			<cfset selfTestRecord(stOut, "a replay before complete carries no result", not len(st.result)) />

			<cfset complete(uploadid=id1, result='{"probe":1}') />
			<cfset st = claim(uploadid=id1, expect=stBind) />
			<cfset selfTestRecord(stOut, "a replay after complete returns the stored result verbatim", st.status eq "replay" and st.result eq '{"probe":1}', st.result) />

			<cfset st = claim(uploadid=id2, expect={ "typename" = "dmFile", "property" = "OTHER", "location" = "selftestloc", "surface" = "file" }) />
			<cfset selfTestRecord(stOut, "a changed bound key is refused as mismatch", st.status eq "mismatch", st.status) />
			<cfset selfTestRecord(stOut, "a mismatched claim does not consume the record", structKeyExists(stStore,id2) and not stStore[id2].bConsumed) />

			<cfset st = claim(uploadid=id2, expect={ "typename" = "dmFile", "location" = "selftestloc", "surface" = "file" }) />
			<cfset selfTestRecord(stOut, "an omitted bound key is refused as mismatch", st.status eq "mismatch", st.status) />

			<cfset id3 = issue(bind={ "typename" = "dmFile" }, grant=stGrant) />
			<cfset st = claim(uploadid=id3, expect={ "typename" = "dmFile", "property" = "filename", "extra" = "x" }) />
			<cfset selfTestRecord(stOut, "presenting extra keys is allowed", st.status eq "ok", st.status) />

			<cfset id4 = issue(bind=stBind, grant=stGrant) />
			<cfset stStore[id4].expires = dateadd("n", -1, now()) />
			<cfset st = claim(uploadid=id4, expect=stBind) />
			<cfset selfTestRecord(stOut, "a past expiry is refused as expired", st.status eq "expired", st.status) />
			<cfset selfTestRecord(stOut, "an expired record is dropped when claimed", not structKeyExists(stStore,id4)) />

			<cfset id5 = issue(bind=stBind, grant=stGrant) />
			<cfset id6 = issue(bind=stBind, grant=stGrant) />
			<cfset stStore[id5].expires = dateadd("n", -1, now()) />
			<cfset prune() />
			<cfset selfTestRecord(stOut, "prune removes an abandoned authorization", not structKeyExists(stStore,id5)) />
			<cfset selfTestRecord(stOut, "prune keeps a live authorization", structKeyExists(stStore,id6)) />

			<cfset id7 = issue(bind=stBind, grant=stGrant) />
			<cfset claim(uploadid=id7, expect=stBind) />
			<cfset prune() />
			<cfset selfTestRecord(stOut, "prune keeps a claimed record inside its grace window", structKeyExists(stStore,id7)) />

			<cfset id8 = issue(bind=stBind, grant=stGrant) />
			<cfset complete(uploadid=id8, result='{"forged":1}') />
			<cfset selfTestRecord(stOut, "complete on an unclaimed record stores nothing", structKeyExists(stStore,id8) and not stStore[id8].bHasResult) />

			<!--- the ceiling bounds uploads in progress, so a consumed record must not count --->
			<cfset maxPending = getNumericSetting("maxPending", this.defaultMaxPending, 1) />
			<cfset session.fc.directUploads = structnew() />
			<cfset stStore = getStore() />
			<cfloop from="1" to="#maxPending#" index="i">
				<cfset issue(bind=stBind, grant=stGrant) />
			</cfloop>
			<cftry>
				<cfset issue(bind=stBind, grant=stGrant) />
				<cfcatch type="any">
					<cfset bThrew = true />
					<cfset capMessage = cfcatch.message />
				</cfcatch>
			</cftry>
			<cfset selfTestRecord(stOut, "issue is refused at the configured cap (#maxPending#)", bThrew, capMessage) />
			<cfset selfTestRecord(stOut, "reaching the cap did not evict a live record", structcount(stStore) eq maxPending, structcount(stStore) & " records held") />

			<cfloop collection="#stStore#" item="uploadid">
				<cfset claim(uploadid=uploadid, expect=stBind) />
			</cfloop>
			<cftry>
				<cfset issue(bind=stBind, grant=stGrant) />
				<cfset bIssuedAfterConsuming = true />
				<cfcatch type="any">
					<cfset bIssuedAfterConsuming = false />
				</cfcatch>
			</cftry>
			<cfset selfTestRecord(stOut, "consumed records do not count toward the cap", bIssuedAfterConsuming) />

			<cfset selfTestRecord(stOut, "an expired authorization gets the retry wording", findnocase("took too long", statusMessage("expired")) gt 0, statusMessage("expired")) />
			<cfset selfTestRecord(stOut, "notfound and mismatch are indistinguishable to the client", statusMessage("notfound") eq statusMessage("mismatch"), statusMessage("notfound")) />

			<cfcatch type="any">
				<cfset selfTestRecord(stOut, "self test threw", false, cfcatch.message) />
			</cfcatch>
		</cftry>

		<!--- whatever this session was really holding --->
		<cfset session.fc.directUploads = stSaved />

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
