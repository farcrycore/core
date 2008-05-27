<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!------------------------------------------------------------------------
deployRefObjects() (fourQ COAPI)
 - included method
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/_fourq/deployrefObjects.cfm,v 1.18 2004/05/20 00:23:18 brendan Exp $
$Author: brendan $
$Date: 2004/05/20 00:23:18 $
$Name:  $
$Revision: 1.18 $

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