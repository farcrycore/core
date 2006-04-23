<cfsetting enablecfoutputonly="yes">
<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<!--- get cache details --->
<cfset contentcache = structget("server.dm_generatedcontentcache.#application.applicationname#")>
<!--- show contents of cache --->
<cfoutput>#contentcache[url.cache].cache#</cfoutput>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="no">