<cfcomponent name="mssql" extends="dbutils" hint="MS SQL database utilities.">

<cffunction name="init" access="public" returntype="mssql" output="false" hint="Initialisation method.">
	<cfargument name="dsn" required="true" type="string" />
	<cfset variables.dsn=arguments.dsn />	
	<cfset variables.dbtype="mssql" />
	<cfreturn this />
</cffunction>

</cfcomponent>