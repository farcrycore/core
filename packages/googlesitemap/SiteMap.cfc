<cfcomponent name="SiteMap" displayname="Site" hint="I am site map and i create site maps for a site">
	
	<cfset variables.aSites=arrayNew(1)>
	<cfset variables.oIndexSite="">
	
	<!--- public /////////--->
	<cffunction name="init" returntype="farcry.core.packages.googlesitemap.SiteMap" access="public">
		<cfreturn this>
	</cffunction>

	<cffunction name="addSite" access="public" description="adds a site to the site map">
		<cfargument name="site" type="farcry.core.packages.googlesitemap.sitemap.Site">
		
		<cfset arrayAppend(variables.aSites,arguments.site)>
	</cffunction>
	
	<cffunction name="getSites" access="public" description="returns all the sites in this sitemap" returntype="array">
		<cfreturn variables.aSites>
	</cffunction>
	
	<cffunction name="createSiteMaps" access="public" returntype="void" description="creates site maps for all sites that have been added">
		<cfloop from="1" to="#arraylen(variables.aSites)#" index="i">
			<cfset variables.aSites[i].createSiteMap()>
		</cfloop>		
	</cffunction>
	
	<cffunction name="getSiteMaps" access="public" returntype="array" description="gets the site maps for all sites and returns them in an array">
		<cfset var aSiteMaps=arraynew(1)>
		
		<cfloop from="1" to="#arraylen(variables.aSites)#" index="i">
			<cfset arrayAppend(aSiteMaps, variables.aSites[i].getSiteMap())>
		</cfloop>
		
		<cfreturn aSiteMaps>
	</cffunction>
	
	<cffunction name="setIndexSite" access="public" returntype="void" hint="sets the index site map">
		<cfargument name="oSite" required="true" type="farcry.core.packages.googlesitemap.sitemap.Site">
		
		<cfset variables.oIndexSite=arguments.oSite>
	</cffunction>
	
	<cffunction name="getIndexSite" returntype="farcry.core.packages.googlesitemap.sitemap.Site" access="public" description="returns xml object created by createSiteMap">
		<cfreturn variables.oIndexSite>
	</cffunction>
	
	<cffunction name="outPutSiteMaps" access="public" description="gets all the site maps and writes them in files in the root directory">
		<cfargument name="aSites" required="false" default="#getSites()#" type="array">
		<cfargument name="siteMapFileName" required="false" default="siteMap" type="string">
		<cfargument name="siteMapsDirectoryName" required="false" default="#arguments.siteMapFileName#" type="string">
		
		<!--- create an Index file if there is more than 1 site --->
		<cfset buildIndexSite(aSites=arguments.aSites,siteMapsDirectoryName=arguments.siteMapsDirectoryName)>
		<cfset outputSites(arguments.aSites, arguments.siteMapFileName, arguments.siteMapsDirectoryName)>
	</cffunction>
	
	<cffunction name="buildIndexSite" access="public" description="create an index xml string for the site map index file" returntype="void">
		<cfargument name="aSites" required="false" default="#getSites()#" type="array">
		<cfargument name="siteMapsDirectoryName" required="false" default="sitemap" type="string">
		<cfargument name="indexFileXMLNameSpace" required="false" default="http://www.sitemaps.org/schemas/sitemap/0.9" type="string">
		<cfargument name="lastmod" required="false" default="#dateformat(now(),'yyyy-mm-mm')#" type="string">
		<cfargument name="changefreq" required="false" default="monthly" type="string">
		<cfargument name="servername" required="false" default="#cgi.server_name#" type="string">
	
		<cfset var oSiteMapData=createObject("component", "farcry.core.packages.googlesitemap.sitemap.SiteMapData").init()>
		<cfset var oSiteIndex=createObject("component", "farcry.core.packages.googlesitemap.sitemap.SiteIndex").init()>
		<cfset var indexXmlString="">
		
		<cfsavecontent variable="indexXmlString">
			<cfloop from="1" to="#arraylen(arguments.aSites)#" index="i">
				<cfset siteName=arguments.aSites[i].getSiteName()>
				<cfoutput>
					 <sitemap>
		      			<loc>#application.fc.lib.esapi.encodeForURL("http://#trim(arguments.servername)#/#arguments.siteMapsDirectoryName#/#siteName#.xml")#</loc>
		      			<lastmod>#arguments.lastmod#</lastmod>
		   			</sitemap>
				</cfoutput>
			</cfloop>
		</cfsavecontent>
		
		<cfset oSiteMapData.setXMLString(indexXmlString)>
		<cfset oSiteIndex.setSiteMapData(oSiteMapData)>
		<cfset oSiteIndex.createSiteMap()>
		<cfset setIndexSite(oSiteIndex)>
	</cffunction>
	
	<cffunction name="outputSites" access="public" description="writes the site maps to disc">
		<cfargument name="aSites" required="false" default="#getSites()#" type="array">
		<cfargument name="siteMapFileName" required="false" default="siteMap" type="string">
		<cfargument name="siteMapsDirectoryName" required="false" default="#arguments.siteMapFileName#" type="string">
		
		<cfset cleanUpExistingDir(arguments.siteMapsDirectoryName)>
		<cfif isObject(variables.oIndexSite)>
			<!--- create the index site file --->
			<cfset outputSite(oSite=variables.oIndexSite,filePath=createFilePath(arguments.siteMapFileName))>
			<!--- output all other sites in sub directory and call the file by the site Name--->
			<cfloop from="1" to="#arraylen(arguments.aSites)#" index="i">
				<cfset outputSite(variables.aSites[i], createFilePath(arguments.aSites[i].getSiteName(),arguments.siteMapsDirectoryName))>
			</cfloop>
		</cfif>
		<cfif arraylen(arguments.aSites) eq 1>
			<!--- there is only one site so dont add sub directory  --->
			<cfset outputSite(arguments.aSites[1], createFilePath(arguments.siteMapFileName))>
		</cfif>
	</cffunction>
	
	
	<cffunction name="outputSite" access="public" description="out puts a site as an xml file to the hard drive">
		<cfargument name="oSite" required="true" type="farcry.core.packages.googlesitemap.sitemap.Site">
		<cfargument name="filePath" required="true" type="string">

		<cffile action="Write" file="#arguments.filePath#" output="#toString(arguments.oSite.getSiteMap())#" mode="664">  
	</cffunction>
	
	
	<cffunction name="generate">
		<cfargument name="stSiteConfig" required="true" default="">
		<cfargument name="siteMapType" required="false" default="siteMap" hint="sitemap or newsSiteMap">
		<cfargument name="types" required="false" default="siteMap" hint="sitemap or newsSiteMap">
		<cfargument name="newstypes" required="false" default="dmNews:publishDate" hint="list of news types in with name of field for publish date">
		<cfargument name="bIncludeNavigation" required="false" default="false">
		
		<!--- first add into sitemap index --->					
		<cfset var oSite=createObject('component', 'farcry.core.packages.googlesitemap.sitemap.Site').init()>
		<cfset var oSiteMapData=createObject('component', 'farcry.core.packages.googlesitemap.sitemap.SiteMapData').init()>
		<!--- now generate xmlData for the site --->
		<cfset var DataGenerator=createObject('component', 'farcry.core.packages.googlesitemap.sitemap.SiteDataGenerator').init()>
		
		
		<cfswitch expression="#arguments.siteMapType#">
			<cfcase value="siteMap">
				<!--- set a navigation sitemap --->
				<cfset DataGenerator.setSiteConfig(arguments.stSiteConfig)>
				<cfif arguments.bIncludeNavigation>
					<cfset DataGenerator.setbGenerateNav(true)>
				</cfif>
				<cfif len(arguments.types)>
					<cfset DataGenerator.setTypes(arguments.types)>
				</cfif>
				<cfset xmlData=DataGenerator.generateSiteData()>
			</cfcase>
			<cfcase value="newsSiteMap">
				<cfset DataGenerator.setSiteConfig(arguments.stSiteConfig)>
				<cfset DataGenerator.setbGenerateNews(true)>
				<cfset DataGenerator.setNewsTypes(arguments.newstypes)>
				<cfset xmlData=DataGenerator.generateSiteData()>	
			</cfcase>
			<!--- TODO: set up for video --->
		</cfswitch>
		
		<cfset oSiteMapData.setXMLString(xmlData)>
		<cfset oSite.setSiteMapData(oSiteMapData)>
		<cfset oSite.createSiteMap()>
		
		<cfreturn toString(oSite.getSiteMap())>
	</cffunction>
	
	<cffunction name="generateSiteMaps" access="public" hint="generates site maps from googleSiteMapSites type" returntype="void">
		<cfargument name="siteMapFileName" required="false" default="sitemap">
		<cfargument name="newsTypes" required="false" default="">
		
		<cfset var SiteConfig=application.fapi.getContentType('googleSiteMapSite')>
		<!--- first get all of the sites --->
		<cfset var qSites=getGoogleSiteMapSite()>
		
		<!--- here we treat googleSiteMapSite as configuration items really --->
		<cfloop query="qSites">
			<cfset stSiteConfig=structNew()>
			<cfset stSiteConfig=SiteConfig.getData(qSites.objectid)>
			
			<cfset oSite=createObject('component', 'farcry.core.packages.googlesitemap.sitemap.Site').init(stSiteConfig.domainName,stSiteConfig.siteName)>
			<!--- now generate xmlData for the site --->
			<cfset DataGenerator=createObject('component', 'farcry.core.packages.googlesitemap.sitemap.SiteDataGenerator').init()>
			<cfset DataGenerator.setSiteConfig(stSiteConfig)>
			<!--- set more news types if nessesary --->
			<cfif len(arguments.newsTypes)>
				<cfset DataGenerator.setNewsTypes(arguments.newsTypes)>
			</cfif>
			<cfset xmlData=DataGenerator.generateSiteData()>
			<!--- add it to the site mapData object --->
			<cfset oSiteMapData=createObject('component', 'farcry.core.packages.googlesitemap.sitemap.SiteMapData').init()>
			<cfset oSiteMapData.setXMLString(xmlData)>
			<!--- addit to the site --->
			<cfset oSite.setSiteMapData(oSiteMapData)>
			<!--- now add the site to the site map --->
			<cfset this.addSite(oSite)>	
		</cfloop>

		<!--- we are all set up so lets create the sites and generate the sites --->
		<cfset this.createSiteMaps()>
		
		<cfset this.outputSiteMaps(siteMapFileName="#arguments.siteMapFileName#")>

	</cffunction>
	
	<!---private /////////--->
	
	<cffunction name="createFilePath" access="private" description="create a file path to the root of the website">
		<cfargument name="siteMapFileName" required="false" default="siteMap" type="string">
		<cfargument name="siteMapsDirectoryName" required="false" default="" type="string">
		
		<cfset var filePath="">
		<cfset var dirPath="">
			
		<cfif len(siteMapsDirectoryName)>
			<cfset dirPath="#ExpandPath('/')##arguments.siteMapsDirectoryName#">
			<!--- create the sub directory if it doesnt exist --->
			
			<cfif not directoryExists(dirPath)>
				<cfdirectory action="create" directory="#dirPath#">
			</cfif>
			<cfset filePath="#dirPath#/#arguments.siteMapFileName#.xml">
		<cfelse>
			<cfset filePath = "#ExpandPath('/')##arguments.siteMapFileName#.xml">
		</cfif>
		
		<cfreturn filePath>
	</cffunction>	
	
	<cffunction name="cleanUpExistingDir" description="removes old sub folder with site maps if it exists">
		<cfargument name="siteMapsDirectoryName" required="true" type="string">
		
		<cfif len(arguments.siteMapsDirectoryName)>
			<cfset dirPath = "#ExpandPath('/')##arguments.siteMapsDirectoryName#">
			<cfif directoryExists(dirPath)>
				<cfdirectory action="delete" directory="#dirPath#" recurse="true">
			</cfif> 		
		</cfif>
	</cffunction>
	
	<cffunction name="getGoogleSiteMapSite" access="private" description="gets all current google site map sites">
		<cfset var qSites="">
		
		<cfquery name="qSites" datasource="#application.dsn#">
			SELECT objectid FROM
			googleSiteMapSite
		</cfquery>
		
		<cfreturn qSites>
	</cffunction>
	
	
	
</cfcomponent>