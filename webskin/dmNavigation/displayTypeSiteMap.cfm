<!--- @@fuAlias: sitemap --->
<cfset oSiteMap=createObject('component', 'farcry.core.packages.googleSiteMap.sitemap').init()>
<cfset stSiteConfig=structNew()>
<cfset stSiteConfig.domainName="#cgi.server_name#">

<cfset xml=oSiteMap.generate(stSiteConfig=stSiteConfig,siteMapType="siteMap", types="dmNavigation")>
<CFHEADER NAME="content-disposition" VALUE="inline; filename=#url.type#.#now()#">
<cfheader name="Content-Type" value="text/xml">
<cfoutput>#xml#</cfoutput>