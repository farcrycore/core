<cflock timeout="5" throwontimeout="No" name="GeneratedContentCache_#application.applicationname#" type="EXCLUSIVE">
	<cfset contentcache = structget("server.dm_generatedcontentcache.#application.applicationname#")>
	<cfset structinsert(contentcache, stArgs.cacheBlockName & stArgs.cacheName, stArgs.stcacheblock, True)>
	<cfif len(stArgs.cacheBlockName)>
		<cflock timeout="5" throwontimeout="No" name="CacheBlockRead_#application.applicationname#" type="EXCLUSIVE">
			<cfset blockcache = structget("server.dm_CacheBlock.#application.applicationname#")>
			<cfif not structkeyexists(blockcache, stArgs.cacheBlockName)>
				<cfset structinsert(blockcache, stArgs.cacheBlockName, "")>
			</cfif>
			<cfset blockcachelist = blockcache[stArgs.cacheBlockName]>
			<cfif not listfind(blockcachelist, stArgs.cacheName)>
				<cfset blockcache[stArgs.cacheBlockName] = listappend(blockcachelist, stArgs.cacheName)>
			</cfif>
		</cflock>
	</cfif>
</cflock>
