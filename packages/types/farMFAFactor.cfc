<cfcomponent
	displayname="MFA Factor"
	hint="Enrolled multi-factor authentication factors, keyed by a stable directory-scoped user key plus the owning user directory. Directory-agnostic storage for credential-owning user directories; secrets in the payload are encrypted by the caller before they reach this type."
	extends="types" output="false"
	bRefObjects="false" bObjectBroker="0" bSystem="true"
	icon="fa-lock">

	<cfproperty name="userKey" type="string" default=""
		ftSeq="1" ftFieldset="" ftLabel="User key"
		ftType="string" dbIndex="IDX_userKey"
		hint="Stable directory-scoped subject id (CLIENTUD: the farUser objectid). Never the login name.">

	<cfproperty name="userDirectory" type="string" default=""
		ftSeq="2" ftFieldset="" ftLabel="User directory"
		ftType="string"
		hint="Key of the owning user directory (e.g. CLIENTUD)">

	<cfproperty name="factorType" type="string" default=""
		ftSeq="3" ftFieldset="" ftLabel="Factor type"
		ftType="string" dbIndex="IDX_mfaFactorKey:1"
		hint="totp / recoveryCode (passkey and emailOTP in later phases)">

	<cfproperty name="status" type="string" default="active"
		ftSeq="4" ftFieldset="" ftLabel="Status"
		ftType="string" dbIndex="IDX_mfaFactorKey:2"
		hint="active / revoked. Only an active row can authenticate. A revoked row keeps no payload and exists solely as non-secret evidence that the user completed an enrolment once, so a returning enrollee stays distinguishable from a new one after a removal (see hasEverEnrolled). The security events remain the audit record.">

	<cfproperty name="payload" type="longchar" default=""
		ftSeq="5" ftFieldset="" ftLabel="Payload"
		ftType="longchar"
		hint="Per-type JSON payload; secret material is encrypted at rest by the caller">

	<cfproperty name="lastUsed" type="date"
		ftSeq="6" ftFieldset="" ftLabel="Last used"
		ftType="datetime"
		hint="When this factor last verified successfully">

	<cfproperty name="keyId" type="string" default=""
		ftSeq="7" ftFieldset="" ftLabel="Key id"
		ftType="string" dbIndex="IDX_mfaFactorKey:3"
		hint="For a totp factor, the encryption key id its secret is sealed under (the gcm envelope's key-id segment), denormalised so a post-rotation 'needs migration' count is an indexed equality query rather than a payload scan. Empty for factor types not sealed with the rotating key (passkey, recoveryCode). Shares the composite index IDX_mfaFactorKey (factorType, status, keyId) declared via dbIndex across those three properties, so it is created by the framework's schema sync - no manual DDL.">


	<cffunction name="getFactors" access="public" output="false" returntype="query" hint="Returns factor rows (without payload) for a user">
		<cfargument name="userKey" type="string" required="true" />
		<cfargument name="userDirectory" type="string" required="true" />
		<cfargument name="factorType" type="string" required="false" default="" />
		<cfargument name="status" type="string" required="false" default="active" hint="Empty string returns all statuses" />

		<cfset var qFactors = "" />

		<cfquery datasource="#application.dsn#" name="qFactors">
			SELECT objectid, userKey, userDirectory, factorType, label, status, lastUsed, datetimecreated
			FROM #application.dbowner#farMFAFactor
			WHERE
				userKey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userKey#">
				AND userDirectory = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userDirectory#">
				<cfif len(arguments.factorType)>
				AND factorType = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.factorType#">
				</cfif>
				<cfif len(arguments.status)>
				AND status = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.status#">
				</cfif>
			ORDER BY CASE WHEN factorType = 'recoveryCode' THEN 1 ELSE 0 END, datetimecreated
		</cfquery>

		<cfreturn qFactors />
	</cffunction>

	<cffunction name="hasActiveAuthFactor" access="public" output="false" returntype="boolean" hint="True when the user has an active authentication factor (recovery codes alone do not count as enrolment)">
		<cfargument name="userKey" type="string" required="true" />
		<cfargument name="userDirectory" type="string" required="true" />

		<cfset var qFactors = getFactors(userKey=arguments.userKey, userDirectory=arguments.userDirectory) />
		<cfset var i = 0 />

		<cfloop from="1" to="#qFactors.recordcount#" index="i">
			<cfif qFactors.factorType[i] neq "recoveryCode">
				<cfreturn true />
			</cfif>
		</cfloop>

		<cfreturn false />
	</cffunction>

	<cffunction name="hasStrongAuthFactor" access="public" output="false" returntype="boolean" hint="True when the user has an active strong factor (totp or passkey). Email OTP and recovery codes do not count; used to decide whether email OTP may be offered under the soleFactor policy.">
		<cfargument name="userKey" type="string" required="true" />
		<cfargument name="userDirectory" type="string" required="true" />

		<cfset var qFactors = getFactors(userKey=arguments.userKey, userDirectory=arguments.userDirectory) />
		<cfset var i = 0 />

		<cfloop from="1" to="#qFactors.recordcount#" index="i">
			<cfif qFactors.factorType[i] eq "totp" or qFactors.factorType[i] eq "passkey">
				<cfreturn true />
			</cfif>
		</cfloop>

		<cfreturn false />
	</cffunction>

	<cffunction name="hasEverEnrolled" access="public" output="false" returntype="boolean" hint="True when this user has completed an enrolment at some point, read from retained factor history rather than the current active-factor count. Any row counts - active or revoked, primary factor or recovery-code set - because a row is only ever written once a factor has been proven. This is what tells a previously enrolled user apart from a genuinely never-enrolled one after a removal, so the enrolment grace skip cannot be handed back by removing a factor. A row hard-deleted by purgeFactors is gone from this history by design.">
		<cfargument name="userKey" type="string" required="true" />
		<cfargument name="userDirectory" type="string" required="true" />

		<cfset var qHistory = "" />

		<cfquery datasource="#application.dsn#" name="qHistory">
			SELECT COUNT(*) AS n
			FROM #application.dbowner#farMFAFactor
			WHERE
				userKey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userKey#">
				AND userDirectory = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userDirectory#">
		</cfquery>

		<cfreturn val(qHistory.n) gt 0 />
	</cffunction>

	<cffunction name="createFactor" access="public" output="false" returntype="string" hint="Creates a factor row and returns its objectid. The payload must already have secret material encrypted. Pass keyId for a totp factor (the id its secret is sealed under) so the denormalised column stays in step; leave empty for factor types not sealed with the rotating key.">
		<cfargument name="userKey" type="string" required="true" />
		<cfargument name="userDirectory" type="string" required="true" />
		<cfargument name="factorType" type="string" required="true" />
		<cfargument name="stPayload" type="struct" required="true" />
		<cfargument name="label" type="string" required="false" default="" />
		<cfargument name="keyId" type="string" required="false" default="" />

		<cfset var stObj = structnew() />

		<cfset stObj.objectid = application.fc.utils.createJavaUUID() />
		<cfset stObj.userKey = arguments.userKey />
		<cfset stObj.userDirectory = arguments.userDirectory />
		<cfset stObj.factorType = arguments.factorType />
		<cfset stObj.status = "active" />
		<cfset stObj.payload = serializeJSON(arguments.stPayload) />
		<cfset stObj.label = arguments.label />
		<cfset stObj.keyId = arguments.keyId />

		<cfset createData(stProperties=stObj, bAudit=false) />

		<cfreturn stObj.objectid />
	</cffunction>

	<cffunction name="getActiveFactor" access="public" output="false" returntype="struct" hint="Returns the first active factor of a type, with its payload deserialized; empty struct when none">
		<cfargument name="userKey" type="string" required="true" />
		<cfargument name="userDirectory" type="string" required="true" />
		<cfargument name="factorType" type="string" required="true" />

		<cfset var stResult = structnew() />
		<cfset var qFactor = "" />

		<cfquery datasource="#application.dsn#" name="qFactor">
			SELECT objectid, label, payload, lastUsed
			FROM #application.dbowner#farMFAFactor
			WHERE
				userKey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userKey#">
				AND userDirectory = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userDirectory#">
				AND factorType = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.factorType#">
				AND status = <cfqueryparam cfsqltype="cf_sql_varchar" value="active">
			ORDER BY datetimecreated
		</cfquery>

		<cfif qFactor.recordcount>
			<cfset stResult.objectid = qFactor.objectid[1] />
			<cfset stResult.label = qFactor.label[1] />
			<cfset stResult.lastUsed = qFactor.lastUsed[1] />
			<cfif isJSON(qFactor.payload[1])>
				<cfset stResult.stPayload = deserializeJSON(qFactor.payload[1]) />
			<cfelse>
				<cfset stResult.stPayload = structnew() />
			</cfif>
		</cfif>

		<cfreturn stResult />
	</cffunction>

	<cffunction name="updateFactorPayload" access="public" output="false" returntype="void" hint="Replaces a factor payload and stamps lastUsed. Pass keyId for a totp factor so the denormalised column tracks the secret's current key id (unchanged on a normal verify, updated on a lazy re-wrap); empty for other factor types.">
		<cfargument name="objectid" type="uuid" required="true" />
		<cfargument name="stPayload" type="struct" required="true" />
		<cfargument name="keyId" type="string" required="false" default="" />

		<cfset var stObj = getData(objectid=arguments.objectid) />

		<cfif not structIsEmpty(stObj)>
			<cfset stObj.payload = serializeJSON(arguments.stPayload) />
			<cfset stObj.lastUsed = now() />
			<cfset stObj.keyId = arguments.keyId />
			<cfset setData(stProperties=stObj, bAudit=false) />
		</cfif>
	</cffunction>

	<cffunction name="writeFactorSecret" access="public" output="false" returntype="numeric" hint="Re-writes a factor's sealed secret (and its denormalised keyId) in place for a key-rotation migration, rebuilding the payload from a fresh read so lastUsed and lastStep carry through and only the secret changes. Skips a row already at the target key id (a concurrent lazy re-wrap on login got there first). The read/write pair is not transactionally locked, so in the rare event a login commits a new lastStep in that window it is last-writer-wins - benign here (worst case a one-step replay window that a live code would already defeat). Returns 1 when written, 0 when the row is gone or already migrated.">
		<cfargument name="objectid" type="uuid" required="true" />
		<cfargument name="newSecret" type="string" required="true" hint="The re-sealed secret to store" />
		<cfargument name="keyId" type="string" required="false" default="" />

		<cfset var stObj = getData(objectid=arguments.objectid) />
		<cfset var stPayload = "" />

		<cfif structIsEmpty(stObj) or not structKeyExists(stObj, "payload") or not isJSON(stObj.payload)>
			<cfreturn 0 />
		</cfif>

		<!--- already at the target key (e.g. a concurrent lazy re-wrap on login got here first): leave it untouched --->
		<cfif structKeyExists(stObj, "keyId") and len(stObj.keyId) and stObj.keyId eq arguments.keyId>
			<cfreturn 0 />
		</cfif>

		<cfset stPayload = deserializeJSON(stObj.payload) />
		<cfset stPayload.secret = arguments.newSecret />
		<cfset stObj.payload = serializeJSON(stPayload) />
		<cfset stObj.keyId = arguments.keyId />
		<!--- deliberately does NOT touch lastUsed - a maintenance re-wrap is not a use of the factor --->
		<cfset setData(stProperties=stObj, bAudit=false) />

		<cfreturn 1 />
	</cffunction>

	<cffunction name="getPasskeys" access="public" output="false" returntype="array" hint="Active passkey factors for a user, each with its deserialized payload (credentialId, public key params, signCount, transports). Passkeys are N-per-user, so unlike getActiveFactor this returns all of them.">
		<cfargument name="userKey" type="string" required="true" />
		<cfargument name="userDirectory" type="string" required="true" />

		<cfset var qPasskeys = "" />
		<cfset var aResult = arraynew(1) />
		<cfset var stItem = "" />

		<cfquery datasource="#application.dsn#" name="qPasskeys">
			SELECT objectid, label, payload, lastUsed, datetimecreated
			FROM #application.dbowner#farMFAFactor
			WHERE
				userKey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userKey#">
				AND userDirectory = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userDirectory#">
				AND factorType = <cfqueryparam cfsqltype="cf_sql_varchar" value="passkey">
				AND status = <cfqueryparam cfsqltype="cf_sql_varchar" value="active">
			ORDER BY datetimecreated
		</cfquery>

		<cfloop query="qPasskeys">
			<cfset stItem = { objectid = qPasskeys.objectid, label = qPasskeys.label, lastUsed = qPasskeys.lastUsed, datetimecreated = qPasskeys.datetimecreated, stPayload = structnew() } />
			<cfif isJSON(qPasskeys.payload)>
				<cfset stItem.stPayload = deserializeJSON(qPasskeys.payload) />
			</cfif>
			<cfset arrayAppend(aResult, stItem) />
		</cfloop>

		<cfreturn aResult />
	</cffunction>

	<cffunction name="getPasskeyByCredentialId" access="public" output="false" returntype="struct" hint="Finds a user's passkey by the credentialId returned in an assertion; empty struct when none match. Scoped to the user (second factor: the subject is already known), so no global credential index is needed.">
		<cfargument name="userKey" type="string" required="true" />
		<cfargument name="userDirectory" type="string" required="true" />
		<cfargument name="credentialId" type="string" required="true" hint="base64url" />

		<cfset var aPasskeys = getPasskeys(userKey=arguments.userKey, userDirectory=arguments.userDirectory) />
		<cfset var stPasskey = "" />

		<cfloop array="#aPasskeys#" index="stPasskey">
			<cfif structKeyExists(stPasskey.stPayload, "credentialId") and stPasskey.stPayload.credentialId eq arguments.credentialId>
				<cfreturn stPasskey />
			</cfif>
		</cfloop>

		<cfreturn structnew() />
	</cffunction>

	<cffunction name="revokeFactorForUser" access="public" output="false" returntype="boolean" hint="Soft-revokes one factor row, but only when it belongs to the given user and - when factorType is passed - is of that type. Both are checked here rather than trusted from the caller, so a removal only ever reaches the row the operation names. Returns true when a row moved from active to revoked.">
		<cfargument name="objectid" type="uuid" required="true" />
		<cfargument name="userKey" type="string" required="true" />
		<cfargument name="userDirectory" type="string" required="true" />
		<cfargument name="factorType" type="string" required="false" default="" hint="Constrain the removal to this factor type; empty allows any" />

		<cfset var stObj = getData(objectid=arguments.objectid) />

		<cfif structIsEmpty(stObj) or not structKeyExists(stObj, "userKey")>
			<cfreturn false />
		</cfif>
		<cfif stObj.userKey neq arguments.userKey or stObj.userDirectory neq arguments.userDirectory>
			<cfreturn false />
		</cfif>
		<cfif len(arguments.factorType) and stObj.factorType neq arguments.factorType>
			<cfreturn false />
		</cfif>

		<cfreturn revokeFactor(objectid=arguments.objectid) gt 0 />
	</cffunction>

	<cffunction name="revokeFactors" access="public" output="false" returntype="numeric" hint="Soft-revokes every ACTIVE factor row for a user, optionally of one type, and returns how many were revoked. Idempotent over retained history: a repeat call returns 0 rather than reporting already-revoked rows as newly removed.">
		<cfargument name="userKey" type="string" required="true" />
		<cfargument name="userDirectory" type="string" required="true" />
		<cfargument name="factorType" type="string" required="false" default="" />

		<cfset var qFactors = getFactors(userKey=arguments.userKey, userDirectory=arguments.userDirectory, factorType=arguments.factorType, status="active") />
		<cfset var i = 0 />
		<cfset var revoked = 0 />

		<cfloop from="1" to="#qFactors.recordcount#" index="i">
			<cfset revoked = revoked + revokeFactor(objectid=qFactors.objectid[i]) />
		</cfloop>

		<cfreturn revoked />
	</cffunction>

	<cffunction name="revokeFactor" access="private" output="false" returntype="numeric" hint="Marks one row revoked and strips what could still authenticate with it: the payload (a sealed totp secret, passkey credential material, or a recovery-code set's hashes) and the stale keyId. What is left is non-secret enrolment history, not an audit trail - the security events own that. Returns 1 when a row moved from active to revoked, 0 when it was already revoked or gone.">
		<cfargument name="objectid" type="uuid" required="true" />

		<cfset var stObj = getData(objectid=arguments.objectid) />

		<cfif structIsEmpty(stObj) or not structKeyExists(stObj, "status") or stObj.status neq "active">
			<cfreturn 0 />
		</cfif>

		<cfset stObj.status = "revoked" />
		<cfset stObj.payload = "" />
		<cfset stObj.keyId = "" />
		<cfset setData(stProperties=stObj, bAudit=false) />

		<cfreturn 1 />
	</cffunction>

	<cffunction name="setFactorLabel" access="public" output="false" returntype="boolean" hint="Renames one factor, but only when it belongs to the given user. Returns true when the label was changed.">
		<cfargument name="objectid" type="uuid" required="true" />
		<cfargument name="userKey" type="string" required="true" />
		<cfargument name="userDirectory" type="string" required="true" />
		<cfargument name="label" type="string" required="true" />

		<cfset var stObj = getData(objectid=arguments.objectid) />

		<cfif not structIsEmpty(stObj) and structKeyExists(stObj, "userKey") and stObj.userKey eq arguments.userKey and stObj.userDirectory eq arguments.userDirectory>
			<cfset stObj.label = left(trim(arguments.label), 255) />
			<cfset setData(stProperties=stObj, bAudit=false) />
			<cfreturn true />
		</cfif>

		<cfreturn false />
	</cffunction>

	<cffunction name="saveRecoveryCodes" access="public" output="false" returntype="void" hint="Replaces the user's recovery code set. Pass hashes, never plain codes.">
		<cfargument name="userKey" type="string" required="true" />
		<cfargument name="userDirectory" type="string" required="true" />
		<cfargument name="aHashes" type="array" required="true" />

		<cfset var aCodes = arraynew(1) />
		<cfset var hash = "" />

		<cfloop array="#arguments.aHashes#" index="hash">
			<cfset arrayAppend(aCodes, { hash = hash, used = false }) />
		</cfloop>

		<!--- revoke the outgoing set (its hashes are cleared with it) before the new one lands, so exactly one set is ever active --->
		<cfset revokeFactors(userKey=arguments.userKey, userDirectory=arguments.userDirectory, factorType="recoveryCode") />
		<cfset createFactor(userKey=arguments.userKey, userDirectory=arguments.userDirectory, factorType="recoveryCode", stPayload={ codes = aCodes }, label="Recovery codes") />
	</cffunction>

	<cffunction name="redeemRecoveryCode" access="public" output="false" returntype="struct" hint="Attempts to redeem a single-use recovery code; marks it used on success">
		<cfargument name="userKey" type="string" required="true" />
		<cfargument name="userDirectory" type="string" required="true" />
		<cfargument name="code" type="string" required="true" />

		<cfset var stResult = { redeemed = false, remaining = 0 } />
		<cfset var stFactor = getActiveFactor(userKey=arguments.userKey, userDirectory=arguments.userDirectory, factorType="recoveryCode") />
		<!--- normalise: codes are compared without formatting so dashes, spaces and case do not matter --->
		<cfset var submitted = reReplace(ucase(trim(arguments.code)), "[^A-Z0-9]", "", "all") />
		<cfset var i = 0 />
		<cfset var stCode = "" />

		<cfif structIsEmpty(stFactor) or not structKeyExists(stFactor.stPayload, "codes")>
			<cfreturn stResult />
		</cfif>

		<cfloop from="1" to="#arrayLen(stFactor.stPayload.codes)#" index="i">
			<cfset stCode = stFactor.stPayload.codes[i] />
			<cfif not stCode.used and application.security.cryptlib.passwordMatchesHash(password=submitted, hashedPassword=stCode.hash)>
				<cfset stFactor.stPayload.codes[i].used = true />
				<cfset stResult.redeemed = true />
			</cfif>
			<cfif not stFactor.stPayload.codes[i].used>
				<cfset stResult.remaining = stResult.remaining + 1 />
			</cfif>
		</cfloop>

		<cfif stResult.redeemed>
			<cfset updateFactorPayload(objectid=stFactor.objectid, stPayload=stFactor.stPayload) />
		</cfif>

		<cfreturn stResult />
	</cffunction>

	<cffunction name="getRecoveryCodesRemaining" access="public" output="false" returntype="numeric" hint="Number of unused recovery codes for a user (0 when none issued)">
		<cfargument name="userKey" type="string" required="true" />
		<cfargument name="userDirectory" type="string" required="true" />

		<cfset var stFactor = getActiveFactor(userKey=arguments.userKey, userDirectory=arguments.userDirectory, factorType="recoveryCode") />
		<cfset var remaining = 0 />
		<cfset var stCode = "" />

		<cfif structIsEmpty(stFactor) or not structKeyExists(stFactor.stPayload, "codes")>
			<cfreturn 0 />
		</cfif>

		<cfloop array="#stFactor.stPayload.codes#" index="stCode">
			<cfif not stCode.used>
				<cfset remaining = remaining + 1 />
			</cfif>
		</cfloop>

		<cfreturn remaining />
	</cffunction>

	<cffunction name="purgeFactors" access="public" output="false" returntype="numeric" hint="HARD-deletes factor rows for a user (every status, history included); returns the number deleted. For intentional purge and cleanup only - removing the owning user record, or discarding a test account. Retiring a factor is revokeFactors: purging also erases the enrolment history hasEverEnrolled reads, after which the account is treated as never enrolled.">
		<cfargument name="userKey" type="string" required="true" />
		<cfargument name="userDirectory" type="string" required="true" />
		<cfargument name="factorType" type="string" required="false" default="" />

		<cfset var qFactors = getFactors(userKey=arguments.userKey, userDirectory=arguments.userDirectory, factorType=arguments.factorType, status="") />
		<cfset var i = 0 />

		<cfloop from="1" to="#qFactors.recordcount#" index="i">
			<cfset delete(objectid=qFactors.objectid[i]) />
		</cfloop>

		<cfreturn qFactors.recordcount />
	</cffunction>


	<!--- status + migration --->

	<cffunction name="getFactorStats" access="public" output="false" returntype="struct" hint="Aggregate active-factor counts for the status page: one figure per factor type, plus the number of distinct users holding an active authentication factor (recovery codes alone are not enrolment). Scoped to a userDirectory when given. Two indexed aggregate queries - no row loading.">
		<cfargument name="userDirectory" type="string" required="false" default="" />

		<cfset var qTypes = "" />
		<cfset var qUsers = "" />
		<cfset var stResult = { totp = 0, passkey = 0, emailOTP = 0, recoveryCode = 0, other = 0, enrolledUsers = 0 } />

		<cfquery datasource="#application.dsn#" name="qTypes">
			SELECT factorType, COUNT(*) AS n
			FROM #application.dbowner#farMFAFactor
			WHERE status = <cfqueryparam cfsqltype="cf_sql_varchar" value="active">
				<cfif len(arguments.userDirectory)>
				AND userDirectory = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userDirectory#">
				</cfif>
			GROUP BY factorType
		</cfquery>

		<cfloop query="qTypes">
			<cfif qTypes.factorType eq "totp">
				<cfset stResult.totp = qTypes.n />
			<cfelseif qTypes.factorType eq "passkey">
				<cfset stResult.passkey = qTypes.n />
			<cfelseif qTypes.factorType eq "recoveryCode">
				<cfset stResult.recoveryCode = qTypes.n />
			<cfelseif qTypes.factorType eq "emailOTP">
				<cfset stResult.emailOTP = qTypes.n />
			<cfelse>
				<cfset stResult.other = stResult.other + qTypes.n />
			</cfif>
		</cfloop>

		<cfquery datasource="#application.dsn#" name="qUsers">
			SELECT COUNT(DISTINCT userKey) AS n
			FROM #application.dbowner#farMFAFactor
			WHERE status = <cfqueryparam cfsqltype="cf_sql_varchar" value="active">
				AND factorType <> <cfqueryparam cfsqltype="cf_sql_varchar" value="recoveryCode">
				<cfif len(arguments.userDirectory)>
				AND userDirectory = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userDirectory#">
				</cfif>
		</cfquery>

		<cfset stResult.enrolledUsers = qUsers.n />
		<cfreturn stResult />
	</cffunction>

	<cffunction name="getOrphanRecoveryCodeSets" access="public" output="false" returntype="query" hint="Active recovery-code sets belonging to a user who holds no active primary factor. The current lifecycle cannot produce this - revoking the last primary factor revokes the set with it - so a row here predates that rule and its hashes should no longer authenticate anything. Scoped to a userDirectory when given.">
		<cfargument name="userDirectory" type="string" required="false" default="" />

		<cfset var qOrphans = "" />

		<cfquery datasource="#application.dsn#" name="qOrphans">
			SELECT r.objectid, r.userKey, r.userDirectory
			FROM #application.dbowner#farMFAFactor r
			WHERE r.status = <cfqueryparam cfsqltype="cf_sql_varchar" value="active">
				AND r.factorType = <cfqueryparam cfsqltype="cf_sql_varchar" value="recoveryCode">
				<cfif len(arguments.userDirectory)>
				AND r.userDirectory = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userDirectory#">
				</cfif>
				AND NOT EXISTS (
					SELECT 1
					FROM #application.dbowner#farMFAFactor p
					WHERE p.userKey = r.userKey
						AND p.userDirectory = r.userDirectory
						AND p.status = <cfqueryparam cfsqltype="cf_sql_varchar" value="active">
						AND p.factorType <> <cfqueryparam cfsqltype="cf_sql_varchar" value="recoveryCode">
				)
			ORDER BY r.objectid
		</cfquery>

		<cfreturn qOrphans />
	</cffunction>

	<cffunction name="revokeOrphanRecoveryCodes" access="public" output="false" returntype="numeric" hint="Revokes and clears every orphaned recovery-code set (see getOrphanRecoveryCodeSets), returning how many were revoked. Idempotent, and it keeps the rows as enrolment history rather than deleting them, so the cleanup does not change how a de-enrolled account is classified.">
		<cfargument name="userDirectory" type="string" required="false" default="" />

		<cfset var qOrphans = getOrphanRecoveryCodeSets(userDirectory=arguments.userDirectory) />
		<cfset var i = 0 />
		<cfset var revoked = 0 />

		<cfloop from="1" to="#qOrphans.recordcount#" index="i">
			<cfset revoked = revoked + revokeFactor(objectid=qOrphans.objectid[i]) />
		</cfloop>

		<cfreturn revoked />
	</cffunction>

	<cffunction name="getTOTPMigrationStats" access="public" output="false" returntype="struct" hint="How many active totp secrets are on the current key vs still need migrating after a rotation, from the indexed keyId column (equality counts; needsMigration is total minus on-current so an unexpected value can never be double-counted).">
		<cfargument name="currentKeyId" type="string" required="true" />
		<cfargument name="userDirectory" type="string" required="false" default="" />

		<cfset var qCounts = "" />
		<cfset var stResult = { total = 0, current = 0, needsMigration = 0 } />

		<cfquery datasource="#application.dsn#" name="qCounts">
			SELECT
				COUNT(*) AS total,
				SUM(CASE WHEN keyId = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.currentKeyId#"> THEN 1 ELSE 0 END) AS oncurrent
			FROM #application.dbowner#farMFAFactor
			WHERE status = <cfqueryparam cfsqltype="cf_sql_varchar" value="active">
				AND factorType = <cfqueryparam cfsqltype="cf_sql_varchar" value="totp">
				<cfif len(arguments.userDirectory)>
				AND userDirectory = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userDirectory#">
				</cfif>
		</cfquery>

		<cfset stResult.total = val(qCounts.total) />
		<cfset stResult.current = val(qCounts.oncurrent) />
		<cfset stResult.needsMigration = stResult.total - stResult.current />
		<cfreturn stResult />
	</cffunction>

	<cffunction name="getActiveTOTPMigrationPage" access="public" output="false" returntype="query" hint="A forward page of active totp factors still needing migration (keyId not the current id), after lastObjectId, ordered by objectid. Keyset pagination: a migrated row's keyId becomes the current id so it drops out, and the cursor advances past any row that errors, so the worker makes forward progress without re-looping.">
		<cfargument name="currentKeyId" type="string" required="true" />
		<cfargument name="userDirectory" type="string" required="true" />
		<cfargument name="lastObjectId" type="string" required="false" default="" />
		<cfargument name="maxRows" type="numeric" required="false" default="200" />

		<cfset var qPage = "" />

		<cfquery datasource="#application.dsn#" name="qPage" maxrows="#arguments.maxRows#">
			SELECT objectid, payload
			FROM #application.dbowner#farMFAFactor
			WHERE status = <cfqueryparam cfsqltype="cf_sql_varchar" value="active">
				AND factorType = <cfqueryparam cfsqltype="cf_sql_varchar" value="totp">
				AND userDirectory = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userDirectory#">
				AND (keyId IS NULL OR keyId <> <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.currentKeyId#">)
				<cfif len(arguments.lastObjectId)>
				AND objectid > <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.lastObjectId#">
				</cfif>
			ORDER BY objectid
		</cfquery>

		<cfreturn qPage />
	</cffunction>


	<!--- ============= Self-test (factor lifecycle; touches the database under a throwaway key, then purges it) ============= --->

	<cffunction name="factorLifecycleSelfTest" access="public" output="false" returntype="struct" hint="Exercises the factor lifecycle end to end against the database using a throwaway user key in a throwaway directory, then purges the fixture: a revoke clears the payload but keeps the enrolment history, revocation is idempotent, the ownership and factor-type constraints hold, exactly one recovery-code set is ever active, and an orphaned set is detected and revoked. Writes only rows it owns (userDirectory SELFTESTUD) and deletes them again. Returns { pass, results }.">

		<cfset var stResult = { pass = true, results = arraynew(1) } />
		<cfset var testKey = "selftest-" & createUUID() />
		<cfset var testDir = "SELFTESTUD" />
		<cfset var totpId = "" />
		<cfset var oldCodesId = "" />
		<cfset var stOld = structnew() />
		<cfset var qRows = "" />
		<cfset var r = "" />

		<cftry>
			<cfset arrayAppend(stResult.results, { name = "unknown user has no enrolment history", pass = (not hasEverEnrolled(userKey=testKey, userDirectory=testDir)) }) />

			<!--- enrol a totp factor --->
			<cfset totpId = createFactor(userKey=testKey, userDirectory=testDir, factorType="totp", stPayload={ secret = "gcm.1.iv.cipher", lastStep = 1 }, label="Authenticator app", keyId="1") />
			<cfset arrayAppend(stResult.results, { name = "new factor is active and counts as enrolment", pass = (hasActiveAuthFactor(userKey=testKey, userDirectory=testDir) and hasStrongAuthFactor(userKey=testKey, userDirectory=testDir) and hasEverEnrolled(userKey=testKey, userDirectory=testDir)) }) />

			<!--- issue, then re-issue, a recovery-code set --->
			<cfset saveRecoveryCodes(userKey=testKey, userDirectory=testDir, aHashes=["hashA", "hashB"]) />
			<cfset oldCodesId = getActiveFactor(userKey=testKey, userDirectory=testDir, factorType="recoveryCode").objectid />
			<cfset arrayAppend(stResult.results, { name = "recovery codes issued (2 remaining)", pass = (getRecoveryCodesRemaining(userKey=testKey, userDirectory=testDir) eq 2) }) />

			<cfset saveRecoveryCodes(userKey=testKey, userDirectory=testDir, aHashes=["hashC"]) />
			<cfset qRows = getFactors(userKey=testKey, userDirectory=testDir, factorType="recoveryCode", status="active") />
			<cfset stOld = getData(objectid=oldCodesId) />
			<cfset arrayAppend(stResult.results, { name = "re-issue leaves exactly one active set", pass = (qRows.recordcount eq 1 and getRecoveryCodesRemaining(userKey=testKey, userDirectory=testDir) eq 1) }) />
			<cfset arrayAppend(stResult.results, { name = "superseded set is revoked with its hashes cleared", pass = (stOld.status eq "revoked" and not len(stOld.payload)) }) />

			<!--- ownership and factor-type constraints on a single revoke --->
			<cfset arrayAppend(stResult.results, { name = "revoke refused for another user's objectid", pass = (not revokeFactorForUser(objectid=totpId, userKey="selftest-other-" & createUUID(), userDirectory=testDir)) }) />
			<cfset arrayAppend(stResult.results, { name = "revoke refused when the factor type does not match", pass = (not revokeFactorForUser(objectid=totpId, userKey=testKey, userDirectory=testDir, factorType="passkey")) }) />
			<cfset arrayAppend(stResult.results, { name = "refused revokes left the factor active", pass = hasActiveAuthFactor(userKey=testKey, userDirectory=testDir) }) />

			<!--- revoke the only primary factor --->
			<cfset arrayAppend(stResult.results, { name = "owned revoke of the matching type succeeds", pass = revokeFactorForUser(objectid=totpId, userKey=testKey, userDirectory=testDir, factorType="totp") }) />
			<cfset stOld = getData(objectid=totpId) />
			<cfset arrayAppend(stResult.results, { name = "revoked factor keeps no secret or key id", pass = (stOld.status eq "revoked" and not len(stOld.payload) and not len(stOld.keyId)) }) />
			<cfset arrayAppend(stResult.results, { name = "de-enrolled, but the enrolment history remains", pass = (not hasActiveAuthFactor(userKey=testKey, userDirectory=testDir) and hasEverEnrolled(userKey=testKey, userDirectory=testDir)) }) />
			<cfset arrayAppend(stResult.results, { name = "bulk revoke is idempotent over revoked history", pass = (revokeFactors(userKey=testKey, userDirectory=testDir, factorType="totp") eq 0) }) />

			<!--- the recovery set is now orphaned: this exercises storage directly, so the directory's last-factor cascade never ran --->
			<cfset qRows = getOrphanRecoveryCodeSets(userDirectory=testDir) />
			<cfset arrayAppend(stResult.results, { name = "orphaned recovery set detected", pass = (qRows.recordcount eq 1) }) />
			<cfset arrayAppend(stResult.results, { name = "orphaned recovery set revoked", pass = (revokeOrphanRecoveryCodes(userDirectory=testDir) eq 1 and getOrphanRecoveryCodeSets(userDirectory=testDir).recordcount eq 0 and getRecoveryCodesRemaining(userKey=testKey, userDirectory=testDir) eq 0) }) />
			<cfset arrayAppend(stResult.results, { name = "orphan sweep is idempotent", pass = (revokeOrphanRecoveryCodes(userDirectory=testDir) eq 0) }) />

			<cfcatch>
				<cfset arrayAppend(stResult.results, { name = "self-test threw: #cfcatch.message#", pass = false }) />
			</cfcatch>
		</cftry>

		<!--- purge the fixture: the one place a hard delete is the right call --->
		<cfset purgeFactors(userKey=testKey, userDirectory=testDir) />
		<cfset arrayAppend(stResult.results, { name = "fixture purged (history gone)", pass = (not hasEverEnrolled(userKey=testKey, userDirectory=testDir)) }) />

		<cfloop array="#stResult.results#" index="r">
			<cfif not r.pass><cfset stResult.pass = false /></cfif>
		</cfloop>

		<cfreturn stResult />
	</cffunction>

</cfcomponent>
