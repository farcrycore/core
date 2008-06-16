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
$Header: /cvs/farcry/core/packages/farcry/cache.cfc,v 1.7 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: cache cfc $


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
		
		<cfset var changed = false>
		<cfset var blockcache = "">
		<cfset var block = "">
		<cfset var contentcache = "">
		<cfset var newList = "">
		<cfset var element = "">
		<cfset var elementFull = "">
		
		<cfinclude template="_cache/cacheClean.cfm">
	</cffunction>
	
	<cffunction name="cacheFlush" access="public" hint="Removes cache(s)">
		<cfargument name="cacheBlockName" type="string" required="false">
		<cfargument name="bShowResults" type="boolean" required="false" default="false">
		<cfargument name="lcachenames" type="string" required="false">
		
		<cfset var blockcache = "">
		<cfset var block = "">
		<cfset var contentcache = "">
		<cfset var element = "">
		<cfset var cache = "">
		<cfset var blockName = "">
		<cfset var newList = "">
		<cfset var checkCache = "">
		
		<cfinclude template="_cache/cacheFlush.cfm">
	</cffunction>
	
	<cffunction name="cacheRead" access="public" returntype="string" hint="Reads a cache">
		<cfargument name="cacheBlockName" type="string" required="true">
		<cfargument name="cacheName" type="string" required="true">
		<cfargument name="dtCachetimeout" type="date" required="true">
		
		<cfset var read = false>
		<cfset var cachelookupname = arguments.cacheBlockName & arguments.cacheName>
		<cfset var success = "">
		<cfset var contentcache = "">
		
		<cfinclude template="_cache/cacheRead.cfm">
		<cfreturn read>
	</cffunction>
	
	<cffunction name="cacheWrite" access="public" hint="Writes a cache">
		<cfargument name="cacheBlockName" type="string" required="true">
		<cfargument name="cacheName" type="string" required="true">
		<cfargument name="stCacheBlock" type="struct" required="true">
		
		<cfset var contentcache = "">
		<cfset var blockcache = "">
		<cfset var blockcachelist = "">
				
		<cfinclude template="_cache/cacheWrite.cfm">
	</cffunction>
	
	<cffunction name="cacheALL" access="public" hint="Caches entire website">
		<cfscript>
			var navFilter=arrayNew(1);
			var qNav = "";
			navfilter[1]="status IN (#listQualify(request.mode.lvalidstatus, "'")#)";
			// get navigation elements
			qNav = application.factory.oTree.getDescendants(objectid=application.navid.home, depth=4, afilter=navFilter);
		</cfscript>
		
		<!--- loop over all pages and hit page to create caches --->
		<cfloop query="qNav">
			<cfhttp url="http://#cgi.http_host#/#application.url.conjurer#?objectid=#qNav.objectid#" timeout="20"></cfhttp>
		</cfloop>
	</cffunction>
</cfcomponent>