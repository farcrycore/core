<cfcomponent displayname="AWS Credentials: environment" hint="Reads credentials from AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY (+ optional AWS_SESSION_TOKEN and AWS_CREDENTIAL_EXPIRATION). Enables keyless local development with SSO/STS-exported temporary credentials." output="false" persistent="false">

	<cfset this.id = "environment" />

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
		<cfset var keyId = this.system.getenv("AWS_ACCESS_KEY_ID") ?: "" />
		<cfset var secret = this.system.getenv("AWS_SECRET_ACCESS_KEY") ?: "" />
		<cfreturn len(keyId) and len(secret) />
	</cffunction>

	<cffunction name="resolve" returntype="struct" output="false">
		<cfargument name="definition" type="struct" required="true" />

		<cfset var keyId = this.system.getenv("AWS_ACCESS_KEY_ID") ?: "" />
		<cfset var secret = this.system.getenv("AWS_SECRET_ACCESS_KEY") ?: "" />
		<cfset var token = this.system.getenv("AWS_SESSION_TOKEN") ?: "" />
		<cfset var expRaw = this.system.getenv("AWS_CREDENTIAL_EXPIRATION") ?: "" />
		<cfset var exp = len(expRaw) ? this.resolver.parseAWSExpiration(expRaw) : "" />

		<!--- Temporary env credentials cannot self-refresh inside a container (the refresh source -
		      the SSO token - lives on the host). Surface an explicit, actionable error rather than a 403. --->
		<cfif isDate(exp) and dateCompare(now(), exp) gte 0>
			<cfset application.fapi.throw(message="Temporary AWS credentials in the environment have expired (AWS_CREDENTIAL_EXPIRATION={1}). Re-export them (e.g. aws configure export-credentials --format env) and restart.",type="awscredentialserror",substituteValues=[ expRaw ]) />
		</cfif>

		<cfreturn {
			"accessKeyId" = trim(keyId),
			"secretAccessKey" = trim(secret),
			"sessionToken" = trim(token),
			"expiration" = exp,
			"source" = this.id
		} />
	</cffunction>

</cfcomponent>
