<cfcomponent
	displayname="MFA Factor"
	hint="Enrolled multi-factor authentication factors, keyed by a stable directory-scoped user key plus the owning user directory. Directory-agnostic storage for credential-owning user directories; secrets in the payload are encrypted by the caller before they reach this type. See docs/0014."
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
		ftType="string"
		hint="totp / recoveryCodes (passkey and emailOTP in later phases)">

	<cfproperty name="status" type="string" default="active"
		ftSeq="4" ftFieldset="" ftLabel="Status"
		ftType="string"
		hint="active / revoked">

	<cfproperty name="payload" type="longchar" default=""
		ftSeq="5" ftFieldset="" ftLabel="Payload"
		ftType="longchar"
		hint="Per-type JSON payload; secret material is encrypted at rest by the caller">

	<cfproperty name="lastUsed" type="date"
		ftSeq="6" ftFieldset="" ftLabel="Last used"
		ftType="datetime"
		hint="When this factor last verified successfully">


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
			ORDER BY datetimecreated
		</cfquery>

		<cfreturn qFactors />
	</cffunction>

	<cffunction name="hasActiveAuthFactor" access="public" output="false" returntype="boolean" hint="True when the user has an active authentication factor (recovery codes alone do not count as enrolment)">
		<cfargument name="userKey" type="string" required="true" />
		<cfargument name="userDirectory" type="string" required="true" />

		<cfset var qFactors = getFactors(userKey=arguments.userKey, userDirectory=arguments.userDirectory) />
		<cfset var i = 0 />

		<cfloop from="1" to="#qFactors.recordcount#" index="i">
			<cfif qFactors.factorType[i] neq "recoveryCodes">
				<cfreturn true />
			</cfif>
		</cfloop>

		<cfreturn false />
	</cffunction>

	<cffunction name="createFactor" access="public" output="false" returntype="string" hint="Creates a factor row and returns its objectid. The payload must already have secret material encrypted.">
		<cfargument name="userKey" type="string" required="true" />
		<cfargument name="userDirectory" type="string" required="true" />
		<cfargument name="factorType" type="string" required="true" />
		<cfargument name="stPayload" type="struct" required="true" />
		<cfargument name="label" type="string" required="false" default="" />

		<cfset var stObj = structnew() />

		<cfset stObj.objectid = application.fc.utils.createJavaUUID() />
		<cfset stObj.userKey = arguments.userKey />
		<cfset stObj.userDirectory = arguments.userDirectory />
		<cfset stObj.factorType = arguments.factorType />
		<cfset stObj.status = "active" />
		<cfset stObj.payload = serializeJSON(arguments.stPayload) />
		<cfset stObj.label = arguments.label />

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

	<cffunction name="updateFactorPayload" access="public" output="false" returntype="void" hint="Replaces a factor payload and stamps lastUsed">
		<cfargument name="objectid" type="uuid" required="true" />
		<cfargument name="stPayload" type="struct" required="true" />

		<cfset var stObj = getData(objectid=arguments.objectid) />

		<cfif not structIsEmpty(stObj)>
			<cfset stObj.payload = serializeJSON(arguments.stPayload) />
			<cfset stObj.lastUsed = now() />
			<cfset setData(stProperties=stObj, bAudit=false) />
		</cfif>
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

	<cffunction name="removeFactorForUser" access="public" output="false" returntype="boolean" hint="Deletes one factor row, but only when it belongs to the given user (guards a forged objectid from removing another user's factor). Returns true when a row was removed.">
		<cfargument name="objectid" type="uuid" required="true" />
		<cfargument name="userKey" type="string" required="true" />
		<cfargument name="userDirectory" type="string" required="true" />

		<cfset var stObj = getData(objectid=arguments.objectid) />

		<cfif not structIsEmpty(stObj) and structKeyExists(stObj, "userKey") and stObj.userKey eq arguments.userKey and stObj.userDirectory eq arguments.userDirectory>
			<cfset delete(objectid=arguments.objectid) />
			<cfreturn true />
		</cfif>

		<cfreturn false />
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

		<cfset removeFactors(userKey=arguments.userKey, userDirectory=arguments.userDirectory, factorType="recoveryCodes") />
		<cfset createFactor(userKey=arguments.userKey, userDirectory=arguments.userDirectory, factorType="recoveryCodes", stPayload={ codes = aCodes }, label="Recovery codes") />
	</cffunction>

	<cffunction name="redeemRecoveryCode" access="public" output="false" returntype="struct" hint="Attempts to redeem a single-use recovery code; marks it used on success">
		<cfargument name="userKey" type="string" required="true" />
		<cfargument name="userDirectory" type="string" required="true" />
		<cfargument name="code" type="string" required="true" />

		<cfset var stResult = { redeemed = false, remaining = 0 } />
		<cfset var stFactor = getActiveFactor(userKey=arguments.userKey, userDirectory=arguments.userDirectory, factorType="recoveryCodes") />
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

		<cfset var stFactor = getActiveFactor(userKey=arguments.userKey, userDirectory=arguments.userDirectory, factorType="recoveryCodes") />
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

	<cffunction name="removeFactors" access="public" output="false" returntype="numeric" hint="Deletes factor rows for a user (all statuses); returns the number removed">
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

</cfcomponent>
