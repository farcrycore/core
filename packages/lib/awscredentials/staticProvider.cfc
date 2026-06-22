<cfcomponent displayname="AWS Credentials: static" hint="Returns explicitly-configured long-lived (or pre-supplied temporary) credentials. This is the backward-compatibility provider for classic accessKeyId/awsSecretKey configs." output="false" persistent="false">

	<cfset this.id = "static" />

	<cffunction name="init" returntype="any" output="false">
		<cfargument name="resolver" type="any" required="true" />
		<cfargument name="engine" type="string" required="false" default="unknown" />
		<cfset this.resolver = arguments.resolver />
		<cfset this.engine = arguments.engine />
		<cfreturn this />
	</cffunction>

	<cffunction name="canResolve" returntype="boolean" output="false">
		<cfargument name="definition" type="struct" required="true" />
		<cfreturn structkeyexists(arguments.definition,"accessKeyId") and len(trim(arguments.definition.accessKeyId))
			and structkeyexists(arguments.definition,"secretAccessKey") and len(trim(arguments.definition.secretAccessKey)) />
	</cffunction>

	<cffunction name="resolve" returntype="struct" output="false">
		<cfargument name="definition" type="struct" required="true" />
		<cfreturn {
			"accessKeyId" = trim(arguments.definition.accessKeyId),
			"secretAccessKey" = trim(arguments.definition.secretAccessKey),
			"sessionToken" = structkeyexists(arguments.definition,"sessionToken") ? trim(arguments.definition.sessionToken) : "",
			"expiration" = "",
			"source" = this.id
		} />
	</cffunction>

</cfcomponent>
