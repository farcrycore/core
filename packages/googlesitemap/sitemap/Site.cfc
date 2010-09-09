<cfcomponent name="Site" displayname="Site" hint="I am a site for a site map">
	
	<cfset variables.oSiteMapData="">
	<cfset variables.oXMLData="">
	<cfset variables.domainName="">
	<cfset variables.siteName="">
	
	<!--- public /////////--->
	<cffunction name="init" access="public">
		<cfargument name="domainName" required="false" type="string" default="">
		<cfargument name="siteName" required="false" type="string" default="">
		
		<cfset setDomainName(arguments.domainName)>
		<cfset setSiteName(arguments.siteName)>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setDomainName" access="public" returntype="void" description="sets the domain name for this site">
		<cfargument name="domainName" required="true" type="string">
		
		<cfset variables.domainName=arguments.domainName>
	</cffunction>
	
	<cffunction name="getDomainName" access="public" returntype="string" description="return the domain name for this site">
		<cfreturn variables.domainName>
	</cffunction>
	
	<cffunction name="setSiteName" access="public" returntype="void" description="sets the site name for this site">
		<cfargument name="siteName" required="true" type="string">
		
		<cfset variables.siteName=arguments.siteName>
	</cffunction>
	
	<cffunction name="getSiteName" access="public" returntype="string" description="return the site name for this site">
		<cfreturn variables.siteName>
	</cffunction>
	
	<cffunction name="setSiteMapData" access="public" description="sets the site map data object" returntype="void">
		<cfargument name="oSiteMapData" required="true" type="farcry.core.packages.googleSiteMap.sitemap.SiteMapData">
															  
		<cfset variables.oSiteMapData=arguments.oSiteMapData>
	</cffunction>
	
	<cffunction name="getSiteMapData" access="public" returntype="farcry.core.packages.googleSiteMap.sitmap.site.SiteMapData" description="returns the SiteMapData object">
		
		<cfreturn variables.oSiteMapData>
	</cffunction>
	
	<cffunction name="setSiteMap" access="public" hint="sets the oXMLData" returntype="void">
		<cfargument name="oXMLData" type="xml" required="true">
		
		<cfset variables.oXMLData=arguments.oXMLData>
	</cffunction>
	
	<cffunction name="getSiteMap" returntype="xml" access="public" description="returns xml object created by createSiteMap">
		<cfreturn variables.oXMLData>
	</cffunction>
		
	
	<cffunction name="createSiteMap" access="public" returntype="void" description="create an xml object out of SiteMapData">
		<cfargument name="siteMapNameSpace" required="false" default="http://www.sitemaps.org/schemas/sitemap/0.9">
		<cfargument name="newsNameSpace" required="false" default="http://www.google.com/schemas/sitemap-news/0.9">
		<cfargument name="videoNameSpace" required="false" default="http://www.google.com/schemas/sitemap-news/0.9">
		
		<cfset var oXMLSiteData="">
		<cfset var newsPos=0>
		<cfset var vidPos=0>
		<cfset var googleSiteMapXML="">
		
		<!--- first check what we have in the site map data --->
		<!--- news? --->
		<cfset newsPos=find("n:news",variables.oSiteMapData.getXMLString())>
		<!--- videos? --->
		<cfset vidPos=find("video:video",variables.oSiteMapData.getXMLString())>

		<!--- build the site map xml String --->
		<cfsavecontent variable="googleSiteMapXML">
			<cfoutput>
				<?xml version="1.0" encoding="UTF-8"?>
				<urlset xmlns="#arguments.siteMapNameSpace#"
			</cfoutput>
			<cfif newsPos>
			     <cfoutput>xmlns:n="#arguments.newsNameSpace#"</cfoutput>
			 </cfif> 
			<cfif vidPos>
			     <cfoutput>xmlns:n="#arguments.videoNameSpace#"</cfoutput>
			 </cfif> 
			 <cfoutput>>#variables.oSiteMapData.getXMLString()#</urlset></cfoutput>
		</cfsavecontent>
		
		<cftry>
			<cfset oXMLSiteData=xmlParse(trim(googleSiteMapXML))>
			<cfcatch>
				<cfthrow message="the data passed to SiteMapData object is invalid xml">
			</cfcatch>
		</cftry>	 
		
		<cfset setSiteMap(oXMLSiteData)>
	</cffunction>
	
	<!--- private /////////--->
</cfcomponent>