<cfcomponent displayname="Canonical URL Functions" output="false">

	<cffunction name="getCanonicalURL" returntype="string" output="false">

		<cfset var canonical = "">
		<cfset var objectFU = "">
		<cfset var currentFU = "">
		<cfset var protocol = "">
		<cfset var domain = "">
		<cfset var stNav = "">

		<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />

		<cfif refindnocase("^/index.cfm",cgi.script_name) AND structKeyExists(request, "stObj") and isDefined("request.stObj.objectId")>

			<!--- get the object FU --->
			<nj:getNavigation objectId="#request.stObj.objectId#" r_stobject="stNav" />
			<cfif isStruct(stNav) and structKeyExists(stNav, "objectid") AND len(stNav.objectid)>
				<!--- if the object is in the tree look up the nav node --->
				<cfset objectFU = application.fapi.getLink(typename="dmNavigation", objectid=stNav.objectID)>
			<cfelse>
				<!--- otherwise look up the object itself --->
				<cfset objectFU = application.fapi.getLink(typename=request.stObj.typename, objectid=request.stObj.objectid)>
			</cfif>

			<!--- get the current FU --->
			<cfif structKeyExists(url, "furl") AND len(url.furl)>
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

			<!--- get the production protocol and domain name --->
			<cfset protocol = getCanonicalProtocol()>
			<cfset domain = getCanonicalDomain()>

			<!--- build canonical --->
			<cfif len(protocol) AND len(domain) AND len(objectFU)>
				<cfset canonical = protocol & "://" & domain & objectFU>
			<cfelseif len(objectFU)>
				<cfset canonical = objectFU>
			</cfif>

		</cfif>

		<cfreturn canonical>
	</cffunction>


	<cffunction name="getCanonicalDomain" returntype="string" output="false">
		<cfset var oEnvironment = application.fapi.getContentType(typename="configEnvironment")>
		<cfset var domain = oEnvironment.getCanonicalDomain()>

		<cfreturn domain>
	</cffunction>

	<cffunction name="getCanonicalProtocol" returntype="string" output="false">
		<cfset var oEnvironment = application.fapi.getContentType(typename="configEnvironment")>
		<cfset var protocol = oEnvironment.getCanonicalProtocol()>

		<cfreturn protocol>
	</cffunction>

</cfcomponent>