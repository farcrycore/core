<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/stats.cfc,v 1.33 2005/10/28 03:41:37 paul Exp $
$Author: paul $
$Date: 2005/10/28 03:41:37 $
$Name: milestone_3-0-1 $
$Revision: 1.33 $

|| DESCRIPTION || 
$Description: statistics cfc $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayName="Statistic" hint="Functions for site and object statistics reports">

<!------------------------------------------------------------------------
stats properties
------------------------------------------------------------------------->
<cfproperty name="logId" type="uuid" hint="Unique identifier for log entry" required="yes" default="">
<cfproperty name="logDateTime" type="date" hint="Date and Time of log entry being recorded" required="yes" default="">
<cfproperty name="pageId" type="uuid" hint="Unique identifier of primary object being logged" required="yes" default="">
<cfproperty name="navId" type="uuid" hint="Unique identifier of navigation object for the primary object being logged" required="no" default="">
<cfproperty name="remoteIP" type="uuid" hint="IP address of user" required="no" default="">
<cfproperty name="userId" type="uuid" hint="Unique identifier of registered user" required="no" default="">

<!------------------------------------------------------------------------
object methods 
------------------------------------------------------------------------->
<cffunction name="deploy" access="public" output="false" returntype="struct" hint="Deploy table structure for stats subsystem.">
	<!--- arguments --->
	<cfargument name="bDropTable" default="false" type="boolean" required="No">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#" hint="Database DSN">
	
	<cfinclude template="_stats/deploy.cfm">

	<cfreturn stStatus>
</cffunction>

<cffunction name="logEntry" access="public" hint="Add entry to stats log for page">
	<cfargument name="pageId" type="uuid" required="true">
	<cfargument name="navId" type="uuid" required="true">
	<cfargument name="remoteIP" type="string" required="true">
	<cfargument name="userId" type="string" required="true">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="sessionId" type="string" required="true" hint="sessionId for visitor">
	<cfargument name="browser" type="string" required="true" hint="browser used by visitor">
	<cfargument name="referer" type="string" required="false" hint="The referer that pointed the user to this page" default="#cgi.http_referer#">
	<cfargument name="locale" type="string" required="false" hint="The locale of user" default="unknown">
	<cfargument name="os" type="string" required="false" hint="The operating system of user" default="unknown">
	
	<cfinclude template="_stats/log.cfm">
</cffunction>

<cffunction name="logSearch" access="public" hint="Add entry to stats log for search queries">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="searchString" type="string" required="true" hint="Search string inputted by user">
	<cfargument name="results" type="numeric" required="true" hint="Number of results returned by search">
	<cfargument name="lCollections" type="string" required="true" hint="List of collections search against" default="">
	<cfargument name="referer" type="string" required="true" hint="The referer that pointed the user to this page" default="#cgi.http_referer#">
	<cfargument name="remoteIP" type="string" required="true" default="#trim(cgi.REMOTE_ADDR)#" hint="Remote address of user performing search">
	
	<cfinclude template="_stats/logSearch.cfm">
</cffunction>

<cffunction name="getSearchStats" access="public" returntype="query" hint="Returns full log results for site searches">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="dateRange" type="string" required="true" default="all">
		
	<cfinclude template="_stats/getSearchStats.cfm">
	<cfreturn qGetSearchStats>
</cffunction>

<cffunction name="getSearchStatsNoResults" access="public" returntype="query" hint="Returns results for site searches that return no results">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="dateRange" type="string" required="true" default="all">
		
	<cfinclude template="_stats/getSearchStatsNoResults.cfm">
	<cfreturn qGetSearchStats>
</cffunction>

<cffunction name="getSearchStatsMostPopular" access="public" returntype="query" hint="Returns results for the most popular site searches">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="dateRange" type="string" required="true" default="all">
		
	<cfinclude template="_stats/getSearchStatsMostPopular.cfm">
	<cfreturn qGetSearchStats>
</cffunction>

<cffunction name="getPageStats" access="public" returntype="query" hint="Returns full log results">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="before" required="No" type="date">
	<cfargument name="after" required="No" type="date">
		
	<cfinclude template="_stats/getPageStats.cfm">
	<cfreturn qGetPageStats>
</cffunction>

<cffunction name="getPageStatsByDate" access="public" returntype="struct" hint="Returns log results for a particular page inbetween two specified dates">
	<cfargument name="pageId" type="uuid" required="false">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="before" required="No" type="date">
	<cfargument name="after" required="No" type="date">
		
	<cfinclude template="_stats/getPageStatsByDate.cfm">
	<cfreturn stReturn>
</cffunction>

<cffunction name="getPageStatsByDay" access="public" returntype="query" hint="Returns log results for a particular page on a particular day">
	<cfargument name="pageId" type="string" required="false">
	<cfargument name="day" type="date" required="true">
	<cfargument name="showAll" type="boolean" required="false" default="false">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="dbowner" type="string" required="false" default="#application.dbowner#">
	
	<cfinclude template="_stats/getPageStatsByDay.cfm">
	<cfreturn qGetPageStatsByDay>
</cffunction>

<cffunction name="getPageStatsByWeek" access="public" returntype="query" hint="Returns log results for a particular page over a period of weeks">
	<cfargument name="pageId" type="string" required="false">
	<cfargument name="day" type="date" required="true">
	<cfargument name="showAll" type="boolean" required="false" default="false">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="dbowner" type="string" required="false" default="#application.dbowner#">
	
	<cfinclude template="_stats/getPageStatsByWeek.cfm">
	<cfreturn qGetPageStatsByWeek>
</cffunction>

<cffunction name="getBranchStatsByDate" access="public" returntype="struct" hint="Returns log results for a branch inbetween two specified dates">
	<cfargument name="navId" type="uuid" required="false">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="before" required="No" type="date">
	<cfargument name="after" required="No" type="date">
		
	<cfinclude template="_stats/getBranchStatsByDate.cfm">
	<cfreturn stReturn>
</cffunction>

<cffunction name="getBranchStatsByDay" access="public" returntype="query" hint="Returns log results for a branch on a particular day">
	<cfargument name="navId" type="string" required="false">
	<cfargument name="day" type="date" required="true">
	<cfargument name="showAll" type="boolean" required="false" default="false">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	
	<cfinclude template="_stats/getBranchStatsByDay.cfm">
	<cfreturn qGetPageStatsByDay>
</cffunction>

<cffunction name="getBranchStatsByWeek" access="public" returntype="query" hint="Returns log results for a branch over a period of weeks">
	<cfargument name="navId" type="string" required="false">
	<cfargument name="day" type="date" required="true">
	<cfargument name="showAll" type="boolean" required="false" default="false">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	
	<cfinclude template="_stats/getBranchStatsByWeek.cfm">
	<cfreturn qGetPageStatsByWeek>
</cffunction>

<cffunction name="getDownloadStats" access="public" returntype="query" hint="Returns log results for all downloaded objects">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		
	<cfinclude template="_stats/getDownloadStats.cfm">
	<cfreturn qGetDownloadStats>
</cffunction>

<cffunction name="getMostViewed" access="public" returntype="query" hint="Returns log results for most viewed objects">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="typeName" type="string" required="false" hint="Filter by typeName">
	<cfargument name="maxRows" type="string" required="true" default="20" hint="Maximum number of results returned">
	<cfargument name="dateRange" type="string" required="true" default="all">
	<cfargument name="dbowner" type="string" required="false" default="#application.dbowner#">
		
	<cfinclude template="_stats/getMostViewed.cfm">
	<cfreturn qGetMostViewed>
</cffunction>

<cffunction name="getSessions" access="public" returntype="query" hint="Returns the number of sessions in a given time frame">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="dateRange" type="string" required="true" default="all">
		
	<cfinclude template="_stats/getSessions.cfm">
	<cfreturn qGetSessions>
</cffunction>

<cffunction name="getBrowsers" access="public" returntype="query" hint="Returns log results for browsers used">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="dateRange" type="string" required="true" default="all">
	<cfargument name="maxRows" type="string" required="true" default="20" hint="Maximum number of results returned">
			
	<cfinclude template="_stats/getBrowsers.cfm">
	<cfreturn qVisitors>
</cffunction>

<cffunction name="getVisitors" access="public" returntype="query" hint="Returns log results for visitors">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="maxRows" type="string" required="true" default="20" hint="Maximum number of results returned">
	<cfargument name="dateRange" type="string" required="true" default="all">
	<cfargument name="remoteIP" type="string" required="false" hint="filter by IP Address">
		
	<cfinclude template="_stats/getVisitors.cfm">
	<cfreturn qVisitors>
</cffunction>

<cffunction name="getVisitorPath" access="public" returntype="query" hint="Returns log results for pages viewed by visitor in a session">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="sessionId" type="string" required="true" hint="ID of visitor session">
			
	<cfinclude template="_stats/getVisitorPath.cfm">
	<cfreturn qPath>
</cffunction>

<cffunction name="getVisitorStatsByDate" access="public" returntype="struct" hint="Returns log results for a particular page inbetween two specified dates">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="before" required="No" type="date">
	<cfargument name="after" required="No" type="date">
		
	<cfinclude template="_stats/getVisitorStatsByDate.cfm">
	<cfreturn stReturn>
</cffunction>

<cffunction name="getVisitorStatsByDay" access="public" returntype="query" hint="Returns log results for a particular page on a particular day">
	<cfargument name="day" type="date" required="true">
	<cfargument name="showAll" type="boolean" required="false" default="false">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
			
	<cfinclude template="_stats/getVisitorStatsByDay.cfm">
	<cfreturn qGetPageStatsByDay>
</cffunction>

<cffunction name="getVisitorStatsByWeek" access="public" returntype="query" hint="Returns log results for a particular page over a period of weeks">
	<cfargument name="day" type="date" required="true">
	<cfargument name="showAll" type="boolean" required="false" default="false">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
			
	<cfinclude template="_stats/getVisitorStatsByWeek.cfm">
	<cfreturn qGetPageStatsByWeek>
</cffunction>

<cffunction name="getReferers" access="public" returntype="query" hint="Returns log results for referers">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="maxRows" type="string" required="true" default="20" hint="Maximum number of results returned">
	<cfargument name="dateRange" type="string" required="true" default="all">
	<cfargument name="filter" type="string" required="false" default="all">
		
	<cfinclude template="_stats/getReferers.cfm">
	<cfreturn qGetReferers>
</cffunction>

<cffunction name="getLocales" access="public" returntype="query" hint="Returns log results for locales">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="maxRows" type="string" required="true" default="20" hint="Maximum number of results returned">
	<cfargument name="dateRange" type="string" required="true" default="all">
		
	<cfinclude template="_stats/getLocales.cfm">
	<cfreturn qGetLocales>
</cffunction>

<cffunction name="getOS" access="public" returntype="query" hint="Returns log results for operating systems">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="maxRows" type="string" required="true" default="20" hint="Maximum number of results returned">
	<cfargument name="dateRange" type="string" required="true" default="all">
		
	<cfinclude template="_stats/getOS.cfm">
	<cfreturn qGetOS>
</cffunction>

<cffunction name="getBrowser">
	<cfargument name="user_agent" required="No" default="#cgi.http_user_agent#">
	
	<cfinclude template="_stats/getUserBrowser.cfm">	
	<cfreturn stBrowser>
</cffunction>

<cffunction name="getGoogleStats" access="public" returntype="query" hint="Returns log results for google referals">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="maxRows" type="string" required="true" default="20" hint="Maximum number of results returned">
	<cfargument name="dateRange" type="string" required="true" default="all">
	
	<cfinclude template="_stats/getGoogleStats.cfm">	
	<cfreturn qGetGoogleStats>
</cffunction>

<cffunction name="getActiveVisitors" hint="Returns a query of current sessions" returntype="query">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="order" type="string" default="sessionTime" required="true" hint="Field to order by">
	<cfargument name="orderDirection" type="string" default="asc" required="true" hint="Order by ascending or descending">
	
	<cfinclude template="_stats/getActiveVisitors.cfm">	
	<cfreturn qActive>
</cffunction>

<cffunction name="getUserOS">
	<cfargument name="user_agent" default="#cgi.http_user_agent#">
	<cfscript>
		// regexes to use 
        regex_windows  = '([^dar]win[dows]*)[\s]?([0-9a-z]*)[\w\s]?([a-z0-9.]*)'; 
        regex_mac      = '(68[k0]{1,3})|(ppc mac os x)|([p\S]{1,5}pc)|(darwin)'; 
        regex_linux    = 'x11|linux'; 
		regex_unix	   = 'unix';
		// look for Windows Box 
		os = "unknown";//
		//based on guidlines from http://www.mozilla.org/build/revised-user-agent-strings.html
        if(reFindNoCase(regex_windows,user_agent)) 
		{   
			user_agent = removeChars(arguments.user_agent,1,reFindNoCase(regex_windows,arguments.user_agent));
		 	// Establish NT 5.1 as Windows XP 
            if (findNoCase("NT 5.1",user_agent))
				os = "Windows XP";
			//Establish NT 5.0 and Windows 2000 as win2k 
			else if (findNoCase("NT 5.0",user_agent))
				os = "Windows 2000";
			else if (findNoCase("9x 4.9",user_agent))
				os = "Windows ME";
			else if (findNoCase("win98",user_agent))
				os = "Windows 98";	
			else if (findNoCase("win95",user_agent))
				os = "Windows 95";		
			else if (findNoCase("NT4",user_agent))
				os = "Windows NT 4.0";	
			else if (findNoCase("16bit",user_agent) OR findNoCase("win3.1",user_agent))
				os = "Windows 3.1";
	     } 
	    // look for mac 
   	    else if( reFindNoCase(regex_mac,user_agent)) 
        {   			
			os = "Mac";
			if (findNoCase("68",user_agent))
				os = os & " 68k";
			else if	(findNoCase("os x",user_agent))
				os = os & " OSX";
			else if	(findNoCase("ppc",user_agent))	
				os = os & " PPC";
       } 
     	//linux  
        else if(reFindNoCase(regex_linux,user_agent)) 
        	os = 'linux';  
		//unix	
        else if (reFindNoCase(regex_unix,user_agent)) 
			os = 'unix';
	</cfscript>		
	<cfreturn os>
</cffunction> 	

<cffunction name="getOwnedBy" access="public" returntype="struct" hint="Returns a break down of content tyoe owned by each user">
	<cfset var stLocal = StructNew()>
	<cfset var stReturn = StructNew()>
	<cfset stReturn.returnCode = 1>
	<cfset stReturn.returnMessage = "">

	<cfinclude template="_stats/getOwnedBy.cfm">

	<cfreturn stReturn>
</cffunction>

<cffunction name="fPurgeStatistics" access="public" returntype="struct" hint="deletes records older than a certain date" output="false">
	<cfargument name="purgeDate" required="true" type="date">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfset var stLocal = StructNew()>
	<cfset stLocal.stReturn = StructNew()>
	<cfset stLocal.stReturn.bSuccess = 1>
	<cfset stLocal.stReturn.message = "">
	
	<cftry>
		<cfquery name="qTotal" datasource="#arguments.dsn#">
		SELECT	count(logid) as total_logs
		FROM 	#application.dbowner#stats
		</cfquery>

		<cfquery name="qPurged" datasource="#arguments.dsn#">
		SELECT	count(logid) as total_logs
		FROM 	#application.dbowner#stats
		WHERE	logdatetime < <cfqueryparam value="#CreateODBCDate(arguments.purgeDate)#" cfsqltype="cf_sql_date">
		</cfquery>

		<cfquery name="qPurgeData" datasource="#arguments.dsn#">
		DELETE
		FROM	#application.dbowner#stats
		WHERE	logdatetime < <cfqueryparam value="#CreateODBCDate(arguments.purgeDate)#" cfsqltype="cf_sql_date">
		</cfquery>

		<cfset totalPercentage = 0>
		<cfif qTotal.total_logs NEQ 0>
			<cfset totalPercentage = numberformat(((qPurged.total_logs/qTotal.total_logs)*100),"__.__")>
		</cfif>

		<cfset stLocal.stReturn.message = "Statistics Sucessfully purged, (#totalPercentage#% removed).<br />">

		<cfcatch>
			<cfset stLocal.stReturn.bSuccess = 0>
			<cfset stLocal.stReturn.message = cfcatch.message>		
		</cfcatch>
	</cftry>
	<cfreturn stLocal.stReturn>
</cffunction>

</cfcomponent>