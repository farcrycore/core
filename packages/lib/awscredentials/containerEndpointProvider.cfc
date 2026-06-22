<cfcomponent displayname="AWS Credentials: container endpoint" hint="Fetches ECS/Fargate task-role (or EKS Pod Identity) credentials from the container credentials endpoint: AWS_CONTAINER_CREDENTIALS_RELATIVE_URI via 169.254.170.2, or AWS_CONTAINER_CREDENTIALS_FULL_URI with an authorization token. This is the primary production path on ECS Fargate." output="false" persistent="false">

	<cfset this.id = "container" />

	<cffunction name="init" returntype="any" output="false">
		<cfargument name="resolver" type="any" required="true" />
		<cfargument name="engine" type="string" required="false" default="unknown" />
		<cfset this.resolver = arguments.resolver />
		<cfset this.engine = arguments.engine />
		<cfset this.system = createobject("java","java.lang.System") />
		<cfreturn this />
	</cffunction>

	<cffunction name="canResolve" returntype="boolean" output="false">
		<cfargument name="definition" type="struct" required="true" />
		<cfset var rel = this.system.getenv("AWS_CONTAINER_CREDENTIALS_RELATIVE_URI") ?: "" />
		<cfset var full = this.system.getenv("AWS_CONTAINER_CREDENTIALS_FULL_URI") ?: "" />
		<cfreturn len(rel) or len(full) />
	</cffunction>

	<cffunction name="resolve" returntype="struct" output="false">
		<cfargument name="definition" type="struct" required="true" />

		<cfset var rel = this.system.getenv("AWS_CONTAINER_CREDENTIALS_RELATIVE_URI") ?: "" />
		<cfset var full = this.system.getenv("AWS_CONTAINER_CREDENTIALS_FULL_URI") ?: "" />
		<cfset var endpoint = "" />
		<cfset var authToken = "" />
		<cfset var tokenFile = "" />
		<cfset var httpResp = "" />
		<cfset var data = "" />
		<cfset var exp = "" />

		<cfif len(rel)>
			<cfset endpoint = "http://169.254.170.2" & rel />
		<cfelse>
			<!--- full URI: SSRF guard - only loopback / link-local hosts, or https --->
			<cfif not isAllowedFullURI(full)>
				<cfset application.fapi.throw(message="Refusing AWS_CONTAINER_CREDENTIALS_FULL_URI [{1}]: host is not loopback/link-local and scheme is not https",type="awscredentialserror",substituteValues=[ full ]) />
			</cfif>
			<cfset endpoint = full />
			<cfset authToken = this.system.getenv("AWS_CONTAINER_AUTHORIZATION_TOKEN") ?: "" />
			<cfset tokenFile = this.system.getenv("AWS_CONTAINER_AUTHORIZATION_TOKEN_FILE") ?: "" />
			<!--- read the token file every refresh - some platforms rotate it --->
			<cfif not len(authToken) and len(tokenFile) and fileExists(tokenFile)>
				<cfset authToken = trim(fileRead(tokenFile)) />
			</cfif>
		</cfif>

		<cfhttp method="GET" url="#endpoint#" result="httpResp" timeout="5" charset="utf-8">
			<cfif len(authToken)>
				<cfhttpparam type="header" name="Authorization" value="#authToken#" />
			</cfif>
		</cfhttp>

		<cfif not isStruct(httpResp) or not structkeyexists(httpResp,"statuscode") or listfirst(httpResp.statuscode," ") neq "200">
			<cfset application.fapi.throw(message="Container credentials endpoint returned [{1}]",type="awscredentialserror",substituteValues=[ (isStruct(httpResp) and structkeyexists(httpResp,"statuscode")) ? httpResp.statuscode : "no response" ]) />
		</cfif>
		<cfif not isJSON(httpResp.fileContent)>
			<cfset application.fapi.throw(message="Container credentials endpoint returned a non-JSON response",type="awscredentialserror") />
		</cfif>

		<cfset data = deserializeJSON(httpResp.fileContent) />
		<cfif not (structkeyexists(data,"AccessKeyId") and structkeyexists(data,"SecretAccessKey") and structkeyexists(data,"Token"))>
			<cfset application.fapi.throw(message="Container credentials response is missing required fields (AccessKeyId/SecretAccessKey/Token)",type="awscredentialserror") />
		</cfif>

		<cfset exp = structkeyexists(data,"Expiration") ? this.resolver.parseAWSExpiration(data.Expiration) : "" />
		<!--- These credentials are always time-limited; if AWS omits or returns an unparseable
		      Expiration, fall back to a short TTL so the cache refreshes soon rather than pinning them. --->
		<cfif not isDate(exp)>
			<cfset exp = dateAdd("n", 15, now()) />
		</cfif>

		<cfreturn {
			"accessKeyId" = data.AccessKeyId,
			"secretAccessKey" = data.SecretAccessKey,
			"sessionToken" = data.Token,
			"expiration" = exp,
			"source" = this.id
		} />
	</cffunction>

	<cffunction name="isAllowedFullURI" returntype="boolean" output="false" access="private">
		<cfargument name="uri" type="string" required="true" />

		<cfset var host = "" />

		<cfif refindnocase("^https://", arguments.uri)>
			<cfreturn true />
		</cfif>
		<cfset host = reReplaceNoCase(arguments.uri, "^https?://([^/:]+).*$", "\1") />
		<cfreturn host eq "localhost" or host eq "127.0.0.1" or left(host,8) eq "169.254." or host eq "::1" />
	</cffunction>

</cfcomponent>
