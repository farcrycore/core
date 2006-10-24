<cfcomponent name="dbutilsgateway">

<cffunction name="init" access="public" output="false" returntype="any" hint="Initialisation method.">
	<cfargument name="dsn" required="true" type="string" />
	<cfargument name="dbtype" required="true" type="string" />
	<cfargument name="dbowner" required="true" type="string" />
	
	<cfset var dbutils="" />
	
	<cfset variables.dsn = arguments.dsn />
	<cfset variables.dbtype = arguments.dbtype />
	<cfset variables.dbowner = arguments.dbowner />

	<cfswitch expression="#arguments.dbtype#">
		
		<cfcase value="postgresql">
			<cfset dbutils=createobject("component", "postgresql").init(arguments.dsn) />
		</cfcase>
		
		<cfdefaultcase>
			<cfthrow detail="Not yet implemented for #arguments.dbtype#" />
		</cfdefaultcase>
	</cfswitch>
	
	<cfreturn dbutils />
</cffunction>

</cfcomponent>