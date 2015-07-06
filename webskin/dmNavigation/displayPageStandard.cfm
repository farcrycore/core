<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Display first child --->

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4" />
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<cfif not structkeyexists(stObj,"navType") or not len(stObj.navType)>
	<cfif len(stObj.externalLink) gt 0>
		<cfset stObj.navType = "externalLink" />
	<cfelseif structKeyExists(stObj,"aObjectIds") AND arrayLen(stObj.aObjectIds)>
		<cfset stObj.navType = "aObjectIds" />
	</cfif>
</cfif>

<cfswitch expression="#stObj.navType#">
	<cfcase value="externalLink"><!--- check for sim link --->
		<cftrace var="attributes.objectid" text="Setting navid to attributes.objectid as external link is specified" />
		<cfset request.navid = stObj.objectid>
		
		<!--- It is often useful to know the navid of the externalLink for use on the page that is being rendered --->
		<cfset request.externalLinkNavid = stObj.objectid>
		
		<nj:display objectid="#stObj.externalLink#" />
		<cfsetting enablecfoutputonly="false" />
		<cfexit method="exittemplate" />

	</cfcase>
	
	<cfcase value="internalRedirectID"><!--- This is a fallback - usually these will be handled in the link --->
		<skin:location objectid="#stObj.internalRedirectID#" statusCode="302" />
	</cfcase>
	
	<cfcase value="externalRedirectURL"><!--- This is a fallback - usually these will be handled in the link --->
		<cflocation url="#stObj.externalRedirectURL#" statusCode="301" addtoken="false" />
	</cfcase>
	
	<cfcase value="aObjectIds">
		<cfloop index="idIndex" from="1" to="#arrayLen(stObj.aObjectIds)#">
			
			<cfset stObjTemp = application.fapi.getContentObject(objectid="#stObj.aObjectIds[idIndex]#") />
			
				
			<!--- request.mode.lValidStatus is typically approved, or draft, pending, approved in SHOWDRAFT mode --->
			<cfif StructKeyExists(stObjTemp,"status") AND ListContains(request.mode.lValidStatus, stObjTemp.status)>
					
				<!--- Otherwise just show this one --->
				<nj:display objectid="#stObjTemp.objectid#" typename="#stObjTemp.typename#" />
				<cfsetting enablecfoutputonly="false" />
				<cfexit method="exittemplate">
				
			<cfelseif stObjTemp.typename neq "dmCSS">
			
				<!--- no status so just show object --->
				<!--- set the navigation point for the child obj --->
				<cfset request.navid = stObj.objectID>		
				
				<!--- reset stObj to appropriate object to be displayed --->
				<nj:display objectid="#stObjTemp.objectid#" typename="#stObjTemp.typename#" />
				<cfsetting enablecfoutputonly="false" />
				<cfexit method="exittemplate" />
			
			</cfif>
			
		</cfloop>
	</cfcase>
</cfswitch>

<!--- If we get to this point, this object doesn't have any children --->
<cfif NOT isDefined("request.navid")>
	<cfset request.navid = stobj.objectid />
</cfif>

<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="#url.bodyView#" />


<cfsetting enablecfoutputonly="false" />