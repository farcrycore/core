<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Delete Object --->

<cfset stWorkflow = createObject("component", application.stcoapi.farWorkflow.packagepath).hasInstance(referenceID="#stobj.objectid#") />

<cfif stWorkflow.bTasksComplete AND stWorkflow.bWorkflowComplete>
	
	<!--- Delete the approved object as well if it exists --->
	<cfif structKeyExists(stobj, "versionID") and len(stobj.versionID)>
		<cfset stResult = delete(objectid="#stobj.versionID#") />
	</cfif>
	
	<cfset stResult = delete(objectid="#stobj.objectid#") />
	
	
	
	<!--- SET SOME SESSION VARIABLE TO MESSAGE THAT THE OBJECT WAS DELETED. --->
	<cfoutput><p>#stobj.label# was deleted.</p></cfoutput>
	<cfabort>
</cfif>

<cfsetting enablecfoutputonly="false" />