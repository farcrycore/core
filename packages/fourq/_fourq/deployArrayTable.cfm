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
deployArrayTable() (fourQ COAPI)
 - included method
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/fourq/_fourq/deployArrayTable.cfm,v 1.28 2004/09/27 04:33:46 daniela Exp $
$Author: daniela $
$Date: 2004/09/27 04:33:46 $
$Name:  $
$Revision: 1.28 $

Contributors:
Geoff Bowers (modius@daemon.com.au)

Description:
Deploy a table in the database for an array property
------------------------------------------------------------------------->

<cfscript>
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
			break;
		}
		case "mysql,mysql5":
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
		}
	}	
</cfscript>

<cfset arraytable = "#arguments.parent#_#arguments.property#">


<cfif arguments.bDropTable>
	<cftry>
	
	<cfswitch expression="#arguments.dbtype#">
	<cfcase value="ora">
		<cfquery datasource="#arguments.dsn#" name="qObjectExists">
			SELECT * 
			FROM USER_TABLES
			WHERE TABLE_NAME = '#ucase(arraytable)#'
		</cfquery>
		
		<cfif qObjectExists.recordcount>
			<cfquery datasource="#arguments.dsn#">
				DROP TABLE #ucase(arraytable)#
			</cfquery>
		</cfif>
	</cfcase>
	<cfcase value="mysql,mysql5">		
		<cfquery datasource="#arguments.dsn#">
			DROP TABLE IF EXISTS #arraytable#
		</cfquery>		
	</cfcase>
	<cfcase value="postgresql">
      <cfquery datasource="#arguments.dsn#" name="qObjectExists">
         SELECT *
         FROM   PG_TABLES
         WHERE  TABLENAME = '#arraytable#'
         AND    SCHEMANAME = 'public'
      </cfquery>
      <cfif qObjectExists.recordcount>
         <cfquery datasource="#arguments.dsn#">
   			DROP TABLE #arraytable#
   		</cfquery>	
      </cfif>
   </cfcase>
	<cfdefaultcase>
		<cfquery datasource="#arguments.dsn#">
 		if exists (
					SELECT * 
					FROM dbo.sysobjects 
					WHERE 	id = object_id(N'[dbo].[#arraytable#]') 
							AND OBJECTPROPERTY(id, N'IsUserTable') = 1
					) 
				drop table [#arraytable#]
		</cfquery>
	</cfdefaultcase>	
	</cfswitch>
		<cfcatch>
		<!--- Suppress Error --->
		   <cftrace inline="false" text="Drop table - failed" var="cfcatch.message">
		</cfcatch>
	</cftry>
	
</cfif>

<cfif arguments.bTestrun>
	<cfsavecontent variable="sql">
	<cfoutput>
	<cfswitch expression="application.dbtype">
	<cfcase value="ora">
		<pre>
			CREATE TABLE #ucase(arraytable)#
			{
				data #db[arguments.datatype]# NOT NULL,
				seq #db.numeric# NOT NULL,
				typename #db.string# NOT NULL,
				objectid #db.uuid# NOT NULL
			}	
		</pre>
	</cfcase> 
	<cfcase value="postgresql">
		<pre>
			CREATE TABLE #arraytable#
			{
				data #db[arguments.datatype]# NOT NULL,
				seq #db.numeric# NOT NULL,
				typename #db.string# NOT NULL,
				objectid #db.uuid# NOT NULL
			}	
		</pre>
	</cfcase>
	<cfdefaultcase>
		<pre>
		CREATE TABLE #arraytable#
		(
		[data] #db[arguments.datatype]# NOT NULL
		[seq] #db.numeric# NOT NULL
		[typename] #db.string# NOT NULL
		[objectid] #db.uuid# NOT NULL
		);
		</pre>
	</cfdefaultcase>
	</cfswitch>
	</cfoutput>
	</cfsavecontent>
	<cfset stTmp.message = "Testrun. No database changes made.">
	<cfset stTmp.bSuccess = true>
	<cfset stTmp.sql = sql>
<cfelse>
    <!--- this is not a test run so check if we need to drop existing tables --->
    <cfif arguments.bDropTable>
        <cftrace inline="false" text="Drop table" var="arraytable">
        <!--- drop table from objectstore --->
    	<cftry>
			<cfswitch expression="#arguments.dbtype#">
			    <cfcase value="ora">
					<cfquery datasource="#arguments.dsn#" name="qObjectExists">
						SELECT * 
						FROM USER_TABLES
						WHERE TABLE_NAME = '#ucase(arraytable)#'
					</cfquery>
					
					<cfif qObjectExists.recordcount>
						<cfquery datasource="#arguments.dsn#">
							DROP TABLE #arraytable#
						</cfquery>
					</cfif>
			    </cfcase>
			    <cfcase value="mysql,mysql5">
					<cfquery datasource="#arguments.dsn#">
		            	DROP TABLE IF EXISTS [#arraytable#]
		    		</cfquery>	
			    </cfcase>			    
			    <cfcase value="postgresql">
				   <cftry>
					  <cfquery datasource="#arguments.dsn#">
							DROP TABLE #arraytable#
						</cfquery>	
				   <cfcatch></cfcatch></cftry>
				 </cfcase>
				<cfdefaultcase>
					<cfquery datasource="#arguments.dsn#">
		            if exists (select * from sysobjects where name = '#arraytable#')
		    		drop table [#arraytable#]
		    		</cfquery>
			    </cfdefaultcase>
			</cfswitch>
	    	<cfcatch>	
	    		<!--- supress error --->
		    	<cftrace inline="false" text="Drop table - failed" var="cfcatch.message">
			</cfcatch>
    	</cftry>
    </cfif>
	
	
	<cfswitch expression="#arguments.dbtype#">
	<cfcase value="ora">
		
		<cfquery datasource="#arguments.dsn#">
		CREATE TABLE #ucase(arraytable)#
		(
		data #db[arguments.datatype]# NOT NULL,
		seq #db.numeric# NOT NULL,
		typename #db.string# NOT NULL,
		objectid #db.uuid# NOT NULL
		)
		</cfquery>
	</cfcase>
	<cfcase value="mysql,mysql5">		
		<cfquery datasource="#arguments.dsn#">
		CREATE TABLE #arraytable#
		(
		data #db[arguments.datatype]# NOT NULL,
		seq #db.numeric# NOT NULL,
		typename #db.string# NOT NULL,
		objectid #db.uuid# NOT NULL
		)
		</cfquery>
	</cfcase>
	<cfcase value="postgresql">
		
		<cfquery datasource="#arguments.dsn#">
		CREATE TABLE #arraytable#
		(
		data #db[arguments.datatype]# NOT NULL,
		seq #db.numeric# NOT NULL,
		typename #db.string# NOT NULL,
		objectid #db.uuid# NOT NULL
		)
		</cfquery>
	</cfcase>
	<cfdefaultcase>
		<!--- Temporary hack for installer --->
		<cftry>
		<cfquery datasource="#arguments.dsn#">
		CREATE TABLE #arraytable#
		(
		[data] #db[arguments.datatype]# NOT NULL,
		[seq] #db.numeric# NOT NULL,
		[typename] #db.string# NOT NULL,
		[objectid] #db.uuid# NOT NULL
		)
		</cfquery>
		<cfcatch></cfcatch>
		</cftry>
		</cfdefaultcase>
	</cfswitch>

	<cfset stTmp.message = "Array Property Table [#arguments.property#_#arguments.parent#] deployed successfully.">
	<cfset stTmp.bSuccess = true>
</cfif>