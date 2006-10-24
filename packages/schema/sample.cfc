<cfcomponent name="sample">

<cffunction name="init" access="public" output="false" returntype="sample" hint="Initialisation function.">
	<cfargument name="dsn" required="true" type="string" />
	<cfargument name="dbtype" required="true" type="string" />
	<cfargument name="dbowner" required="true" type="string" />
	
	<cfset variables.tablename = "sample" />
	<cfset variables.dsn = arguments.dsn />
	<cfset variables.dbtype = arguments.dbtype />
	<cfset variables.dbowner = arguments.dbowner />

	<cfset variables.dbutils = createobject("component", "dbutils.dbutilsfactory").init(dsn=arguments.dsn, dbtype=arguments.dbtype, dbowner=arguments.dbowner) />
	
	<cfreturn this />
	
</cffunction>

<cffunction name="createTable" access="public" output="false" returntype="struct" hint="Create table.">
	<cfargument name="bDropTable" default="true" type="boolean" hint="Flag to drop table before creating." />
	<cfset var stReturn = structNew() />

	<cfswitch expression="#variables.dbtype#">
		<cfcase value="postgresql">
			<cfset streturn = createTablePostgresql(argumentcollection=arguments) />
		</cfcase>
		
		<cfcase value="mysql,mysql5">
			<cfset streturn = createTableMySQL(argumentcollection=arguments) />
		</cfcase>
		
		<cfcase value="ora, oracle">
			<cfset streturn = createTableOracle(argumentcollection=arguments) />
		</cfcase>

		<cfdefaultcase>
			<cfthrow detail="Create sample: #variables.dbtype# not yet implemented.">
		</cfdefaultcase>
	</cfswitch>
	
	<cfreturn streturn />
</cffunction>

<cffunction name="createTablePostgresql" access="public" output="false" returntype="struct" hint="Create table; postgresql.">
	<cfargument name="bDropTable" default="true" type="boolean" hint="Flag to drop table before creating." />
	<cfset var stReturn = structNew() />
	

	<cfreturn stReturn />
</cffunction>

<cffunction name="createTableMySQL" access="public" output="false" returntype="struct" hint="Create table; MySQL.">
	<cfargument name="bDropTable" default="true" type="boolean" hint="Flag to drop table before creating." />
	<cfset var stReturn = structNew() />
	

	<cfreturn stReturn />
</cffunction>

<cffunction name="createTableMSSQL" access="public" output="false" returntype="struct" hint="Create table; MSSQL.">
	<cfargument name="bDropTable" default="true" type="boolean" hint="Flag to drop table before creating." />
	<cfset var stReturn = structNew() />
	

	<cfreturn stReturn />
</cffunction>

<cffunction name="createTableOracle" access="public" output="false" returntype="struct" hint="Create table; Oracle.">
	<cfargument name="bDropTable" default="true" type="boolean" hint="Flag to drop table before creating." />
	<cfset var stReturn = structNew() />
	

	<cfreturn stReturn />
</cffunction>

</cfcomponent>