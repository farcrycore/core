<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$


|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_category/deployCategories.cfm,v 1.7 2003/05/27 07:14:03 brendan Exp $
$Author: brendan $
$Date: 2003/05/27 07:14:03 $
$Name: b131 $
$Revision: 1.7 $


|| DESCRIPTION ||
$Description: <insert short description of functionality> $
$TODO: <whatever todo's needed -- can be inline also>$


|| DEVELOPER ||
$Developer: Daniel Morphett (daniel@daemon.com.au) $



|| ATTRIBUTES ||
$in: stArgs.bDropTables	: drop the existing tables if true. destructive! $
$out: <separate entry for each variable>$
--->                                                                                                                                     <cfsetting enablecfoutputonly="Yes">

<cfscript>
	stStatus = structNew();
	stStatus.message = "";
	stStatus.status = false;
	stArgs.bdropTables = true;
</cfscript>

<cfif stArgs.bDropTables>
<!--- <cftry> --->
	<cfswitch expression="#application.dbtype#">
	<cfcase value="ora">
		<cfquery datasource="#stArgs.dsn#" name="qExists">
			SELECT * FROM #application.dbowner#USER_TABLES
			WHERE TABLE_NAME = 'CATEGORIES'
		</cfquery>
		<cfif qExists.recordCount>
			<cfquery datasource="#stArgs.dsn#">
			DROP TABLE #application.dbowner#CATEGORIES
			</cfquery>
		</cfif>	
		<cfquery datasource="#stArgs.dsn#" name="qExists">
			SELECT * FROM #application.dbowner#USER_TABLES
			WHERE TABLE_NAME = 'REFCATEGORIES'
		</cfquery>
		<cfif qExists.recordCount>
			<cfquery datasource="#stArgs.dsn#">
				DROP TABLE #application.dbowner#REFCATEGORIES
			</cfquery>
			
		</cfif>	
	</cfcase>
	<cfcase value="mysql">
		<cfquery datasource="#stArgs.dsn#">
        	DROP TABLE IF EXISTS categories	
		</cfquery>
		<cfquery datasource="#stArgs.dsn#">
        	DROP TABLE IF EXISTS refCategories
		</cfquery>
	</cfcase>
	<cfdefaultcase>
	<cftransaction>
		<cfquery datasource="#stArgs.dsn#">
        if exists (select * from sysobjects where name = 'categories')
		DROP TABLE categories	

    	-- return recordset to stop CF bombing out?!?
    	select count(*) as blah from sysobjects
		</cfquery>
		<cfquery datasource="#stArgs.dsn#">
        if exists (select * from sysobjects where name = 'refCategories')
        DROP TABLE refCategories

    	-- return recordset to stop CF bombing out?!?
    	select count(*) as blah from sysobjects
		</cfquery>
	</cftransaction>	
	</cfdefaultcase>
	</cfswitch>	
	<cfset stStatus.message = "refCategories,categories tables successfully dropped <br>">
	<!--- <cfcatch type="any">
		<!--- TODO - put some details of the cfcatch.Message --->
		<cfset stStatus.message = "refCategories,categories tables unsuccessfully dropped <br>"> 
	</cfcatch>
</cftry>	
--->
</cfif> 
<cflock name="#createUUID()#" type="exclusive" timeout="50">
<cftry>
	<cfswitch expression="#application.dbtype#">
	<cfcase value="ora">
		
		<cfquery datasource="#stArgs.dsn#">
			CREATE TABLE #application.dbowner#CATEGORIES
			(
			CATEGORYID VARCHAR2(50) NOT NULL,
			CATEGORYLABEL VARCHAR2(255) NOT NULL
			)
		</cfquery>
		<cfquery datasource="#stArgs.dsn#">
			CREATE TABLE #application.dbowner#REFCATEGORIES
			(
			CATEGORYID VARCHAR2(50) NOT NULL,
			OBJECTID VARCHAR2(50) NOT NULL
			)
		</cfquery>
		
	</cfcase>
	<cfcase value="mysql">
		<cfquery datasource="#stArgs.dsn#">
		CREATE TABLE #application.dbowner#categories
		(
			categoryID VARCHAR(50) NOT NULL,
			categoryLabel VARCHAR(255) NOT NULL
		)
		</cfquery>
		<cfquery datasource="#stArgs.dsn#">
		CREATE TABLE #application.dbowner#refCategories
		(
			categoryid VARCHAR (50) NOT NULL,
			objectID VARCHAR(50) NOT NULL
		)
		</cfquery>
	</cfcase>
	<cfdefaultcase>
	<cftransaction>
	<!--- Create category and refCategories Tables --->
	<cfquery datasource="#stArgs.dsn#">
	CREATE TABLE #application.dbowner#categories
	(
		[categoryID] [VARCHAR] (50) NOT NULL,
		[categoryLabel] [NVARCHAR] (512) NOT NULL
	);
	</cfquery>
	<cfquery datasource="#stArgs.dsn#">
	CREATE TABLE #application.dbowner#refCategories
	(
		[categoryid] [VARCHAR] (50) NOT NULL,
		[objectID] [VARCHAR] (50) NOT NULL
	);
	</cfquery>
	</cftransaction>
	</cfdefaultcase>
	</cfswitch>
	<cfinvoke component="#application.packagepath#.farcry.tree"	 method="setRootNode" objectName = "root" typename = "categories" objectID="#createUUID()#" returnvariable="stReturn">
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

