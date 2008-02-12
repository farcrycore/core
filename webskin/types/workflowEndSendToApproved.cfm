<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Approve --->
<cfset stWorkflow = createObject("component", application.stcoapi.farWorkflow.packagepath).hasInstance(referenceID="#stobj.objectid#") />

<cfif stWorkflow.bTasksComplete AND stWorkflow.bWorkflowComplete>
	
	<farcry:logevent object="#stobj.objectid#" type="types" event="workflow" notes="workflow completed" />
	
	<cflocation url="#application.url.webtop#/navajo/approve.cfm?objectid=#stobj.objectid#&status=approved" addToken="false" />
</cfif>

<cfsetting enablecfoutputonly="false" />