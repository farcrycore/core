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

	<cfswitch expression="#arguments.dbtype#">
	<cfcase value="ora">
		<cfquery datasource="#arguments.dsn#" name="qExists">
			SELECT * FROM USER_TABLES
			WHERE TABLE_NAME = 'REFCATEGORIES'
		</cfquery>
		<cfif qExists.recordCount>
			<cfquery datasource="#arguments.dsn#">
				DROP TABLE #arguments.dbowner#REFCATEGORIES
			</cfquery>
			
		</cfif>	
	</cfcase>
	<cfcase value="mysql,mysql5">
		<cfquery datasource="#arguments.dsn#">
        	DROP TABLE IF EXISTS refCategories
		</cfquery>
	</cfcase>
	<cfcase value="postgresql">
		<cftry><cfquery datasource="#arguments.dsn#">
        	DROP TABLE refCategories
		</cfquery><cfcatch></cfcatch></cftry>
	</cfcase>
	
	<!--- oi... --->
	<cfcase value="HSQLDB">
		<cfquery datasource="#arguments.dsn#">
        	DROP TABLE refCategories IF EXISTS
		</cfquery>
	</cfcase>
	
	<cfdefaultcase>
	<cftransaction>
		<cfquery datasource="#arguments.dsn#" name="qTempOutput">
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
<cflock name="#createuuid()#" type="exclusive" timeout="50">
<cftry>
	<cfswitch expression="#arguments.dbtype#">
	<cfcase value="ora">
		<cfquery datasource="#arguments.dsn#">
			CREATE TABLE #arguments.dbowner#REFCATEGORIES
			(
			CATEGORYID VARCHAR2(50) NOT NULL,
			OBJECTID VARCHAR2(50) NOT NULL
			)
		</cfquery>
	</cfcase>
	<cfcase value="mysql,mysql5">
		<cfquery datasource="#arguments.dsn#">
		CREATE TABLE #arguments.dbowner#refCategories
		(
			categoryid VARCHAR (50) NOT NULL,
			objectID VARCHAR(50) NOT NULL
		)
		</cfquery>
	</cfcase>
	<cfcase value="postgresql">
		<cfquery datasource="#arguments.dsn#">
		CREATE TABLE #arguments.dbowner#refCategories
		(
			categoryid VARCHAR (50) NOT NULL,
			objectID VARCHAR (50) NOT NULL
		)
		</cfquery>
	</cfcase>
	
	<!--- TODO: --->
	<cfcase value="HSQLDB">
		<cfquery datasource="#arguments.dsn#">
		CREATE TABLE refCategories (
			categoryid VARCHAR(50) NOT NULL,
			objectID VARCHAR(50) NOT NULL
		)
		</cfquery>
	</cfcase>
	
	
	<cfdefaultcase>
	<cftransaction>
	
	<cfquery datasource="#arguments.dsn#">
	CREATE TABLE #arguments.dbowner#refCategories
	(
		[categoryid] [VARCHAR] (50) NOT NULL,
		[objectID] [VARCHAR] (50) NOT NULL
	);
	</cfquery>
	</cftransaction>
	</cfdefaultcase>
	</cfswitch>
	
	<cfcatch type="database">
		<cfscript>
			//TODO - put some details of the cfcatch.Message 
			stStatus.status = false;
			stStatus.message = 'CreaterefCategory tables failed';
		</cfscript>
		<Cfdump var="#cfcatch#"><cfabort>
	</cfcatch> 
	 
</cftry>	
</cflock>

	
<cfsetting enablecfoutputonly="no">

