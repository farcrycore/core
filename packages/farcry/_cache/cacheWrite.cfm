<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_cache/cacheWrite.cfm,v 1.2 2003/09/10 12:21:48 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 12:21:48 $
$Name: b201 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: write Cache Function $
$TODO: $

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
