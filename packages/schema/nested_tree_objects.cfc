<cfcomponent name="nested_tree_objects">

<cffunction name="init" access="public" output="false" returntype="nested_tree_objects" hint="Initialisation function.">
	<cfargument name="dsn" required="true" type="string" />
	<cfargument name="dbtype" required="true" type="string" />
	<cfargument name="dbowner" required="true" type="string" />
	
	<cfset variables.tablename = "nested_tree_objects" />
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
			<cfthrow detail="Create nested_tree_objects: #variables.dbtype# not yet implemented.">
		</cfdefaultcase>
	</cfswitch>
	
	<cfreturn streturn />
</cffunction>

<!--- ? --->
<cffunction name="createTableHSQLDB" access="public" output="false" returntype="struct" hint="Create table; HSQLDB.">
	<cfargument name="bDropTable" default="true" type="boolean" hint="Flag to drop table before creating." />
	<cfset var stReturn = structNew() />
	
	<cfif arguments.bDropTable>
		<cfquery name="dropExisting" datasource="#variables.dsn#">
			DROP TABLE nested_tree_objects IF EXISTS
		</cfquery>
	</cfif>
	
	<cfquery datasource="#variables.dsn#" name="qCreateTable">
		CREATE TABLE nested_tree_objects (
			OBJECTID CHAR(35) not null PRIMARY KEY,
			PARENTID CHAR(35) null,
			OBJECTNAME VARCHAR(255) not null,
			TYPENAME VARCHAR(255) not null,
			NLEFT INTEGER not null,
			NRIGHT INTEGER not null,
			NLEVEL INTEGER not null
		)
	</cfquery>
	
	<!--- CREATE [UNIQUE] INDEX <index> ON <table> (<column> [DESC] [, ...]) [DESC]; --->
	<cfquery datasource="#variables.dsn#">
	 	CREATE INDEX IDX_NTO ON nested_tree_objects (nLeft, nRight)
	</cfquery>

	<cfreturn stReturn />
</cffunction>


<cffunction name="createTablePostgresql" access="public" output="false" returntype="struct" hint="Create table; postgresql.">
	<cfargument name="bDropTable" default="true" type="boolean" hint="Flag to drop table before creating." />
	<cfset var stReturn = structNew() />
	<cfset var bTableExists=dbutils.checktableexists(tablename="nested_tree_objects") />
	
	<cfquery datasource="#variables.dsn#" name="qCreateTable">
	-- Table: nested_tree_objects
	
	<cfif bTableExists AND arguments.bdroptable>
		DROP TABLE nested_tree_objects;
		-- DROP INDEX idx_nto;
	</cfif>
	
	CREATE TABLE nested_tree_objects
	(
	  objectid character varying(50) NOT NULL,
	  parentid character varying(50),
	  objectname character varying(255) NOT NULL,
	  typename character varying(255) NOT NULL,
	  nleft integer NOT NULL,
	  nright integer NOT NULL,
	  nlevel integer NOT NULL,
	  CONSTRAINT nested_tree_objects_pkey PRIMARY KEY (objectid)
	) 
	WITHOUT OIDS;
	ALTER TABLE nested_tree_objects OWNER TO postgres;
	
	-- Index: idx_nto
	
	CREATE INDEX idx_nto
	  ON nested_tree_objects
	  USING btree
	  (nleft, nright);
		
	</cfquery>
	<cfreturn stReturn />
</cffunction>

<cffunction name="createTableMySQL" access="public" output="false" returntype="struct" hint="Create table; MySQL.">
	<cfargument name="bDropTable" default="true" type="boolean" hint="Flag to drop table before creating." />
	<cfset var stReturn = structNew() />
	
	<cfif arguments.bDropTable>
		<cfquery name="dropExisting" datasource="#variables.dsn#">
			DROP TABLE IF EXISTS #variables.dbowner#nested_tree_objects
		</cfquery>
	</cfif>
	
	<cfquery datasource="#variables.dsn#" name="qCreateTable">
		CREATE TABLE nested_tree_objects (
			OBJECTID CHAR(35) not null,
			PARENTID CHAR(35) null,
			OBJECTNAME VARCHAR(255) not null,
			TYPENAME VARCHAR(255) not null,
			NLEFT INTEGER not null,
			NRIGHT INTEGER not null,
			NLEVEL INTEGER not null,
			CONSTRAINT PK_NESTEDTREE_UNIQUE PRIMARY KEY (OBJECTID))
	</cfquery>
	
	<cfquery datasource="#variables.dsn#">
	 	CREATE INDEX IDX_NTO ON nested_tree_objects (nLeft, nRight)
	</cfquery>

	<cfreturn stReturn />
</cffunction>

<cffunction name="createTableMSSQL" access="public" output="false" returntype="struct" hint="Create table; MSSQL.">
	<cfargument name="bDropTable" default="true" type="boolean" hint="Flag to drop table before creating." />
	<cfset var stReturn = structNew() />
	
	<cfif arguments.bdroptable>
		<cfquery name="dropExisting" datasource="#variables.dsn#">
			-- drop nested_tree_objects
			if exists (select * from sysobjects where name = 'nested_tree_objects') 
			drop table #variables.dbowner#nested_tree_objects
			
			-- drop nested_tree_objects index
			if exists (select * from sysindexes where name = 'ix_nto') 
			drop index nested_tree_objects.ix_nto
			
			-- return recordset to stop CF bombing out?!?
			select count(*) as blah from sysobjects
		</cfquery>
	</cfif>
	
	<cfquery name="nested_tree_objects" datasource="#variables.dsn#">
		create table #variables.dbowner#nested_tree_objects (
			[ObjectID] [char] (35) not null primary key nonclustered,
			[ParentID] [char] (35) null ,
			[ObjectName] [nvarchar] (512) not null ,
			[TypeName] [varchar] (255) not null ,
			[nLeft] [int] not null ,
			[nRight] [int] not null ,
			[nLevel] [int] not null ,
			check (nLeft < nRight)
			)
	</cfquery>
	
	<cfquery name="nested_tree_objects_index" datasource="#variables.dsn#">
		create clustered index ix_nto on #variables.dbowner#nested_tree_objects (nLeft, nRight) 
	</cfquery> 

	<cfreturn stReturn />
</cffunction>

<cffunction name="createTableOracle" access="public" output="false" returntype="struct" hint="Create table; Oracle.">
	<cfargument name="bDropTable" default="true" type="boolean" hint="Flag to drop table before creating." />
	<cfset var stReturn = structNew() />
	
	<cfquery name="qExists" datasource="#variables.dsn#">
		SELECT * 
		FROM USER_TABLES
		WHERE TABLE_NAME = 'NESTED_TREE_OBJECTS'
	</cfquery>
	
	<cfif qExists.recordCount AND arguments.bDropTable>
		<cfquery name="dropExisting" datasource="#variables.dsn#">
			DROP TABLE NESTED_TREE_OBJECTS
		</cfquery>	
	</cfif>
	
	<cfquery name="nested_tree_objects" datasource="#variables.dsn#">
		CREATE TABLE NESTED_TREE_OBJECTS (
			OBJECTID CHAR(35) not null,
			PARENTID CHAR(35) null,
			OBJECTNAME VARCHAR2(255) not null,
			TYPENAME VARCHAR2(255) not null,
			NLEFT NUMBER not null,
			NRIGHT NUMBER not null,
			NLEVEL NUMBER not null,
			CONSTRAINT PK_NESTEDTREE_UNIQUE PRIMARY KEY (OBJECTID))
	</cfquery>
	<cfquery name="qExists" datasource="#variables.dsn#">
		SELECT * FROM USER_OBJECTS
		WHERE OBJECT_NAME = 'IDX_NTO'
	</cfquery>
	<cfif qExists.recordCount>
		<cfquery datasource="#variables.dsn#">
		DROP INDEX IDX_NTO
		</cfquery>	
	</cfif> 
	<cfquery datasource="#variables.dsn#">
	 	CREATE INDEX IDX_NTO ON NESTED_TREE_OBJECTS (nLeft, nRight)
	</cfquery>
	<cfquery name="qExists" datasource="#variables.dsn#">
		SELECT * FROM USER_TABLES 
		WHERE TABLE_NAME = 'TEMP_GET_ANCESTORS'
	</cfquery>
	<cfif qExists.recordCount>
		<cfquery datasource="#variables.dsn#">
		DROP TABLE TEMP_GET_ANCESTORS
		</cfquery>	
	</cfif> 
	<cfquery datasource="#variables.dsn#">
		CREATE GLOBAL TEMPORARY TABLE temp_get_ancestors(
			PARENTID VARCHAR2(40) NULL
			) on commit preserve rows
	</cfquery>
	<cfquery name="qExists" datasource="#variables.dsn#">
		SELECT * FROM USER_TABLES 
		WHERE TABLE_NAME = 'TEMP_INSERT_CHILD_AT'
	</cfquery>
	<cfif qExists.recordCount>
		<cfquery datasource="#variables.dsn#">
		DROP TABLE TEMP_INSERT_CHILD_AT
		</cfquery>	
	</cfif> 
	<cfquery datasource="#variables.dsn#">
			CREATE GLOBAL TEMPORARY TABLE temp_insert_child_at(
				SEQ NUMBER NOT NULL,
				NRIGHT NUMBER NOT NULL
			) on commit preserve rows
	</cfquery>
	<cfquery name="qExists" datasource="#variables.dsn#">
		SELECT * FROM USER_TABLES 
		WHERE TABLE_NAME = 'TEMP_BRANCH_IDS'
	</cfquery>
	<cfif qExists.recordCount>
		<cfquery datasource="#variables.dsn#">
		DROP TABLE TEMP_BRANCH_IDS
		</cfquery>	
	</cfif> 
	<cfquery datasource="#variables.dsn#">
		CREATE GLOBAL TEMPORARY TABLE temp_branch_ids(
			OBJECTID VARCHAR2(35) NOT NULL
		)  on commit preserve rows 
	</cfquery>	
	<cfquery name="qExists" datasource="#variables.dsn#">
		SELECT * FROM USER_TABLES 
		WHERE TABLE_NAME = 'TEMP_MOVE_BRANCH'
	</cfquery>
	<cfif qExists.recordCount>
		<cfquery datasource="#variables.dsn#">
		DROP TABLE TEMP_MOVE_BRANCH
		</cfquery>	
	</cfif> 
	<cfquery datasource="#variables.dsn#">
			CREATE GLOBAL TEMPORARY TABLE temp_move_branch(
				SEQ NUMBER NOT NULL,
				NRIGHT NUMBER NOT NULL
			)  on commit preserve rows
	</cfquery>

	<cfreturn stReturn />
</cffunction>

</cfcomponent>