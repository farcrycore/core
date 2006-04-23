<cfset cachelookupname = stArgs.cacheBlockName & stArgs.cacheName>
<cfset read = false>
<cflock timeout="10" throwontimeout="No" name="GeneratedContentCache_#application.applicationname#" type="READONLY">
	<cfset success = true>
	<cfset contentcache = structget("server.dm_generatedcontentcache.#application.applicationname#")>
	<cfif structkeyexists(contentcache, cachelookupname)>
		<cfif contentcache[cachelookupname].cachetimestamp gt stArgs.dtCachetimeout>
			<cfoutput>#contentcache[cachelookupname].cache#</cfoutput>
			<cfset read = true>
		<cfelse>
			<cfset read = false>
		</cfif>
	</cfif>
</cflock>



<!--- <cflock timeout="10" throwontimeout="No" name="GeneratedContentCache_#application.applicationname#" type="READONLY">
	<cfset success = true>
	<cfset contentcache = structget("server.dm_generatedcontentcache.#application.applicationname#")>
	<cfif structkeyexists(contentcache, cachelookupname)>
		<cfif contentcache[cachelookupname].cachetimestamp gt stArgs.dtCachetimeout>
			<cfif isdefined("stArgs.r_output")>
				<cfset setvariable("caller.#stArgs.r_output#",  contentcache[cachelookupname].cache)>
			<cfelse>
				<cfoutput>#contentcache[cachelookupname].cache#</cfoutput>
			</cfif>
			<cfset setvariable("caller.#stArgs.r_cachehit#",  true)>
		<cfelse>
			<cfset setvariable("caller.#stArgs.r_cachehit#",  false)>
		</cfif>
	<cfelse>
		<cfset setvariable("caller.#stArgs.r_cachehit#",  false)>
	</cfif>
</cflock>
<cfif success eq false>
	<cfset setvariable("caller.#stArgs.r_cachehit#",  false)>
</cfif> --->