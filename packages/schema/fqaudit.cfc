<cfcomponent name="fqaudit">

<!--- 
TODO:
Should possibly move this to something under fourq.  Either that or move all 
audit stuff directly under core. GB 20061022
 --->

<cffunction name="init" access="public" output="false" returntype="fqaudit" hint="Initialisation function.">
	<cfargument name="dsn" required="true" type="string" />
	<cfargument name="dbtype" required="true" type="string" />
	<cfargument name="dbowner" required="true" type="string" />
	
	<cfset variables.tablename = "fqaudit" />
	<cfset variables.dsn = arguments.dsn />
	<cfset variables.dbtype = arguments.dbtype />
	<cfset variables.dbowner = arguments.dbowner />
	
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
			<cfthrow detail="Create fqaudit: #variables.dbtype# not yet implemented.">
		</cfdefaultcase>
	</cfswitch>
	
	<cfset streturn.bsuccess="true" />
	<cfreturn streturn />
</cffunction>

<!--- TODO: shouldn't this be in the gateway? --->
<cffunction name="createTableHSQLDB" access="public" output="false" returntype="struct" hint="Create table; hsqldb.">
	<cfargument name="bDropTable" default="true" type="boolean" hint="Flag to drop table before creating." />
	
	<cfset var stReturn = structNew() />
	
	<cfif arguments.bdroptable>
		<cfquery datasource="#variables.dsn#" name="qDrop">
			DROP TABLE fqAudit IF EXISTS;
		</cfquery>
	</cfif>
			
	<!--- create the audit tables --->
	<cfquery datasource="#variables.dsn#" name="qCreate">
		CREATE TABLE fqAudit (
			AUDITID VARCHAR(50) NOT NULL PRIMARY KEY,
			OBJECTID VARCHAR(50) NULL,
			DATETIMESTAMP TIMESTAMP NOT NULL,
			USERNAME VARCHAR(255) NOT NULL ,
			LOCATION VARCHAR(255) NULL ,
			AUDITTYPE VARCHAR(50) NOT NULL ,
			NOTE VARCHAR(255) NULL
		) 
	</cfquery>

	<cfreturn stReturn />
</cffunction>


<cffunction name="createTablePostgresql" access="public" output="false" returntype="struct" hint="Create table; postgresql.">
	<cfargument name="bDropTable" default="true" type="boolean" hint="Flag to drop table before creating." />
	<cfset var stReturn = structNew() />
	
	<cfquery datasource="#variables.dsn#" name="qCheck">
	SELECT count(*) AS tblExists
	FROM   PG_TABLES
	WHERE  TABLENAME = 'fqaudit'
	AND    SCHEMANAME = 'public'
	</cfquery>

	<cfif qCheck.tblExists AND arguments.bdroptable>
		<cfquery datasource="#variables.dsn#" name="qDrop">
		DROP TABLE fqAudit
		</cfquery>
	</cfif>
			
	<!--- create the audit tables --->
	<cfquery datasource="#variables.dsn#" name="qCreate">
	CREATE TABLE #variables.dbowner#FQAUDIT(
		AUDITID VARCHAR(50) NOT NULL PRIMARY KEY,
		OBJECTID VARCHAR(50) NULL,
		DATETIMESTAMP TIMESTAMP NOT NULL,
		USERNAME VARCHAR(255) NOT NULL ,
		LOCATION VARCHAR(255) NULL ,
		AUDITTYPE VARCHAR(50) NOT NULL ,
		NOTE VARCHAR(255) NULL
	) 
	</cfquery>

	<cfreturn stReturn />
</cffunction>

<cffunction name="createTableMySQL" access="public" output="false" returntype="struct" hint="Create table; MySQL.">
	<cfargument name="bDropTable" default="true" type="boolean" hint="Flag to drop table before creating." />
	<cfset var stReturn = structNew() />

    <cfquery datasource="#variables.dsn#" name="qCheck">
        SHOW TABLES LIKE 'fqAudit'
    </cfquery>
	
    <cfset result = ArrayNew(1)>

    <cfif IsDefined("qCheck.RecordCount") AND qCheck.RecordCount eq 1>
        <cfset result[1] = 1>
    <cfelse>
        <cfset QueryNew('qCheck')>
        <cfset QueryAddRow(qCheck)>
        <cfset result[1] = 0>
    </cfif>
    <cfset temp = QueryAddColumn(qCheck,'tblExists',result)>

			<cfquery datasource="#variables.dsn#" name="qDrop">
				DROP TABLE if exists #variables.dbowner#fqAudit
			</cfquery>
			
			<!--- create the audit tables --->
			<cfquery datasource="#variables.dsn#" name="qCreate">
				CREATE TABLE fqAudit (
					AuditID char (50) NOT NULL ,
					objectid char (50) NULL ,
					datetimeStamp datetime NOT NULL ,
					username varchar (255) NOT NULL ,
					location varchar (255) NULL ,
					auditType char (50) NOT NULL ,
					note varchar (255) NULL,
					PRIMARY KEY(AuditID) 
				) 
			</cfquery>

	<cfreturn stReturn />
</cffunction>

<cffunction name="createTableMSSQL" access="public" output="false" returntype="struct" hint="Create table; MSSQL.">
	<cfargument name="bDropTable" default="true" type="boolean" hint="Flag to drop table before creating." />
	<cfset var stReturn = structNew() />
				<cfquery datasource="#variables.dsn#" name="qCheck">
			SELECT count(*) AS tblExists FROM sysobjects 
			WHERE name = 'fqAudit'
			</cfquery>

			<cfif qCheck.tblExists>
			<cfquery datasource="#variables.dsn#" name="qDrop">
			<!--- if exists (select * from sysobjects where name = '#variables.dbowner#fqAudit') --->
			If exists (select * from INFORMATION_SCHEMA.TABLES where table_name = 'fqAudit')
			DROP TABLE #variables.dbowner#fqAudit;
	
			<!--- return recordset to stop CF bombing out?!? --->
			select count(*) as blah from INFORMATION_SCHEMA.TABLES where table_name = 'fqAudit'
			</cfquery>
			</cfif>
			<!--- create the audit tables --->
			<cfquery datasource="#variables.dsn#" name="qCreate">
			CREATE TABLE #variables.dbowner#fqAudit (
				[AuditID] [char] (50) NOT NULL ,
				[objectid] [char] (50) NULL ,
				[datetimeStamp] [datetime] NOT NULL ,
				[username] [varchar] (255) NOT NULL ,
				[location] [varchar] (255) NULL ,
				[auditType] [char] (50) NOT NULL ,
				[note] [varchar] (255) NULL 
			) ON [PRIMARY];
			
			ALTER TABLE #variables.dbowner#fqAudit WITH NOCHECK ADD 
				CONSTRAINT [PK_fqAudit] PRIMARY KEY NONCLUSTERED 
				(
					[AuditID]
				)  ON [PRIMARY];
			</cfquery>


	<cfreturn stReturn />
</cffunction>

<cffunction name="createTableOracle" access="public" output="false" returntype="struct" hint="Create table; Oracle.">
	<cfargument name="bDropTable" default="true" type="boolean" hint="Flag to drop table before creating." />
	<cfset var stReturn = structNew() />

	<cfquery datasource="#variables.dsn#" name="qCheck">
	SELECT count(*) AS tblExists FROM USER_TABLES WHERE TABLE_NAME = 'FQAUDIT'
	</cfquery>

			<cfif qCheck.tblExists AND arguments.bdroptable>
			<cfquery datasource="#variables.dsn#" name="qDrop">
				DROP TABLE #variables.dbowner#fqAudit
			</cfquery>
			</cfif>

			<cfquery datasource="#variables.dsn#" name="qCreate">
			CREATE TABLE #variables.dbowner#FQAUDIT(
				AUDITID VARCHAR2(50) NOT NULL ,
				OBJECTID VARCHAR2(50) NULL,
				DATETIMESTAMP DATE NOT NULL,
				USERNAME VARCHAR2(255) NOT NULL ,
				LOCATION VARCHAR2(255) NULL ,
				AUDITTYPE VARCHAR2(50) NOT NULL ,
				NOTE VARCHAR2(255) NULL ,
				CONSTRAINT PK_FQAUDIT PRIMARY KEY (AUDITID)
			) 
						
			</cfquery>


	<cfreturn stReturn />
</cffunction>

</cfcomponent>