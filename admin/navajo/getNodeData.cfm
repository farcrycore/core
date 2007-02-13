<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">

<q4:contentobjectgetmultiple bActiveOnly="0" lObjectIds="#url.lObjectIds#" r_stObjects="stObjs">
<!--- Need to delete certain keys - one of these (not sure which) is breaking the javascript on the calling page
 --->
 <cfset filterList = "displayMethod,teaser,body,commentlog,VERSIONID,ATEASERIMAGEIDS,METAKEYWORDS">
<cfloop index="objId" list="#StructKeyList(stObjs)#">
	<cfset obj = stObjs[objId]>
	<cfloop list="#structKeyList(stObjs[objId])#" index="key">
		<cfif listContainsNoCase(filterList,key) AND structKeyExists(stObjs[objID],key)>
			<cfset tmp = structDelete(stObjs[objId],key)>
		</cfif>
	</cfloop>
	<cfif isDefined("obj.aObjectIds") and ArrayLen( obj.aObjectIds )>
		<q4:contentobjectgetmultiple bActiveOnly="0" lObjectIds="#ArrayToList(obj.aObjectIds)#" r_stObjects="stSubObjs">
		<cfloop index="objId" list="#StructKeyList(stSubObjs)#">
			<cfloop list="#structKeyList(stSubObjs[objId])#" index="key">
				<cfif listContainsNoCase(filterList,key) AND structKeyExists(stSubObjs[objID],key)>
					<cfset tmp = structDelete(stSubObjs[objId],key)>
				</cfif>
			</cfloop>
		</cfloop>			
		<cfset temp=obj.aObjectIds>
		<cfset obj.aObjectIds=stSubObjs>
	</cfif>
</cfloop>
<cfdump var="#stObjs#">
<cfwddx action="CFML2JS" input="#stObjs#" toplevelvariable="objectData" output="jscode">
<cfoutput>
#JSStringFormat(jscode)#
<script>
	parent.downloadComplete("#JSStringFormat(jscode)#");
</script>
</cfoutput>
<cfsetting enablecfoutputonly="No">