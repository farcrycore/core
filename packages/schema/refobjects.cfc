<cfcomponent name="refobjects">

<cffunction name="init" access="public" output="false" returntype="refobjects" hint="Initialisation function.">
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
		<cfcase value="mssql">
			<cfset streturn = createTableMSSQL(argumentcollection=arguments) />
		</cfcase>

		<cfcase value="postgresql">
			<cfset streturn = createTablePostgresql(argumentcollection=arguments) />
		</cfcase>
		
		<cfcase value="mysql,mysql5">
			<cfset streturn = createTableMySQL(argumentcollection=arguments) />
		</cfcase>
		
		<cfcase value="ora, oracle">
			<cfset streturn = createTableOracle(argumentcollection=arguments) />
		</cfcase>

		<cfcase value="HSQLDB">
			<cfset streturn = createTableHSQLDB(argumentcollection=arguments) />
		</cfcase>

		<cfdefaultcase>
			<cfthrow detail="Create sample: #variables.dbtype# not yet implemented.">
		</cfdefaultcase>
	</cfswitch>
	
	<cfreturn streturn />
</cffunction>

<!--- --->
<cffunction name="createTableHSQLDB" access="public" output="false" returntype="struct" hint="Create table; HSQLDB.">
	<cfargument name="bDropTable" default="true" type="boolean" hint="Flag to drop table before creating." />
	<cfset var stReturn = structNew() />
	
	<cfif arguments.bDropTable>
		<cfquery datasource="#variables.dsn#">
		      DROP TABLE refObjects IF EXISTS;
		</cfquery>
	</cfif>
	
	<cfquery datasource="#variables.dsn#">
		CREATE TABLE refObjects (
			objectid VARCHAR(50) NOT NULL PRIMARY KEY,
			typename VARCHAR(50) NOT NULL
		);
	</cfquery>

	<cfreturn stReturn />
</cffunction>

<cffunction name="createTablePostgresql" access="public" output="false" returntype="struct" hint="Create table; postgresql.">
	<cfargument name="bDropTable" default="true" type="boolean" hint="Flag to drop table before creating." />
	<cfset var stReturn = structNew() />
	<cfset var bTableExists=dbutils.checktableexists(tablename="refobjects") />
	
	<cfif bTableExists AND arguments.bDropTable>
		<cfquery datasource="#variables.dsn#">
		DROP TABLE refObjects
		</cfquery>
	</cfif>
	
	<cfquery datasource="#variables.dsn#">
	CREATE TABLE refObjects (
		objectid VARCHAR(50) NOT NULL, 
		typename VARCHAR(50) NOT NULL,
		PRIMARY KEY (objectid)
		)
	</cfquery>

	<cfreturn stReturn />
</cffunction>

<cffunction name="createTableMySQL" access="public" output="false" returntype="struct" hint="Create table; MySQL.">
	<cfargument name="bDropTable" default="true" type="boolean" hint="Flag to drop table before creating." />
	<cfset var stReturn = structNew() />
	
	<cfif arguments.bDropTable>
		<cfquery datasource="#variables.dsn#">
			DROP TABLE IF EXISTS refObjects
		</cfquery>
	</cfif>
	
	<cfquery datasource="#variables.dsn#">
		CREATE TABLE refObjects (
		objectid VARCHAR(50) NOT NULL,
		typename VARCHAR(50) NOT NULL,
		PRIMARY KEY (objectid)
		)
	</cfquery>

	<cfreturn stReturn />
</cffunction>

<cffunction name="createTableMSSQL" access="public" output="false" returntype="struct" hint="Create table; MSSQL.">
	<cfargument name="bDropTable" default="true" type="boolean" hint="Flag to drop table before creating." />
	<cfset var stReturn = structNew() />
	
	<cfif arguments.bDropTable>
		<cfquery datasource="#variables.dsn#">
			if exists (select * from sysobjects where name = 'refObjects')
		      drop table #variables.dbowner#refObjects
		</cfquery>
	</cfif>
	
	<cfquery datasource="#variables.dsn#">
		CREATE TABLE #variables.dbowner#refObjects (
		objectid VARCHAR(50) NOT NULL,
		typename VARCHAR(50) NOT NULL,
		PRIMARY KEY (objectid)
		)
	</cfquery>

	<cfreturn stReturn />
</cffunction>

<cffunction name="createTableOracle" access="public" output="false" returntype="struct" hint="Create table; Oracle.">
	<cfargument name="bDropTable" default="true" type="boolean" hint="Flag to drop table before creating." />
	<cfset var stReturn = structNew() />
	
	<cfif arguments.bDropTable>
		<cfquery name="local.qryTableExists3" datasource="#variables.dsn#">
			select 1
			from   all_tables
			where  table_name = 'REFOBJECTS'
			and    owner      = '#ucase(variables.dbowner)#'
		</cfquery>
		<cfif local.qryTableExists3.recordcount gt 0 >
			<cfquery datasource="#variables.dsn#">
				DROP TABLE #variables.dbowner#refObjects
			</cfquery>
		</cfif>
	</cfif>

	<cfquery datasource="#variables.dsn#">
		CREATE TABLE #variables.dbowner#refObjects (
		objectid VARCHAR(50) NOT NULL,
		typename VARCHAR(50) NOT NULL,
		PRIMARY KEY (objectid)
		)
	</cfquery>

	<cfreturn stReturn />
</cffunction>

</cfcomponent>