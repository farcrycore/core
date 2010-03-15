<cfcomponent name="indexSite" extends="site" displayname="index site" hint="I am an a site index that points to other site maps">
	
	<cffunction name="createSiteMap" access="public" returntype="void" description="create an xml object out of SiteMapData">
		<cfargument name="siteMapNameSpace" required="false" default="http://www.sitemaps.org/schemas/sitemap/0.9">
		
		<cfset var oXMLSiteData="">
		<cfset var googleSiteMapXML="">

		<!--- build the site map xml String --->
		<cfsavecontent variable="googleSiteMapXML">
			<cfoutput>
				<?xml version="1.0" encoding="UTF-8"?>
				<sitemapindex xmlns="#arguments.siteMapNameSpace#"
			</cfoutput>
			 <cfoutput>>#variables.oSiteMapData.getXMLString()#</sitemapindex></cfoutput>
		</cfsavecontent>
		
		<cftry>
			<cfset oXMLSiteData=xmlParse(trim(googleSiteMapXML))>
			<cfcatch>
				<cfthrow message="the data passed to SiteMapData object is invalid xml">
			</cfcatch>
		</cftry>	 
		
		<cfset setSiteMap(oXMLSiteData)>
	</cffunction>
	
</cfcomponent>