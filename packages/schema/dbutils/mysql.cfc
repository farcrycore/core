<cfcomponent name="mysql" extends="dbutils" hint="mySQL database utilities.">

<cffunction name="init" access="public" returntype="mysql" output="false" hint="Initialisation method.">
	<cfargument name="dsn" required="true" type="string" />
	<cfset variables.dsn=arguments.dsn />	
	<cfset variables.dbtype="mysql" />
	<cfreturn this />
</cffunction>

</cfcomponent>