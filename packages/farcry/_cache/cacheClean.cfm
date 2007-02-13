<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_cache/cacheClean.cfm,v 1.4 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: clean Cache Function $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- flush out entire block of caches --->
<cfif arguments.bShowResults eq "true">
	<!--- show blocks that have been flushed --->
	<cfoutput><div class="formtitle">Block<cfif listlen(arguments.cacheBlockName) gt 1>s</cfif> Cleaned:</div></cfoutput>
</cfif>

<!--- check there are blocks selected --->
<cfif listlen(arguments.cacheBlockName) gt 1>
	<cflock timeout="10" throwontimeout="Yes" name="CacheBlockRead_#application.applicationname#" type="EXCLUSIVE">
		<cfset blockcache = structget("server.dm_CacheBlock.#application.applicationname#")>
		<!--- loop over list of selected blocks --->
		<cfloop list="#arguments.cacheBlockName#" index="block">
			<!--- check block exists --->
			<cfif structkeyexists(blockcache, block)>
				<cflock timeout="10" throwontimeout="Yes" name="GeneratedContentCache_#application.applicationname#" type="EXCLUSIVE"><!--- possibility to get contention against cachewrite, but this is admin, so it'll throw and no probs... --->
					<cfset contentcache = structget("server.dm_generatedcontentcache.#application.applicationname#")>
					<cfset newList = "">
					
					<!--- loop over caches within block --->
					<cfloop index="element" list="#blockcache[block]#">
						<!--- concatinate blockName & cacheName (this is how caches are first named) --->
						<cfset elementFull = block & element>
						
						<!--- check if cache has expired --->
						<cfif contentcache[elementFull].cachetimeout neq 0 and contentcache[elementFull].cachetimestamp lt now() - contentcache[elementFull].cachetimeout>
							<!--- delete cache --->
							<cfset structdelete(contentcache, elementFull)>
							<cfset changed= true>
						<cfelse>
							<!--- only keep cache references to active caches --->
							<cfset newList = listappend(newList,element)>	
						</cfif>
					</cfloop>
					<!--- update block --->		
					<cfset blockcache[block] = newList>
				</cflock>
				<!--- check any changes have been made to block --->
				<cfif changed>
					<!--- output block name --->
					<cfoutput><span class="frameMenuBullet">&raquo;</span> #block#<br></cfoutput>
				<cfelse>
					<cfoutput>No caches needed cleaning.</cfoutput>
				</cfif>
								
			</cfif>
		</cfloop>
	</cflock>
	<cfoutput><p><hr></p></cfoutput>
<cfelse>
	<cfoutput>No blocks to clean<p><hr></p></cfoutput>
</cfif>