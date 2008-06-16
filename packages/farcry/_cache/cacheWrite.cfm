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
$Header: /cvs/farcry/core/packages/farcry/_cache/cacheWrite.cfm,v 1.3 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: write Cache Function $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cflock timeout="5" throwontimeout="No" name="GeneratedContentCache_#application.applicationname#" type="EXCLUSIVE">
	<cfset contentcache = structget("server.dm_generatedcontentcache.#application.applicationname#")>
	<cfset structinsert(contentcache, arguments.cacheBlockName & arguments.cacheName, arguments.stcacheblock, True)>
	<cfif len(arguments.cacheBlockName)>
		<cflock timeout="5" throwontimeout="No" name="CacheBlockRead_#application.applicationname#" type="EXCLUSIVE">
			<cfset blockcache = structget("server.dm_CacheBlock.#application.applicationname#")>
			<cfif not structkeyexists(blockcache, arguments.cacheBlockName)>
				<cfset structinsert(blockcache, arguments.cacheBlockName, "")>
			</cfif>
			<cfset blockcachelist = blockcache[arguments.cacheBlockName]>
			<cfif not listfind(blockcachelist, arguments.cacheName)>
				<cfset blockcache[arguments.cacheBlockName] = listappend(blockcachelist, arguments.cacheName)>
			</cfif>
		</cflock>
	</cfif>
</cflock>
