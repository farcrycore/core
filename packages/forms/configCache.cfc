<cfcomponent displayname="Caching" extends="forms" key="cache" output="false"
	hint="Configure miscellaneous data caches">

	<cfproperty name="maximumFriendlyURLs" type="string" default="1000" required="false"
		ftSeq="1" ftFieldset="Caching" ftLabel="Maximum Friendly URLs"
		ftType="string" 
		ftHint="Maximum number of friendly URLs to store in in-memory object broker">

	<cfproperty name="configTimeout" type="string" default="0" required="false"
		ftSeq="2" ftFieldset="Caching" ftLabel="Config Timeout (m)"
		ftType="string" 
		ftHint="How often should the application.config scope be refreshed from object broker. Set to 0 to never refresh. Config access through application.fapi.getConfig() will always use the cache.">

	<cfproperty name="navidTimeout" type="string" default="0" required="false"
		ftSeq="3" ftFieldset="Caching" ftLabel="Navigation Timeout (m)"
		ftType="string" 
		ftHint="How often should the application.navid scope be refreshed from object broker. Set to 0 to never refresh. NavID access through application.fapi.getNavID() will always use the cache.">

	<cfproperty name="catidTimeout" type="string" default="0" required="false"
		ftSeq="4" ftFieldset="Caching" ftLabel="Category Timeout (m)"
		ftType="string" 
		ftHint="How often should the application.catid scope be refreshed from object broker. Set to 0 to never refresh. CatID access through application.fapi.getCatID() will always use the cache.">


	<cffunction name="process" access="public" output="false" returntype="struct">
		<cfargument name="fields" type="struct" required="true" />
		
		<cfset application.fc.lib.objectbroker.configureType("fuLookup",arguments.fields.maximumFriendlyURLs) />

		<cfreturn arguments.fields />
	</cffunction>

</cfcomponent>