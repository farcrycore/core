<cfcomponent displayname="AWS Credentials" hint="SDK-free AWS credential resolver. Resolves and caches (auto-refreshing) credentials for named credential sets via an ordered, pluggable provider chain. Long-lived keys resolve to a never-expiring static entry; temporary credentials (with a session token) are refreshed before they expire. Pure cfhttp/JSON - no AWS SDK." output="false" persistent="false">

	<cfset this.cache = structnew() />
	<cfset this.credentialSets = structnew() />
	<cfset this.providers = structnew() />
	<cfset this.providerOrder = structnew() />
	<cfset this.refreshMarginSeconds = 600 />

	<cffunction name="init" returntype="any" output="false">
		<cfargument name="cdn" type="any" required="false" />
		<cfargument name="engine" type="string" required="false" default="unknown" />

		<cfset var sys = createobject("java","java.lang.System") />
		<cfset var margin = sys.getenv("FARCRY_CDN_CRED_REFRESH_MARGIN_SECONDS") ?: "" />

		<cfif structkeyexists(arguments,"cdn")>
			<cfset this.cdn = arguments.cdn />
		</cfif>
		<cfset this.engine = arguments.engine />
		<cfset this.cache = structnew() />
		<cfset this.credentialSets = structnew() />

		<!--- refresh safety margin: renew this many seconds before expiry --->
		<cfif isNumeric(margin) and margin gt 0>
			<cfset this.refreshMarginSeconds = margin />
		</cfif>

		<cfset buildProviders() />

		<cfreturn this />
	</cffunction>

	<cffunction name="buildProviders" access="private" output="false" returntype="void" hint="Instantiates the built-in provider chain and the source->provider ordering. Single seam: providers are kept static here (consistent with lib/ plumbing); relocating them to a discoverable packages/awscredentials/ type later would replace only this method.">
		<!--- provider instances (Phase 1: static, environment, container, EC2 IMDSv2) --->
		<cfset this.providers = structnew() />
		<cfset this.providers["static"] = createobject("component","farcry.core.packages.lib.awscredentials.staticProvider").init(resolver=this,engine=this.engine) />
		<cfset this.providers["environment"] = createobject("component","farcry.core.packages.lib.awscredentials.environmentProvider").init(resolver=this,engine=this.engine) />
		<cfset this.providers["container"] = createobject("component","farcry.core.packages.lib.awscredentials.containerEndpointProvider").init(resolver=this,engine=this.engine) />
		<cfset this.providers["instanceProfile"] = createobject("component","farcry.core.packages.lib.awscredentials.instanceProfileProvider").init(resolver=this,engine=this.engine) />

		<!--- credential source -> ordered list of provider ids to try --->
		<cfset this.providerOrder = {
			"auto" = [ "static", "environment", "container", "instanceProfile" ],
			"role" = [ "container", "instanceProfile" ],
			"static" = [ "static" ],
			"environment" = [ "environment" ],
			"env" = [ "environment" ],
			"container" = [ "container" ],
			"ecs" = [ "container" ],
			"instanceprofile" = [ "instanceProfile" ],
			"imds" = [ "instanceProfile" ],
			"ec2" = [ "instanceProfile" ]
		} />
	</cffunction>

	<cffunction name="registerCredentialSet" returntype="void" output="false" hint="Declares a named credential set (lazy - no resolution happens here). Idempotent.">
		<cfargument name="name" type="string" required="true" />
		<cfargument name="definition" type="struct" required="true" />

		<cfset var key = lcase(trim(arguments.name)) />
		<cfset var def = duplicate(arguments.definition) />

		<cfif not structkeyexists(def,"source") or not len(trim(def.source))>
			<cfset def.source = "auto" />
		</cfif>
		<cfset def.source = lcase(trim(def.source)) />

		<cfset this.credentialSets[key] = def />
	</cffunction>

	<cffunction name="hasCredentialSet" returntype="boolean" output="false">
		<cfargument name="name" type="string" required="true" />
		<cfreturn structkeyexists(this.credentialSets, lcase(trim(arguments.name))) />
	</cffunction>

	<cffunction name="isKnownSource" returntype="boolean" output="false" hint="True when the credential source is supported by this build (i.e. has a provider chain).">
		<cfargument name="source" type="string" required="true" />
		<cfreturn structkeyexists(this.providerOrder, lcase(trim(arguments.source))) />
	</cffunction>

	<cffunction name="getCredentials" returntype="struct" output="false" hint="Returns live credentials for a named set: cached-if-fresh, otherwise refreshed under an exclusive per-set lock.">
		<cfargument name="setName" type="string" required="true" />

		<cfset var key = lcase(trim(arguments.setName)) />
		<cfset var lockName = "" />
		<cfset var def = "" />
		<cfset var fresh = "" />

		<cfif not structkeyexists(this.credentialSets, key)>
			<cfset application.fapi.throw(message="AWS credential set [{1}] is not registered",type="awscredentialserror",substituteValues=[ arguments.setName ]) />
		</cfif>

		<!--- fast path: lock-free read of a fresh entry --->
		<cfif structkeyexists(this.cache, key) and isFresh(this.cache[key])>
			<cfreturn this.cache[key].creds />
		</cfif>

		<cfset def = this.credentialSets[key] />
		<cfset lockName = "awscreds_" & key & "_" & application.applicationname />

		<cflock name="#lockName#" type="exclusive" timeout="30">
			<!--- double-check inside the lock --->
			<cfif structkeyexists(this.cache, key) and isFresh(this.cache[key])>
				<cfreturn this.cache[key].creds />
			</cfif>

			<cftry>
				<cfset fresh = resolveOnce(def) />
				<cfset this.cache[key] = {
					"creds" = fresh,
					"fetchedAt" = now(),
					"expiration" = fresh.expiration,
					"lastError" = ""
				} />
				<cfreturn fresh />

				<cfcatch>
					<!--- serve still-present cached creds through a transient refresh failure --->
					<cfif structkeyexists(this.cache, key)>
						<cfset this.cache[key].lastError = cfcatch.message />
						<cflog file="awscredentials" application="true" type="warning" text="AWS credential refresh failed for set [#key#]; serving cached credentials: #cfcatch.message#" />
						<cfreturn this.cache[key].creds />
					<cfelse>
						<cfset application.fapi.throw(message="Unable to resolve AWS credentials for set [{1}] (source={2}): {3}",type="awscredentialserror",detail=serializeJSON(sanitiseDefinition(def)),substituteValues=[ arguments.setName, def.source, cfcatch.message ]) />
					</cfif>
				</cfcatch>
			</cftry>
		</cflock>
	</cffunction>

	<cffunction name="resolveOnce" returntype="struct" output="false" hint="Runs the provider chain for a definition once and returns the first successful credentials. Throws if none resolve.">
		<cfargument name="definition" type="struct" required="true" />

		<cfset var source = structkeyexists(arguments.definition,"source") ? lcase(trim(arguments.definition.source)) : "auto" />
		<cfset var order = structkeyexists(this.providerOrder, source) ? this.providerOrder[source] : "" />
		<cfset var i = 0 />
		<cfset var pid = "" />
		<cfset var provider = "" />
		<cfset var creds = "" />
		<cfset var tried = "" />

		<cfif not isArray(order)>
			<cfset application.fapi.throw(message="Unknown AWS credential source [{1}]. Supported in this build: auto, role, static, environment, container, instanceProfile.",type="awscredentialserror",substituteValues=[ source ]) />
		</cfif>

		<cfloop from="1" to="#arraylen(order)#" index="i">
			<cfset pid = order[i] />
			<cfif not structkeyexists(this.providers, pid)>
				<cfcontinue />
			</cfif>
			<cfset provider = this.providers[pid] />
			<cfset tried = listappend(tried, pid) />
			<cfif provider.canResolve(arguments.definition)>
				<cfset creds = provider.resolve(arguments.definition) />
				<cfif isStruct(creds) and structkeyexists(creds,"accessKeyId") and len(creds.accessKeyId)>
					<cfreturn normaliseCreds(creds, pid) />
				</cfif>
			</cfif>
		</cfloop>

		<cfset application.fapi.throw(message="No AWS credential provider could resolve set (source={1}; providers tried={2})",type="awscredentialserror",substituteValues=[ source, tried ]) />
	</cffunction>

	<cffunction name="normaliseCreds" returntype="struct" output="false" access="private">
		<cfargument name="creds" type="struct" required="true" />
		<cfargument name="source" type="string" required="true" />

		<cfreturn {
			"accessKeyId" = arguments.creds.accessKeyId,
			"secretAccessKey" = structkeyexists(arguments.creds,"secretAccessKey") ? arguments.creds.secretAccessKey : "",
			"sessionToken" = structkeyexists(arguments.creds,"sessionToken") ? arguments.creds.sessionToken : "",
			"expiration" = structkeyexists(arguments.creds,"expiration") ? arguments.creds.expiration : "",
			"source" = (structkeyexists(arguments.creds,"source") and len(arguments.creds.source)) ? arguments.creds.source : arguments.source
		} />
	</cffunction>

	<cffunction name="isFresh" returntype="boolean" output="false" access="private">
		<cfargument name="entry" type="struct" required="true" />

		<cfset var marginMinutes = this.refreshMarginSeconds / 60 />

		<!--- No usable expiry means either a long-lived static/env key or env-supplied temporary
		      credentials with no expiry hint. In both cases the value is fixed for the life of the
		      process (there is no in-process refresh source to improve on), so treat it as fresh and
		      avoid taking the refresh lock on every request. Providers that issue genuinely
		      time-limited credentials (container endpoint, IMDS) always return an Expiration. --->
		<cfif not isDate(arguments.entry.expiration)>
			<cfreturn true />
		</cfif>
		<cfreturn dateDiff("n", now(), arguments.entry.expiration) gt marginMinutes />
	</cffunction>

	<cffunction name="parseAWSExpiration" returntype="any" output="false" hint="Parses an ISO-8601 UTC timestamp (e.g. 2026-06-19T13:45:00Z) into a local CF datetime. Returns an empty string if blank or unparseable.">
		<cfargument name="iso" type="string" required="true" />

		<cfset var s = trim(arguments.iso) />

		<cfif not len(s)>
			<cfreturn "" />
		</cfif>
		<cfset s = reReplace(s, "\.\d+Z$", "Z") />
		<cfset s = replace(s, "T", " ") />
		<cfset s = replace(s, "Z", "") />
		<cftry>
			<cfreturn dateConvert("utc2local", parseDateTime(trim(s))) />
			<cfcatch><cfreturn "" /></cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="describe" returntype="struct" output="false" hint="Non-secret snapshot of a credential set's cache state. Never returns the secret key or session token.">
		<cfargument name="setName" type="string" required="true" />

		<cfset var key = lcase(trim(arguments.setName)) />
		<cfset var def = structkeyexists(this.credentialSets, key) ? this.credentialSets[key] : structnew() />
		<cfset var entry = structkeyexists(this.cache, key) ? this.cache[key] : "" />
		<cfset var out = {
			"name" = arguments.setName,
			"registered" = structkeyexists(this.credentialSets, key),
			"source" = structkeyexists(def,"source") ? def.source : "",
			"region" = structkeyexists(def,"region") ? def.region : "",
			"cached" = isStruct(entry),
			"hasSessionToken" = false,
			"expiration" = "",
			"secondsRemaining" = "",
			"lastError" = "",
			"resolvedSource" = ""
		} />

		<cfif isStruct(entry)>
			<cfset out.hasSessionToken = (len(entry.creds.sessionToken) gt 0) />
			<cfset out.expiration = entry.expiration />
			<cfset out.lastError = entry.lastError />
			<cfset out.resolvedSource = structkeyexists(entry.creds,"source") ? entry.creds.source : "" />
			<cfif isDate(entry.expiration)>
				<cfset out.secondsRemaining = dateDiff("s", now(), entry.expiration) />
			</cfif>
		</cfif>

		<cfreturn out />
	</cffunction>

	<cffunction name="sanitiseDefinition" returntype="struct" output="false" access="private" hint="Masks secrets in a credential-set definition for safe logging / error detail.">
		<cfargument name="definition" type="struct" required="true" />

		<cfset var out = duplicate(arguments.definition) />

		<cfif structkeyexists(out,"secretAccessKey") and len(out.secretAccessKey)><cfset out.secretAccessKey = "STRIPPED" /></cfif>
		<cfif structkeyexists(out,"sessionToken") and len(out.sessionToken)><cfset out.sessionToken = "STRIPPED" /></cfif>
		<cfif structkeyexists(out,"accessKeyId") and len(out.accessKeyId)><cfset out.accessKeyId = "STRIPPED" /></cfif>

		<cfreturn out />
	</cffunction>

</cfcomponent>
