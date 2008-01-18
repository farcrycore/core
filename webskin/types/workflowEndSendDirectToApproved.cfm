<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">

<cfset stWorkflow = createObject("component", application.stcoapi.farWorkflow.packagepath).hasInstance(referenceID="#stobj.objectid#") />


<cfif stWorkflow.bTasksComplete>
	<!--- CHANGE THE OBJECTS STATUS TO APPROVED --->
	<cfset url.objectid = stobj.objectid />
	<cfset url.status = "approved" />
	<cfset form.submit = "submit" />
	<cfset form.commentlog = "Workflow Complete. Sent to Approved" />

	<nj:objectStatus>

	<cfabort>
</cfif>



<cfsetting enablecfoutputonly="false" />