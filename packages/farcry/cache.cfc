<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/cache.cfc,v 1.4 2003/09/10 12:21:48 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 12:21:48 $
$Name: b201 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: cache cfc $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayname="Cache" hint="Manages cache functions for FarCry">
	<cffunction name="cacheClean" access="public" hint="Removes cache(s) that have timed out in a cache block">
		<cfargument name="cacheBlockName" type="string" required="true">
		<cfargument name="bShowResults" type="boolean" required="false" default="false">
		
		<cfinclude template="_cache/cacheClean.cfm">
	</cffunction>
	
	<cffunction name="cacheFlush" access="public" hint="Removes cache(s)">
		<cfargument name="cacheBlockName" type="string" required="false">
		<cfargument name="bShowResults" type="boolean" required="false" default="false">
		<cfargument name="lcachenames" type="string" required="false">
						
		<cfinclude template="_cache/cacheFlush.cfm">
	</cffunction>
	
	<cffunction name="cacheRead" access="public" returntype="string" hint="Reads a cache">
		<cfargument name="cacheBlockName" type="string" required="true">
		<cfargument name="cacheName" type="string" required="true">
		<cfargument name="dtCachetimeout" type="date" required="true">
		
		<cfinclude template="_cache/cacheRead.cfm">
		<cfreturn read>
	</cffunction>
	
	<cffunction name="cacheWrite" access="public" hint="Writes a cache">
		<cfargument name="cacheBlockName" type="string" required="true">
		<cfargument name="cacheName" type="string" required="true">
		<cfargument name="stcacheblock" type="struct" required="true">
				
		<cfinclude template="_cache/cacheWrite.cfm">
	</cffunction>
	
	<cffunction name="cacheALL" access="public" hint="Caches entire website">
		<cfscript>
			// get navigation elements
			navFilter=arrayNew(1);
			navfilter[1]="status IN (#listQualify(request.mode.lvalidstatus, "'")#)";
			qNav = application.factory.oTree.getDescendants(objectid=application.navid.home, depth=4, afilter=navFilter);
		</cfscript>
		
		<!--- loop over all pages and hit page to create caches --->
		<cfloop query="qNav">
			<cfhttp url="http://#cgi.http_host#/#application.url.conjurer#?objectid=#qNav.objectid#" timeout="20"></cfhttp>
		</cfloop>
	</cffunction>
</cfcomponent>