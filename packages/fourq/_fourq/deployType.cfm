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
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!------------------------------------------------------------------------
deployType() (fourQ COAPI)
 - included method
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/_fourq/deployType.cfm,v 1.29 2004/09/27 04:33:46 daniela Exp $
$Author: daniela $
$Date: 2004/09/27 04:33:46 $
$Name:  $
$Revision: 1.29 $

Contributors:
Geoff Bowers (modius@daemon.com.au)

Description:
This function is used to build a relational database table in the 
specified database based on the properties defined by the fourQ persisted 
CFC instances.
------------------------------------------------------------------------->
<cfsetting enablecfoutputonly="Yes">
<!--- 
Note:
This could be a nightmare trying to finesse column details
might be ok for basic table types and to help build array tables etc
here's a start afore we decided to do something more useful :-)
 --->

<!--- introspect for metadata on this object invocation --->
<cfset md = getMetaData(this)>

<!--- begin: prepare SQL statement to send to database --->
<!---
TODO:
Need to add code for ARRAY data type deployment. 
 --->
 
<cfscript>
// get table name for db schema deployment
	tablename = arguments.dbowner&this.getTablename();
// get extended properties for this instance
	stProps = variables.tableMetadata.getTableDefinition();
// cfc property type to db data type translation
	switch(arguments.dbtype){
		case "ora":
		{
			db.boolean = "NUMBER(1)";
			db.date = "DATE";
			db.integer = "INTEGER";			
			db.numeric = "NUMBER";
			db.string = "VARCHAR2(255)";
			db.nstring = "NVARCHAR2(255)";
			db.uuid = "VARCHAR2(50)";
			db.variablename = "VARCHAR2(64)";
			db.color = "VARCHAR2(20)";
			db.email = "VARCHAR2(255)";
			db.longchar = "NCLOB";
			sql = "CREATE TABLE #TABLENAME#( ";
			break;
		}
		case "mysql":
		{
			db.boolean = "INT";
			db.date = "DATETIME";
			db.integer = "INT";			
			db.numeric = "NUMERIC";
			db.string = "VARCHAR(255)";
			db.nstring = "VARCHAR(255)";
			db.uuid = "VARCHAR(50)";
			db.variablename = "VARCHAR(64)";
			db.color = "VARCHAR(20)";
			db.email = "VARCHAR(255)";
			db.longchar = "LONGTEXT";	
			sql = "CREATE TABLE #TABLENAME#( ";
			break;
		}
		case "postgresql":
		{
			db.boolean = "INT";
			db.date = "TIMESTAMP";
			db.integer = "INTEGER";			
			db.numeric = "NUMERIC";
			db.string = "VARCHAR(255)";
			db.nstring = "VARCHAR(255)";
			db.uuid = "VARCHAR(50)";
			db.variablename = "VARCHAR(64)";
			db.color = "VARCHAR(20)";
			db.email = "VARCHAR(255)";
			db.longchar = "TEXT";	
			sql = "CREATE TABLE #TABLENAME#( ";
			break;
		}
		default:
		{	
			db.boolean = "[int]";
			db.date = "[DATETIME]";
			db.integer = "[INT]";			
			db.numeric = "[NUMERIC]";
			db.string = "[VARCHAR] (255)";
			db.nstring = "[NVARCHAR] (512)";
			db.uuid = "[VARCHAR] (50)";
			db.variablename = "[VARCHAR] (64)";
			db.color = "[VARCHAR] (20)";
			db.email = "[VARCHAR] (255)";
			db.longchar = "[NTEXT]";
			SQL = "CREATE TABLE #tablename# (";
		}
	}	
</cfscript>

<cfset bFirstProp = true />

<!--- build column statements for object type--->
<cfloop collection="#stProps#" item="prop">
	<cfset thisprop = stProps[prop]>
	<!--- add property as db column? --->
	<cfif not isDefined('thisprop.addToDb')>
		<cfset thisprop.addToDb = true>
	</cfif>
	<!--- is property NULL-able? --->
	<cfparam name="thisprop.required" default="false">
	<cfif thisprop.required>
		<cfset nullable = "NOT NULL">
	<cfelse>
		<cfset nullable = "NULL">
	</cfif>
	<!--- is a default defined? not used by the looks... --->
	<cfif isDefined('thisprop.default') AND thisprop.default neq "">
		<cfset default = "DEFAULT '#thisprop.default#'">
	<cfelse>
		<cfset default = "">
	</cfif>

	<!--- Handle Array properties --->
	<cfif thisprop.type eq 'array'>
		
		<cfparam name="thisprop.datatype" default="string">
		<cfset stInput = structNew()>
		<cfset stInput.bDropTable = arguments.bDropTable>
		<cfset stInput.bTestRun = arguments.bTestRun>
        <cfset stInput.dsn = arguments.dsn>
		<cfset stInput.property = thisprop.name>
		<cfset stInput.parent = tablename>
		<cfset stInput.datatype = thisprop.datatype>
		<cfset stResult[thisprop.name] = deployArrayTable(ArgumentCollection=stInput)>
		
	<cfelse>
	
		<cfif thisprop.addToDb>
			
			<cfif bFirstProp>
				<cfset bFirstProp = false />
			<cfelse>
				<cfset sql = ",#sql#" />
			</cfif>

			<cfscript>
					
				switch(arguments.dbtype){
					case "ora" :
					{
						sql = sql & "#thisprop.name# #db[thisprop.type]# #default# #nullable# ";
						break;
					}
					case "mysql" :
					{
						sql = sql & "#thisprop.name# #db[thisprop.type]# #default# #nullable# ";
						break;
					}
					case "postgresql" :
					{
						sql = sql & "#thisprop.name# #db[thisprop.type]# #default# #nullable# ";
						break;
					}
					default : {
						sql = sql & "[#thisprop.name#] #db[thisprop.type]# #nullable# #default#";
					}
				} //end case
						
			</cfscript>
		</cfif>
	</cfif>
</cfloop>

<cfset sql = sql & ")">
<!--- Note - only doing this as oracle driver is dieing - this would however execute fine in sql plus - bug in jdbc me thinks --->
<cfif NOT arguments.dbtype IS  "ora">
	<cfset sql = sql & ";">
</cfif>
<cfset sql = replace(sql,",)",")")>

<!--- end: prepare SQL statement to send to database --->

<!--- begin: deploy tables in database --->
<cfif NOT arguments.btestrun>
    <cftrace inline="false" text="Drop table" var="tablename">
    <!--- drop table from objectstore --->
	
	<cftry>
		<cfswitch expression="#arguments.dbtype#">
		<cfcase value="ora">
			<cfquery datasource="#application.dsn#" name="qDrop">
				SELECT * FROM USER_TABLES 
				WHERE TABLE_NAME = '#ucase(tablename)#'
			</cfquery>
			<cfif qDrop.recordcount>
				<cfquery datasource="#application.dsn#">
					DROP TABLE #ucase(tablename)#
				</cfquery>
			</cfif>
		</cfcase>
		<cfcase value="mysql,mysql5">
			
			<cfquery datasource="#application.dsn#">
				DROP TABLE IF EXISTS #tablename#
			</cfquery>
			
		</cfcase>
		<cfcase value="postgresql">
         <cftry>
            <cfquery datasource="#application.dsn#">
      			DROP TABLE #tablename#
      		</cfquery>	
         <cfcatch></cfcatch>
         </cftry>
		 </cfcase>
		<cfdefaultcase>
		<cfquery datasource="#arguments.dsn#" name="qDrop">
        if exists (select * from sysobjects where name = '#tableName#')
		drop table [#tablename#]

        -- return recordset to stop CF bombing out?!?
        select count(*) as blah from sysobjects
		</cfquery>
		</cfdefaultcase>
		</cfswitch>
		
		<cfcatch>
		<!--- supress error --->
		<cftrace inline="false" text="Drop table - failed" var="cfcatch.message">
		</cfcatch>
	</cftry>
	
	<!--- create query with zero record count --->
	<cfset qExists = queryNew('faketable')>
	
<cfelse>
<!--- check for the existence of the table --->
	<cfswitch expression="#arguments.dbtype#">
	
	<cfcase value="ora">
		<cfquery datasource="#application.dsn#" name="qExists">
			SELECT * FROM USER_TABLES 
			WHERE TABLE_NAME = '#ucase(tablename)#'
		</cfquery>
	</cfcase>
	<cfcase value="mysql,mysql5">
		<cfquery datasource="#application.dsn#" name="qExists">
			SHOW TABLES LIKE '#ucase(tablename)#'
		</cfquery>
	</cfcase>
	<cfcase value="postgresql">
      <cfquery datasource="#application.dsn#" name="qExists">
         SELECT *
         FROM   PG_TABLES
         WHERE  upper(TABLENAME) = upper('#tablename#')
         AND    SCHEMANAME = 'public'
      </cfquery>
   </cfcase>
	<cfdefaultcase>
		<cfquery datasource="#arguments.dsn#" name="qExists">
			select * from dbo.sysobjects where id = object_id(N'[dbo].[#tablename#]')
			</cfquery>
	</cfdefaultcase>	
	</cfswitch>
</cfif>

<cfif NOT arguments.btestrun AND isDefined('qExists.recordCount') and NOT qExists.recordcount>
<!--- deploy table into datasource --->
	<cfdump var="#sql#">
	
	<cfif arguments.dbtype neq "MySQL">
		<!---- Temporary hack for installer ---->
		<cftry>
		<cfquery datasource="#arguments.dsn#" name="qDeploy">#preserveSingleQuotes(sql)#</cfquery>
		<cfcatch></cfcatch>
		</cftry>
	<cfelse>
		<cfset sql = replace(sql,"NTEXT","TEXT","all")><!--- had to stick this in, somehow the query was getting built for mysql with mssql syntax. Dan --->
		<cfquery datasource="#arguments.dsn#" name="qDeploy">#preserveSingleQuotes(sql)#</cfquery>
	</cfif>
	<cfset stResult.message = "Type [#tableName#] deployed successfully.">
	<cfset stResult.bSuccess = true>
	
<cfelse>
<!--- test run or table not dropped --->
	<cfif arguments.btestrun>
		<cfset stResult.message = "Testrun. No database changes made.">
		<cfset stResult.bSuccess = true>
	<cfelse>
		<cfset stResult.message = "A table with that name already exists.">
		<cfset stResult.bSuccess = false>
	</cfif>
	
	
</cfif>

<!--- add sql statement for debug --->
<cfset stResult.sql = sql>
<!--- end: deploy tables in database --->

<cfsetting enablecfoutputonly="no">