<cfcomponent name="postgresql" extends="dbutils" hint="Postgresql database utilities.">

<cffunction name="init" access="public" returntype="postgresql" output="false" hint="Initialisation method.">
	<cfargument name="dsn" required="true" type="string" />
	<cfset variables.dsn=arguments.dsn />	
	<cfset variables.dbtype="postgresql" />
	<cfreturn this />
</cffunction>

<cffunction name="checkTableExists" access="public" hint="Checks for the existence of a table." returntype="boolean">
	<cfargument name="tablename" required="true" type="string" />
	
	<cfset var qcheck=queryNew("tblExists") />
	<cfset var breturn="false" />
	
	<cfquery datasource="#variables.dsn#" name="qCheck">
	SELECT count(*) AS tblExists
	FROM   PG_TABLES
	WHERE  TABLENAME = '#arguments.tablename#'
	AND    SCHEMANAME = 'public'
	</cfquery>

	<cfif qCheck.tblexists>
		<cfset bReturn="true" />
	</cfif>
	
	<cfreturn bReturn />
</cffunction>

</cfcomponent>