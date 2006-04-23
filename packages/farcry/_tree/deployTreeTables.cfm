<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_tree/deployTreeTables.cfm,v 1.7 2003/05/28 23:15:05 brendan Exp $
$Author: brendan $
$Date: 2003/05/28 23:15:05 $
$Name: b131 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: This tag installs all the tables that you need for nested tree model operations.
If you add any more, make sure you create them as [dbo].[tablename], otherwise, hassles later on will be caused by the 
app_user being the table owner.$
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $
$Developer: Geoff Bowers (modius@daemon.com.au) - CFC integration $
$Developer: Daniel Morphett (daniel@daemon.com.au) - stored procs etc $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfswitch expression="#application.dbtype#">
<cfcase value="mysql">
	
	<cfquery name="dropExisting" datasource="#stArgs.dsn#">
		DROP TABLE IF EXISTS NESTED_TREE_OBJECTS
	</cfquery>	
	
	
	<cfquery name="nested_tree_objects" datasource="#stArgs.dsn#">
		CREATE TABLE NESTED_TREE_OBJECTS (
			OBJECTID CHAR(35) not null,
			PARENTID CHAR(35) null,
			OBJECTNAME VARCHAR(255) not null,
			TYPENAME VARCHAR(255) not null,
			NLEFT INTEGER not null,
			NRIGHT INTEGER not null,
			NLEVEL INTEGER not null,
			CONSTRAINT PK_NESTEDTREE_UNIQUE PRIMARY KEY (OBJECTID))
	</cfquery>
	
	<cfquery datasource="#stArgs.dsn#">
	 	CREATE INDEX IDX_NTO ON NESTED_TREE_OBJECTS (nLeft, nRight)
	</cfquery>
</cfcase>	

<cfcase value="ora">
	<cfquery name="qExists" datasource="#stArgs.dsn#">
		SELECT * 
		FROM USER_TABLES
		WHERE TABLE_NAME = 'NESTED_TREE_OBJECTS';
	</cfquery>
	<cfif qExists.recordCount>
		<cfquery name="dropExisting" datasource="#stArgs.dsn#">
			DROP TABLE NESTED_TREE_OBJECTS
		</cfquery>	
	</cfif>
	
	<cfquery name="nested_tree_objects" datasource="#stArgs.dsn#">
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
	<cfquery name="qExists" datasource="#stArgs.dsn#">
		SELECT * FROM USER_OBJECTS
		WHERE OBJECT_NAME = 'IDX_NTO'
	</cfquery>
	<cfif qExists.recordCount>
		<cfquery datasource="#stArgs.dsn#">
		DROP INDEX IDX_NTO
		</cfquery>	
	</cfif> 
	<cfquery datasource="#stArgs.dsn#">
	 	CREATE INDEX IDX_NTO ON NESTED_TREE_OBJECTS (nLeft, nRight)
	</cfquery>
	<cfquery name="qExists" datasource="#stArgs.dsn#">
		SELECT * FROM USER_TABLES 
		WHERE TABLE_NAME = 'TEMP_GET_ANCESTORS'
	</cfquery>
	<cfif qExists.recordCount>
		<cfquery datasource="#stArgs.dsn#">
		DROP TABLE TEMP_GET_ANCESTORS
		</cfquery>	
	</cfif> 
	<cfquery datasource="#stArgs.dsn#">
		CREATE GLOBAL TEMPORARY TABLE temp_get_ancestors(
			PARENTID VARCHAR2(40) NULL
			) on commit preserve rows
	</cfquery>
	<cfquery name="qExists" datasource="#stArgs.dsn#">
		SELECT * FROM USER_TABLES 
		WHERE TABLE_NAME = 'TEMP_INSERT_CHILD_AT'
	</cfquery>
	<cfif qExists.recordCount>
		<cfquery datasource="#stArgs.dsn#">
		DROP TABLE TEMP_INSERT_CHILD_AT
		</cfquery>	
	</cfif> 
	<cfquery datasource="#stArgs.dsn#">
			CREATE GLOBAL TEMPORARY TABLE temp_insert_child_at(
				SEQ NUMBER NOT NULL,
				NRIGHT NUMBER NOT NULL
			) on commit preserve rows
	</cfquery>
	<cfquery name="qExists" datasource="#stArgs.dsn#">
		SELECT * FROM USER_TABLES 
		WHERE TABLE_NAME = 'TEMP_BRANCH_IDS'
	</cfquery>
	<cfif qExists.recordCount>
		<cfquery datasource="#stArgs.dsn#">
		DROP TABLE TEMP_BRANCH_IDS
		</cfquery>	
	</cfif> 
	<cfquery datasource="#stArgs.dsn#">
		CREATE GLOBAL TEMPORARY TABLE temp_branch_ids(
			OBJECTID VARCHAR2(35) NOT NULL
		)  on commit preserve rows 
	</cfquery>	
	<cfquery name="qExists" datasource="#stArgs.dsn#">
		SELECT * FROM USER_TABLES 
		WHERE TABLE_NAME = 'TEMP_MOVE_BRANCH'
	</cfquery>
	<cfif qExists.recordCount>
		<cfquery datasource="#stArgs.dsn#">
		DROP TABLE TEMP_MOVE_BRANCH
		</cfquery>	
	</cfif> 
	<cfquery datasource="#stArgs.dsn#">
			CREATE GLOBAL TEMPORARY TABLE temp_move_branch(
				SEQ NUMBER NOT NULL,
				NRIGHT NUMBER NOT NULL
			)  on commit preserve rows
	</cfquery>
</cfcase>

<cfdefaultcase><!--- mssql server --->
	<cfquery name="dropExisting" datasource="#stArgs.dsn#">
		-- drop nested_tree_objects
		if exists (select * from sysobjects where name = 'nested_tree_objects') 
		drop table nested_tree_objects
		
		-- drop nested_tree_objects index
		if exists (select * from sysindexes where name = 'ix_nto') 
		drop index nested_tree_objects.ix_nto
		
		-- return recordset to stop CF bombing out?!?
		select count(*) as blah from sysobjects
	</cfquery>    
	
	
	<!------------------------------------------------------------------------
	Deploy NTM Table (nested_tree_objects)
	------------------------------------------------------------------------->
	<cfquery name="nested_tree_objects" datasource="#stArgs.dsn#">
		create table [dbo].[nested_tree_objects] (
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
	
	<cfquery name="nested_tree_objects_index" datasource="#stArgs.dsn#">
		create clustered index ix_nto on nested_tree_objects (nLeft, nRight) 
	</cfquery> 
</cfdefaultcase>
</cfswitch>


<cfscript>
if (IsDefined("error")) {
	stReturn.bSuccess = false;
	stReturn.message = error;
} else {
	stReturn.bSuccess = true;
	stReturn.message ="Nested tree model deployed.";
}
</cfscript>

<cfsetting enablecfoutputonly="no">