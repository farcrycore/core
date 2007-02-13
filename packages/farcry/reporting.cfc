<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/reporting.cfc,v 1.4 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: reporting cfc $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayName="reporting" hint="Functions for reporting on my farcry tab">
	<cffunction name="getAgeBreakdown" access="public" returntype="struct" hint="Returns a count of objects broken down into date segments">
		<cfargument name="breakdown" type="string" required="false" default="25,50,75,100">
				
		<cfinclude template="_reporting/getAgeBreakdown.cfm">
		
		<cfreturn stAge>
	</cffunction>

	<cffunction name="getRecentObjects" access="public" returntype="struct" hint="Returns a recent list of Objects added to the system">
		<cfargument name="numberOfObjects" type="string" required="false" default="5">
		<cfargument name="objectType" type="string" required="true">
				
		<cfinclude template="_reporting/getRecentObjects.cfm">
		
		<cfreturn stRecentObjects>
	</cffunction>
</cfcomponent>