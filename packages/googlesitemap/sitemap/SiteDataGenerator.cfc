<cfcomponent name="SiteDataGenerator" displayname="SiteDataGenerator" hint="I generate site map xml strings">
	<cfset variables.SiteConfig="">
	<cfset variables.newsTypes="dmNews:publishDate">
	<!--- switch these on and off to generate individual types with set method --->
	<cfset variables.bGenerateNews=0> 
	<cfset variables.bGenerateNav=0>
	<cfset variables.bGenerateVideos=0>
	<cfset variables.types="">
	
	
	<!--- public /////////--->
	<cffunction name="init" returntype="farcry.core.packages.googleSiteMap.sitemap.SiteDataGenerator" access="public">
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setSiteConfig" access="public" description="sets the site config">
		<cfargument name="SiteConfig" type="struct" required="true">
	
		<cfset variables.SiteConfig=arguments.SiteConfig>
		<!--- set default values --->
		<cfif not structKeyExists(variables.SiteConfig, "startPoint")>
			<cfset variables.SiteConfig.startPoint=application.fapi.getNavID("root")>
		</cfif>
		<cfif not structKeyExists(variables.SiteConfig, "depth")>
			<cfset variables.SiteConfig.depth=5>
		</cfif>
	</cffunction>
	
	<cffunction name="getSiteConfig" access="public" description="gets the site config" returntype="farcry.plugins.googleSiteMap.packages.custom.SiteConfig">
		<cfreturn variables.siteConfig>
	</cffunction>
	
	<cffunction name="setNewsTypes" access="public" description="sets the news types">
		<cfargument name="newsTypes" type="string" required="true">
		
		<cfset variables.newsTypes=arguments.newsTypes>
		
	</cffunction>
	
	<cffunction name="setTypes" access="public" description="sets the types">
		<cfargument name="types" type="string" required="true">
		
		<cfset variables.types=arguments.types>
		
	</cffunction>
	
	<cffunction name="setbGenerateNews" access="public" description="sets the switch to generate news">
		<cfargument name="bGenerateNews" type="boolean" required="true">
		
		<cfset variables.bGenerateNews=arguments.bGenerateNews>
	</cffunction>
	
	<cffunction name="getbGenerateNews" access="public" description="gets the swith to generate news" returntype="boolen">
		<cfreturn variables.bGenerateNews>
	</cffunction>
	
	<cffunction name="setbGenerateNav" access="public" description="sets the switch to generate navs">
		<cfargument name="bGenerateNav" type="boolean" required="true">
		
		<cfset variables.bGenerateNav=arguments.bGenerateNav>
	</cffunction>
	
	
	<cffunction name="getbGenerateNav" access="public" description="gets the switch to generate navs" returntype="boolen">
		<cfreturn variables.bGenerateNav>
	</cffunction>
	
	<cffunction name="getNewsTypes" access="public" description="gets new types" returntype="string">
		<cfreturn variables.newsTypes>
	</cffunction>
	
	<cffunction name="generateSiteData" access="public" description="creates xml text for a site map">
		
		<cfset var qNavigationData="">
		<cfset var qNewsData="">
		<cfset var qTypeData="">
		<cfset var videoXMLData="">
		<cfset var navXMLData="">
		<cfset var newsXMLData="">
		<cfset var typeXMLData="">
		<cfset var stMeta="">
		
		<cfif variables.bGenerateNews>
			<cfloop list ="#variables.newsTypes#"  index="newsType" >
				<!--- check to see if there is getNewsSiteMapData method in the component --->
				<cfset oObj=application.fapi.getContentType(listFirst(newsType,":"))>
				<cfset stMeta=getMetaData(oObj)>
				<cfif methodExists(stMeta,'getNewsSiteMapData')>
					<cfset qNewsData=oObj.getNewsSiteMapData()>
				<cfelse>
					<cfset qNewsData=getNewsData(listFirst(newsType,":"), listLast(newsType,":"))>
				</cfif>
				<cfset newsXMLData="#newsXMLData##generateNewsXMLData(qNewsData)#">
			</cfloop>
		</cfif>
		<cfif variables.bGenerateVideos>
			<cfset qVideoData=getVideoData()>
			<cfset videoXMLData=generateVideoXMLData(qVideoData)>
		</cfif>
		
		<cfloop list="#variables.types#" index="type">
			<cfif type eq "dmNavigation" or variables.bGenerateNav>
				<!--- check to see if there is a getSiteMapData method in the component --->
				<cfset oObj=application.fapi.getContentType(type)>
				<cfset stMeta=getMetaData(oObj)>
				
				<cfif methodExists(stMeta,'getSiteMapData')>
					<cfset qNavigationData=oObj.getSiteMapData()>
				<cfelse>
					<cfset qNavigationData=getNavigationData()>
				</cfif>
				<!--- check to see if there is a generateSiteMapXML method in the component --->
				<cfif methodExists(stMeta,'generateSiteMapXML')>
					<cfset navXMLData=oObj.generateSiteMapXML(qNavigationData)>
				<cfelse>
					<cfset navXMLData=generateNavXMLData(qNavigationData)>
				</cfif>
			</cfif>
			
			<cfif type neq "dmNavigation">
				<!--- check to see if there is a getSiteData method in the component --->
				<cfset oObj=application.fapi.getContentType(type)>
				<cfset stMeta=getMetaData(oObj)>
				
				<cfif methodExists(stMeta,'getSiteMapData')>
					<cfset qTypeData=oObj.getSiteMapData()>
				<cfelse>
					<cfset qTypeData=getTypeData(type)>
				</cfif>
				<!--- check to see if there is a generateSiteMapXML method in the component --->
				
				<cfif methodExists(stMeta,'generateSiteMapXML')>
					<cfset typeXMLData="#typeXMLData##oObj.generateSiteMapXML(qTypeData)#">
				<cfelse>
					<cfset typeXMLData="#typeXMLData##generateTypeXMLData(qTypeData)#">
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn "#navXMLData##newsXMLData##videoXMLData##typeXMLData#">
	</cffunction>
	
	<cffunction name="getNavigationData" returntype="query" access="public" hint="a query to get all naviagtion nodes">
		
		<cfset var navFilter=arrayNew(1)>
		<cfset var qNavUnsorted="">

		<!--- g.s this code is copied from an existing site map generator please see http://groups.google.com/group/farcry-dev/browse_thread/thread/2d8e81c4f3b65620--->
		<cfset navfilter[1]="status IN ('approved')">
		<cfset qNavUnsorted = application.factory.oTree.getDescendants(objectid=variables.SiteConfig.startPoint, depth=variables.SiteConfig.depth, bIncludeSelf="0", afilter=navFilter, lcolumns="externallink,datetimelastupdated")>
        <!--- VE: sort query through a requery; externallink may not be 
			filled because we would get double URL's in the sitemap this is 
			prohibited by google.---> 

        <cfquery name="qNavSorted" dbtype="query"> 
			SELECT objectid,nlevel,nleft,datetimelastupdated,externallink 
            FROM qNavUnsorted 
            WHERE externallink = '' OR externallink is NULL
            ORDER BY nLeft,objectName ASC 
        </cfquery>
		
		<cfreturn qNavSorted>
	</cffunction>
	
	<cffunction name="generateNavXMLData" returntype="string" hint="generates xml string" access="public">
		<cfargument name="qNavData" required="true" type="query">
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		<!--- g.s this code was copied directly from an existing site map generator http://groups.google.com/group/farcry-dev/browse_thread/thread/2d8e81c4f3b65620--->
		<cfsavecontent variable="xmlString">
			<cfloop query="arguments.qNavData">
				<cfsavecontent variable="strUrl">
					<skin:buildLink includedomain="true" domain="#SiteConfig.domainName#" urlOnly="true" objectid="#qNavData.objectid#" externallink="#qNavData.externallink#" />
				</cfsavecontent> 
				<!--- avoiding white space here hence the 1 line of code --->
				<cfoutput> 
		        	<url><loc>#XmlFormat(strUrl)#</loc><priority><cfif qNavData.nlevel LTE 2>1.0<cfelseif qNavData.nlevel LTE 3>0.9<cfelse>#numberformat(log10 (qNavData.nlevel),'0._')#</cfif></priority> <lastmod>#DateFormat(qNavData.datetimelastupdated,'yyyy-mm-dd')#</lastmod> <changefreq><cfif qNavData.nlevel LTE 2>daily<cfelse>weekly</cfif></changefreq></url>
				</cfoutput>
			</cfloop>    
		</cfsavecontent>
		
		<cfreturn xmlString>
	</cffunction>
	
	<cffunction name="generateTypeXMLData" returntype="string" hint="generates xml string" access="public">
		<cfargument name="qTypeData" required="true" type="query">
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

		<cfsavecontent variable="xmlString">
			<cfloop query="arguments.qTypeData">
				<cfsavecontent variable="strUrl">
					<skin:buildLink includedomain="true" domain="#SiteConfig.domainName#" urlOnly="true" objectid="#qTypeData.objectid#" />
				</cfsavecontent> 
				<!--- avoiding white space here hence the 1 line of code --->
				<cfoutput> 
		        	<url><loc>#XmlFormat(strUrl)#</loc><priority>0.9</priority> <lastmod>#DateFormat(qTypeData.datetimelastupdated,'yyyy-mm-dd')#</lastmod> <changefreq>daily</changefreq></url>
				</cfoutput>
			</cfloop>    
		</cfsavecontent>
		
		<cfreturn xmlString>
	</cffunction>
	
	<cffunction name="getNewsData" access="public" description="generates news xml string" returntype="query">
		<cfargument name="newsType" required="true">
		<cfargument name="publishFieldName" required="false" default="#application.dsn#">
		<cfargument name="dsn" required="false" default="#application.dsn#">
		
		<cfquery name="qNews" datasource="#arguments.dsn#">
			SELECT * FROM #arguments.newsType#
			WHERE status='approved'
			AND #arguments.publishFieldName# > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#dateAdd('d',-2,now())#" />
			AND #arguments.publishFieldName# < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#" />
			ORDER BY #arguments.publishFieldName# DESC
		</cfquery>
		
		<cfreturn qNews>
	</cffunction>
	
	<cffunction name="getTypeData" access="public" description="creates a site map for diffent types" returntype="query">
		<cfargument name="type" required="true">
		<cfargument name="bCheckForPublishDate" required="false" default="true">
		<cfargument name="dsn" required="false" default="#application.dsn#">
		
		<cfset var qTypeData="">
		<cftry>
			<cfquery name="qTypeData" datasource="#arguments.dsn#">
				SELECT * FROM #arguments.type#
				WHERE status='approved'
				<cfif arguments.bCheckForPublishDate>
					AND publishDate < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#" />
					AND (expiryDate > <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#" /> or expiryDate is NULL)
				</cfif>
			</cfquery>
			<cfcatch>
				<cfthrow message="#cfcatch.Message#">
			</cfcatch>
		</cftry>
		<cfreturn qTypeData>
	</cffunction>

	<cffunction name="generateNewsXMLData" access="public" description="generates news xml data">
		<cfargument name="qNewsData" required="true" type="query">
		<cfargument name="language" required="false" type="string" default="en">
		
		<cfset var xmlString="">
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
			
		<cfsavecontent variable="xmlString">
			<cfloop query="arguments.qNewsData">
				<cfsavecontent variable="strUrl">
					<skin:buildLink includedomain="true" domain="#SiteConfig.domainName#" urlOnly="true" objectid="#qNewsData.objectid#" />
				</cfsavecontent> 
				<!--- avoiding white space here hence the 1 line of code --->
				<cfoutput> 
		        	<url><loc>#XmlFormat(strUrl)#</loc><n:news><n:publication><n:name>#XmlFormat(variables.SiteConfig.newsPublication)#</n:name><n:language>#XmlFormat(arguments.language)#</n:language></n:publication><cfif isdefined("qNewsData.access")><n:access>#XmlFormat(qNewsData.access)#</n:access></cfif><cfif isdefined("qNewsData.genres")><n:genres>#XmlFormat(qNewsData.genres)#</n:genres></cfif><n:publication_date>#dateFormat(arguments.qNewsData.publishDate,"yyyy-mm-dd")#</n:publication_date><n:title>#XmlFormat(qNewsData.title)#</n:title><cfif isDefined("qNewsData.metaKeyWords")><n:keywords>#XmlFormat(qNewsData.metaKeyWords)#</n:keywords></cfif><cfif isDefined("qNewsData.stock_tickers")><n:stock_tickers>#XmlFormat(qNewsData.stock_tickers)#</n:stock_tickers></cfif></n:news></url>
				</cfoutput>
			</cfloop>    
		</cfsavecontent>
		
		<cfreturn xmlString>
	</cffunction>
	
	<cffunction name="getVideoData" access="public" description="gets video from the database" returntype="query">
		<!--- THIS STILL NEEDS TO bE DEVELOPED --->
		<cfreturn queryNew('blah')>
	</cffunction>
	
	<cffunction name="generateVideoXMLData" access="public" description="generates video xml data" returntype="string">
		<cfargument name="qVideoData" type="query">
		<!--- THIS STILL NEEDS TO bE DEVELOPED --->
		<cfreturn "">
	</cffunction>
	
	<!--- private /////////--->
	
	<cffunction name="methodExists" access="private" description="checks to see if a method exists in a component" returntype="boolean">
		<cfargument name="oObj" required="true" >
		<cfargument name="methodName">
		
		<cfif structKeyExists(arguments.oObj,'functions')>
			<cfloop from="1" to="#arraylen(arguments.oObj.functions)#" index="i">	
				<cfif arguments.oObj.functions[i].name eq arguments.methodName>
					<cfreturn true>
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn false>
	</cffunction>
	
</cfcomponent>