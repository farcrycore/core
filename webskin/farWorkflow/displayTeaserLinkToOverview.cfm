<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset referenceTypename = application.coapi.coapiUtilities.findType(objectid="#stobj.referenceID#") />

<cfif len(referenceTypename)>
	<cfset oReferenceObject = createObject("component", application.stcoapi["#referenceTypename#"].packagePath) />
	<cfset stReferenceObject = oReferenceObject.getData(objectid="#stobj.referenceID#") />
	
	<cfoutput><div style="border:1px dotted grey;margin:10px;padding:10px;"></cfoutput>
	<cfoutput>
		<h3><a href="#application.url.webtop#/edittabOverview.cfm?objectid=#stReferenceObject.objectid#">#stReferenceObject.label# (#stobj.title#)</a></h3>
		<p>#stobj.description#</p>
	</cfoutput>
	
	<cfif arrayLen(stobj.aTaskIDs)>
		<cfloop from="1" to="#arrayLen(stobj.aTaskIDs)#" index="i">
			<cfoutput><li></cfoutput>
				<skin:view objectid="#stobj.aTaskIDs[i]#" typename="farTask" template="displayTitle" />
			<cfoutput></li></cfoutput>
		</cfloop>
	</cfif>
	
	<cfoutput></div></cfoutput>

</cfif>

<cfsetting enablecfoutputonly="false" />