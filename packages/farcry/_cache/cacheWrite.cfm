<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

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
