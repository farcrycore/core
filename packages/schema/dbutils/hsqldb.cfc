<cfcomponent name="hsqldb" extends="dbutils" hint="HSQLDB database utilities.">

	<cffunction name="init" access="public" returntype="hsqldb" output="false" hint="Initialisation method.">
		<cfargument name="dsn" required="true" type="string" />
		
		<cfset variables.dsn = arguments.dsn />	
		<cfset variables.dbtype = "HSQLDB" />
		
		<cfreturn this />
	</cffunction>

</cfcomponent>