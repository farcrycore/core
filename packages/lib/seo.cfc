<cfcomponent displayname="SEO Functions" output="false">

	<!--- seo / metadata methods --->

	<cffunction name="getTitle" returntype="string" output="false">
		<cfargument name="objectid" type="string" required="false" default="">
		<cfargument name="typename" type="string" required="false" default="">
		<cfargument name="stObject" type="struct" required="false" default="#structNew()#">
		<cfargument name="lProperties" type="string" required="false" default="seoTitle,title,label">

		<cfset var stObj = getPreferredObject(argumentCollection=arguments)>
		<cfset var title = getPreferredProperty(stObject=stObj, lProperties=arguments.lProperties)>

		<cfreturn title>
	</cffunction>

	<cffunction name="getDescription" returntype="string" output="false">
		<cfargument name="objectid" type="string" required="false" default="">
		<cfargument name="typename" type="string" required="false" default="">
		<cfargument name="stObject" type="struct" required="false" default="#structNew()#">
		<cfargument name="lProperties" type="string" required="false" default="seoDescription,extendedmetadata,teaser,body">

		<cfset var stObj = getPreferredObject(argumentCollection=arguments)>
		<cfset var description = getPreferredProperty(stObject=stObj, lProperties=arguments.lProperties)>

		<cfif len(description) gt 200>
			<cfset description = left(description, 200) & "...">
		</cfif>

		<cfreturn description>
	</cffunction>

	<cffunction name="getKeywords" returntype="string" output="false">
		<cfargument name="objectid" type="string" required="false" default="">
		<cfargument name="typename" type="string" required="false" default="">
		<cfargument name="stObject" type="struct" required="false" default="#structNew()#">
		<cfargument name="lProperties" type="string" required="false" default="seoKeywords,metaKeywords">

		<cfset var stObj = getPreferredObject(argumentCollection=arguments)>
		<cfset var keywords = getPreferredProperty(stObject=stObj, lProperties=arguments.lProperties)>

		<cfreturn keywords>
	</cffunction>


	<cffunction name="getPreferredObject" returntype="struct" output="false">
		<cfargument name="objectid" type="string" required="false" default="">
		<cfargument name="typename" type="string" required="false" default="">
		<cfargument name="stObject" type="struct" required="false" default="#structNew()#">

		<cfset var stObj = structNew()>

		<!--- get stObj --->
		<cfif NOT structIsEmpty(arguments.stObject)>
			<cfset stObj = arguments.stObject>
		<cfelseif len(arguments.objectid) AND len(arguments.typename)>
			<cfset stObj = application.fapi.getContentObject(typename=arguments.typename, objectid=arguments.objectid)>
		<cfelseif len(arguments.objectid)>
			<cfset stObj = application.fapi.getContentObject(objectid=arguments.objectid)>
		<cfelseif structKeyExists(request, "stObj")>
			<cfset stObj = request.stObj>
		<cfelse>
			<cfthrow message="Missing an objectid, stObject, or request.stObj">
		</cfif>

		<cfreturn stObj>
	</cffunction>

	<cffunction name="getPreferredProperty" returntype="string" output="false">
		<cfargument name="stObject" type="struct" required="true">
		<cfargument name="lProperties" type="string" required="false" default="seoTitle,title,label">
		<cfargument name="stripHTML" type="boolean" required="false" default="true">

		<cfset var value = "">
		<cfset var item = "">

		<cfif NOT structIsEmpty(arguments.stObject)>
			<cfloop list="#arguments.lProperties#" index="item">
				<!--- return the first matching property value --->
				<cfif structKeyExists(arguments.stObject, item) AND len(trim(arguments.stObject[item]))>
					<cfif arguments.stripHTML>
						<cfset value = trim(reReplace(arguments.stObject[item], "<[^>]*>", "", "all"))>
					<cfelse>
						<cfset value = trim(arguments.stObject[item])>
					</cfif>
					<cfif len(value)>
						<cfbreak>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn value>
	</cffunction>


	<!--- canonical methods --->

	<cffunction name="getCanonicalURL" returntype="string" output="false">
		<cfargument name="objectid" type="string" required="false" default="">
		<cfargument name="typename" type="string" required="false" default="">
		<cfargument name="stObject" type="struct" required="false" default="#structNew()#">
		<cfargument name="bUseHostname" type="boolean" required="false" default="false">

		<cfset var canonical = "">
		<cfset var protocol = getCanonicalProtocol()>
		<cfset var domain = getCanonicalDomain(bUseHostname=arguments.bUseHostname)>
		<cfset var objectFU = getCanonicalFU(argumentCollection=arguments)>

		<!--- build canonical, fall back to absolute path when domain name is missing --->
		<cfif len(protocol) AND len(domain) AND len(objectFU)>
			<cfset canonical = protocol & "://" & domain & objectFU>
		<cfelseif len(objectFU)>
			<cfset canonical = objectFU>
		</cfif>

		<cfreturn canonical>
	</cffunction>


	<cffunction name="getCanonicalFU" returntype="string" output="false">
		<cfargument name="objectid" type="string" required="false" default="">
		<cfargument name="typename" type="string" required="false" default="">
		<cfargument name="stObject" type="struct" required="false" default="#structNew()#">

		<cfset var objectFU = "">
		<cfset var currentFU = "">
		<cfset var stNav = "">

		<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />

		<!--- get objectid / typename --->
		<cfif NOT structIsEmpty(arguments.stObject)>
			<cfset arguments.objectid = arguments.stObject.objectid>
			<cfset arguments.typename = arguments.stObject.typename>
		<cfelseif len(arguments.objectid) AND NOT len(arguments.typename) AND structKeyExists(request, "stObj")>
			<cfset arguments.typename = request.stObj.typename>
		<cfelseif structKeyExists(request, "stObj")>
			<cfset arguments.objectid = request.stObj.objectid>
			<cfset arguments.typename = request.stObj.typename>
		</cfif>

		<cfif isValid("uuid", arguments.objectid) AND len(arguments.typename)>

			<!--- check for bUseInTree types --->
			<cfif application.fapi.getContentTypeMetadata(typename=arguments.typename, md="bUseInTree", default=false)>
				<!--- look up the parent nav node --->
				<nj:getNavigation objectId="#arguments.objectid#" r_stobject="stNav" />
			</cfif>

			<cfif isStruct(stNav) and structKeyExists(stNav, "aObjectIDs") AND stNav.aObjectIDs[1] eq arguments.objectid>
				<!--- if the object is the first child in the tree look up the nav node --->
				<cfset objectFU = application.fapi.getLink(typename="dmNavigation", objectid=stNav.objectID)>
			<cfelse>
				<!--- otherwise look up the object itself --->
				<cfset objectFU = application.fapi.getLink(typename=arguments.typename, objectid=arguments.objectid)>

				<!--- match the current friendly URL if this is the request object --->
				<cfif structKeyExists(request, "stObj") AND arguments.objectid eq request.stObj.objectid AND structKeyExists(url, "furl") AND len(url.furl)>
					<cfset currentFU = application.fapi.fixURL(url.furl)>
					<!--- use the current FU if the object FU is just an objectid --->
					<cfif len(objectFU) gt 1 AND isValid("uuid", right(objectFU, len(objectFU)-1))>
						<cfset objectFU = currentFU>
					</cfif>
					<!--- use current FU if stems match (i.e. currentFU is found in objectFU or vice versa) --->
					<cfif len(currentFU) AND (findNoCase(currentFU, objectFU) OR findNoCase(objectFU, currentFU))>
						<cfset objectFU = currentFU>
					</cfif>
				</cfif>

			</cfif>

		</cfif>

		<cfreturn objectFU>
	</cffunction>


	<cffunction name="getCanonicalDomain" returntype="string" output="false">
		<cfargument name="bUseHostname" type="boolean" required="false" default="false">

		<cfset var domain = application.fapi.getConfig("environment", "canonicalDomain", "")>
		<cfif arguments.bUseHostname AND NOT len(domain)>
			<cfset domain = CGI.HTTP_HOST>
		</cfif>
		<cfreturn domain>
	</cffunction>

	<cffunction name="getCanonicalProtocol" returntype="string" output="false">
		<cfset var protocol = application.fapi.getConfig("environment", "canonicalProtocol", "")>
		<cfif NOT len(protocol)>
			<cfif cgi.https eq "off">
				<cfset protocol = "http">
			<cfelse>
				<cfset protocol = "https">
			</cfif>
		</cfif>
		<cfreturn protocol>
	</cffunction>

	<cffunction name="getCanonicalBaseURL" returntype="string" output="false">
		<cfargument name="bUseHostname" type="boolean" required="false" default="true">
		<!--- default to using the current hostname when generating a base URL by itself --->
		<cfset var baseURL = "#getCanonicalProtocol()#://#getCanonicalDomain(bUseHostname=arguments.bUseHostname)#">
		<cfreturn baseURL>
	</cffunction>


</cfcomponent>