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
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_category/deployCategories.cfm,v 1.14 2004/12/15 10:15:51 brendan Exp $
$Author: brendan $
$Date: 2004/12/15 10:15:51 $
$Name: milestone_3-0-1 $
$Revision: 1.14 $


|| DESCRIPTION ||
$Description: <insert short description of functionality> $
$TODO: <whatever todo's needed -- can be inline also>$


|| DEVELOPER ||
$Developer: Daniel Morphett (daniel@daemon.com.au) $



|| ATTRIBUTES ||
$in: arguments.bDropTables	: drop the existing tables if true. destructive! $
$out: <separate entry for each variable>$
--->                                                                                                                                     <cfsetting enablecfoutputonly="Yes">

<cfscript>
	stStatus = structNew();
	stStatus.message = "";
	stStatus.status = false;
	arguments.bdropTables = true;
</cfscript>

<cfif arguments.bDropTables>

	<cfswitch expression="#application.dbtype#">
	<cfcase value="ora">
		<cfquery datasource="#arguments.dsn#" name="qExists">
			SELECT * FROM USER_TABLES
			WHERE TABLE_NAME = 'CATEGORIES'
		</cfquery>
		<cfif qExists.recordCount>
			<cfquery datasource="#arguments.dsn#">
			DROP TABLE #application.dbowner#CATEGORIES
			</cfquery>
		</cfif>	
		<cfquery datasource="#arguments.dsn#" name="qExists">
			SELECT * FROM USER_TABLES
			WHERE TABLE_NAME = 'REFCATEGORIES'
		</cfquery>
		<cfif qExists.recordCount>
			<cfquery datasource="#arguments.dsn#">
				DROP TABLE #application.dbowner#REFCATEGORIES
			</cfquery>
			
		</cfif>	
	</cfcase>
	<cfcase value="mysql,mysql5">
		<cfquery datasource="#arguments.dsn#">
        	DROP TABLE IF EXISTS categories	
		</cfquery>
		<cfquery datasource="#arguments.dsn#">
        	DROP TABLE IF EXISTS refCategories
		</cfquery>
	</cfcase>
	<cfcase value="postgresql">
		<cftry>
      <cfquery datasource="#arguments.dsn#">
        	DROP TABLE categories	
		</cfquery><cfcatch></cfcatch></cftry>
		<cftry><cfquery datasource="#arguments.dsn#">
        	DROP TABLE refCategories
		</cfquery><cfcatch></cfcatch></cftry>
	</cfcase>
	<cfdefaultcase>
	<cftransaction>
		<cfquery datasource="#arguments.dsn#">
        if exists (select * from sysobjects where name = 'categories')
		DROP TABLE categories	

    	-- return recordset to stop CF bombing out?!?
    	select count(*) as blah from sysobjects
		</cfquery>
		<cfquery datasource="#arguments.dsn#">
        if exists (select * from sysobjects where name = 'refCategories')
        DROP TABLE refCategories

    	-- return recordset to stop CF bombing out?!?
    	select count(*) as blah from sysobjects
		</cfquery>
	</cftransaction>	
	</cfdefaultcase>
	</cfswitch>	
	<cfset stStatus.message = "refCategories,categories tables successfully dropped <br>">

</cfif> 
<cflock name="#application.fc.utils.createJavaUUID()#" type="exclusive" timeout="50">
<cftry>
	<cfswitch expression="#application.dbtype#">
	<cfcase value="ora">
		
		<cfquery datasource="#arguments.dsn#">
			CREATE TABLE #application.dbowner#CATEGORIES
			(
			CATEGORYID VARCHAR2(50) NOT NULL,
			ALIAS VARCHAR2(50) NULL,
			CATEGORYLABEL VARCHAR2(255) NOT NULL
			)
		</cfquery>
		<cfquery datasource="#arguments.dsn#">
			CREATE TABLE #application.dbowner#REFCATEGORIES
			(
			CATEGORYID VARCHAR2(50) NOT NULL,
			OBJECTID VARCHAR2(50) NOT NULL
			)
		</cfquery>
		
	</cfcase>
	<cfcase value="mysql,mysql5">
		<cfquery datasource="#arguments.dsn#">
		CREATE TABLE #application.dbowner#categories
		(
			categoryID VARCHAR(50) NOT NULL,
			alias VARCHAR(50) NULL,
			categoryLabel VARCHAR(255) NOT NULL
		)
		</cfquery>
		<cfquery datasource="#arguments.dsn#">
		CREATE TABLE #application.dbowner#refCategories
		(
			categoryid VARCHAR (50) NOT NULL,
			objectID VARCHAR(50) NOT NULL
		)
		</cfquery>
	</cfcase>
	<cfcase value="postgresql">
		<cfquery datasource="#arguments.dsn#">
		CREATE TABLE #application.dbowner#categories
		(
			categoryID VARCHAR (50) NOT NULL,
			categoryLabel VARCHAR (255) NOT NULL,
			alias VARCHAR (50) NULL
		)
		</cfquery>
		<cfquery datasource="#arguments.dsn#">
		CREATE TABLE #application.dbowner#refCategories
		(
			categoryid VARCHAR (50) NOT NULL,
			objectID VARCHAR (50) NOT NULL
		)
		</cfquery>
	</cfcase>
	<cfdefaultcase>
	<cftransaction>
	<!--- Create category and refCategories Tables --->
	<cfquery datasource="#arguments.dsn#">
	CREATE TABLE #application.dbowner#categories
	(
		[categoryID] [VARCHAR] (50) NOT NULL,
		[alias] [VARCHAR] (50) NULL,
		[categoryLabel] [NVARCHAR] (512) NOT NULL
	);
	</cfquery>
	<cfquery datasource="#arguments.dsn#">
	CREATE TABLE #application.dbowner#refCategories
	(
		[categoryid] [VARCHAR] (50) NOT NULL,
		[objectID] [VARCHAR] (50) NOT NULL
	);
	</cfquery>
	</cftransaction>
	</cfdefaultcase>
	</cfswitch>
	
	<cfset rootUUID = application.fc.utils.createJavaUUID()>
	<cfquery datasource="#application.dsn#" name="qUpdate">
		insert into #application.dbowner#categories
		(categoryid,alias,categorylabel)
		values 
		('#rootUUID#','root' ,'root')
	</cfquery>
	
	<cfinvoke component="#application.packagepath#.farcry.tree"	 method="setRootNode" objectName = "root" typename = "categories" objectID="#rootUUID#" returnvariable="stReturn">
	<cfscript> 
		stStatus.status = true;
		stStatus.message = stStatus.message & stReturn.message & '<br>' & 'categories, refCategory tables successfully created';
	</cfscript>
	<cfcatch type="database">
		<cfscript>
			//TODO - put some details of the cfcatch.Message 
			stStatus.status = false;
			stStatus.message = 'Creat categories, refCategory tables failed';
		</cfscript>
		<Cfdump var="#cfcatch#"><cfabort>
	</cfcatch>
	 
</cftry>	
</cflock>

	
<cfsetting enablecfoutputonly="no">

