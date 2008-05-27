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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_cache/cacheFlush.cfm,v 1.4 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: flush Cache Function $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfif isdefined("arguments.cacheBlockName")>
	<!--- flush out entire block of caches --->
		
	<cfif arguments.bShowResults eq "true">
		<!--- show blocks that have been flushed --->
		<cfoutput><div class="formtitle">Block<cfif listlen(arguments.cacheBlockName) gt 1>s</cfif> Flushed:</div></cfoutput>
	</cfif>
	
	<!--- check there are blocks selected --->
	<cfif listlen(arguments.cacheBlockName) gt 0>
		<cflock timeout="10" throwontimeout="Yes" name="CacheBlockRead_#application.applicationname#" type="EXCLUSIVE">
			<cfset blockcache = structget("server.dm_CacheBlock.#application.applicationname#")>
			<!--- loop over list of selected blocks --->
			<cfloop list="#arguments.cacheBlockName#" index="block">
				<!--- check block exists --->
				<cfif structkeyexists(blockcache, block)>
					<cflock timeout="10" throwontimeout="Yes" name="GeneratedContentCache_#application.applicationname#" type="EXCLUSIVE"><!--- possibility to get contention against cachewrite, but this is admin, so it'll throw and no probs... --->
						<cfset contentcache = structget("server.dm_generatedcontentcache.#application.applicationname#")>
						<!--- loop over cahces within block --->
						<cfloop index="element" list="#blockcache[block]#">
							<!--- delete cache --->
							<cfset structdelete(contentcache, block & element)>
						</cfloop>		
					</cflock>
					<!--- delete block --->
					<cfset structdelete(blockcache,block)>
					<cfif arguments.bShowResults eq "true">
						<cfoutput><span class="frameMenuBullet">&raquo;</span> #block#<br></cfoutput>
					</cfif>
				</cfif>
			</cfloop>
		</cflock>
		<cfif arguments.bShowResults eq "true">
			<cfoutput><p><hr></p></cfoutput>
		</cfif>
	<cfelse>
		<cfif arguments.bShowResults eq "true">
			<cfoutput>No blocks to Flush<p><hr></p></cfoutput>
		</cfif>
	</cfif>
<cfelse>
	<!--- flush individual caches --->
	<cfparam name="arguments.lcachenames" default="">
	<cfoutput><div class="formtitle">Cache<cfif listlen(arguments.lcachenames) gt 1>s</cfif> Flushed:</div></cfoutput>
	<!--- check there are caches selected --->
	<cfif listlen(arguments.lcachenames) gt 0>
		<cflock timeout="20" throwontimeout="Yes" name="GeneratedContentCache_#application.applicationname#" type="EXCLUSIVE">
			<cfset contentcache = structget("server.dm_generatedcontentcache.#application.applicationname#")>
			<!--- loop over selected chaches --->
			<cfloop index="cache" list="#arguments.lcachenames#">
				<!--- check cache exists --->
				<cfif structkeyexists(contentcache, cache)>
					<cfoutput><span class="frameMenuBullet">&raquo;</span> #cache#<br></cfoutput>
					<!--- delete cache --->
					<cfset structdelete(contentcache, cache)>
					
					<!--- delete reference to cache in cache block --->
					<cflock timeout="10" throwontimeout="Yes" name="CacheBlockRead_#application.applicationname#" type="EXCLUSIVE">
						<cfset blockcache = structget("server.dm_CacheBlock.#application.applicationname#")>
						<!--- loop over each block cache --->
						<cfloop collection="#blockCache#" item="blockName">
							<!--- check blockName is set at start of Cache --->
							<cfif listcontains(cache,blockName)>
								<!--- check block has a cache --->
								<cfif structkeyexists(blockcache, blockName)>
									<cflock timeout="10" throwontimeout="Yes" name="GeneratedContentCache_#application.applicationname#" type="EXCLUSIVE">
										<cfset newList = "">
										<!--- loop over each cache in block ---> 
										<cfloop list="#blockcache[blockName]#" index="checkCache">
											<!--- check if cache in block is same as cache just deleted --->
											<cfif listcontains(cache,checkCache) eq 0>
												<!--- only keep cache references to active caches --->
												<cfset newList = listappend(newList,checkCache)>
											</cfif>
										</cfloop>
										<!--- update block --->
										<cfset blockcache[blockName] = newList>
									</cflock>
								</cfif>
							</cfif>
						</cfloop>
					</cflock>
					
				</cfif>
			</cfloop>
		</cflock>
		<cfoutput><p><hr></p></cfoutput>
	<cfelse>
		<cfoutput>No caches to Flush<p><hr></p></cfoutput>
	</cfif>
</cfif>