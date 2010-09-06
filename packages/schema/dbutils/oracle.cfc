<cfcomponent name="oracle" extends="dbutils" hint="Oracle database utilities.">

<cffunction name="init" access="public" returntype="oracle" output="false" hint="Initialisation method.">
	<cfargument name="dsn" required="true" type="string" />
	<cfset variables.dsn=arguments.dsn />	
	<cfset variables.dbtype="ora" />
	<cfreturn this />
</cffunction>

</cfcomponent>