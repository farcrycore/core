<cfcomponent name="SiteMapData" displayname="Site" hint="I am site map data and i hold data for a site">
	
	<cfset variables.xmlString="">
	
	<!--- public /////////--->
	<cffunction name="init" returntype="farcry.core.packages.googleSiteMap.sitemap.SiteMapData" access="public">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setXMLString" access="public" description="set the xmlData" returntype="void">
		<cfargument name="xmlData" type="string" required="true">
		
		<cfset variables.xmlData=arguments.xmlData>
	</cffunction>
	
	<cffunction name="getXMLString" access="public" description="returns the xmlData that has been set" returntype="string">
		<cfreturn variables.xmlData>
	</cffunction>
	
	<!--- private /////////--->
</cfcomponent>