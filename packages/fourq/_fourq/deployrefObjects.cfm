<!------------------------------------------------------------------------
deployRefObjects() (fourQ COAPI)
 - included method
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/_fourq/deployrefObjects.cfm,v 1.18 2004/05/20 00:23:18 brendan Exp $
$Author: brendan $
$Date: 2004/05/20 00:23:18 $
$Name:  $
$Revision: 1.18 $

Released Under the "Common Public License 1.0"
http://www.opensource.org/licenses/cpl.php

Contributors:
Geoff Bowers (modius@daemon.com.au)

Description:
This function is used to build a relational database table in the 
specified database based for an object to type lookup reference for 
fourQ persisted CFC instances.
------------------------------------------------------------------------->
<cfsetting enablecfoutputonly="Yes">
<cfif arguments.bDropTable>
	<cfswitch expression="#arguments.dbtype#">
	<!--- Oracle deployment --->
	<cfcase value="ora">
		<cfquery datasource="#application.dsn#" name="qTableExists">
			SELECT * FROM USER_TABLES 
			WHERE TABLE_NAME = 'REFOBJECTS'
		</cfquery>
		<cfif qTableExists.recordcount>
			<cfquery datasource="#application.dsn#">
				DROP TABLE #arguments.dbowner#refOBJECTS
			</cfquery>
		</cfif>	
		<cfquery datasource="#application.dsn#">
			CREATE TABLE #arguments.dbowner#refobjects (
			objectid VARCHAR2(50) NOT NULL,
			typename VARCHAR2(50) NOT NULL
			)
		</cfquery>
		
	</cfcase>
	<cfcase value="mysql,mysql5">
		
		<cfquery datasource="#application.dsn#">
			DROP TABLE IF EXISTS #arguments.dbowner#refObjects
		</cfquery>
		
		<cfquery datasource="#application.dsn#">
			CREATE TABLE #arguments.dbowner#refObjects (
			objectid VARCHAR(50) NOT NULL,
			typename VARCHAR(50) NOT NULL
			)
		</cfquery>
		
	</cfcase>
	<cfcase value="postgresql">
      <cfquery datasource="#application.dsn#" name="qTableExists">
         SELECT *
         FROM   PG_TABLES
         WHERE  TABLENAME = 'refobjects'
         AND    SCHEMANAME = 'public'
      </cfquery>
      <cfif qTableExists.recordcount>
         <cfquery datasource="#application.dsn#">
   			DROP TABLE #arguments.dbowner#refobjects
   		</cfquery>	
      </cfif>
      <cfquery datasource="#application.dsn#">
			CREATE TABLE #arguments.dbowner#refobjects (
			objectid VARCHAR (50) NOT NULL,
			typename VARCHAR (50) NOT NULL
			)
		</cfquery>
   </cfcase>
	<cfdefaultcase>
		<cfquery datasource="#arguments.dsn#">
		if exists (select * from sysobjects where name = 'refObjects')
		drop table refObjects
	
		-- return recordset to stop CF bombing out?!?
		select count(*) as blah from sysobjects
		</cfquery>
		<cfquery datasource="#arguments.dsn#" name="qCreateRefObjects">
			CREATE TABLE #arguments.dbowner#refObjects
			(
			[objectid] [VARCHAR] (50) NOT NULL,
			[typename] [VARCHAR] (50) NOT NULL
			);
		</cfquery>

	</cfdefaultcase>
	</cfswitch>
</cfif>


<cfset stResult.message = "Type refObjects deployed successfully.">
<cfset stResult.bSuccess = true>
	
<cfsetting enablecfoutputonly="no">