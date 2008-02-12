<cfcomponent name="facade" displayname="workflow facade" hint="Used by the workflow for the ajax callbacks" output="false" > 

<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" >

<cffunction name="renderWorkflowTasks" access="remote" output="true" returntype="void">
 	<cfargument name="workflowID" required="yes" type="uuid" hint="ObjectID of the workflow being created.">
 	<cfargument name="workflowDefID" required="yes" type="uuid" hint="ObjectID of the workflow definition to select tasks from.">

	<cfset var oWorkflow = createObject("component", application.stcoapi.farWorkflow.packagePath) />
	<cfset var oWorkflowDef = createObject("component", application.stcoapi.farWorkflowDef.packagePath) />
	<cfset var stProperties = structNew() />
	<cfset var stWorkflowDef = oWorkflowDef.getData(objectid="#arguments.workflowDefID#") />
	<cfset var stResult = structNew() />
	<cfset var html = structNew() />
	
	<cfset request.mode.ajax = true />
	
	<cfset stProperties.objectid = arguments.workflowID />
	<cfset stProperties.workflowDefID = arguments.workflowDefID />
	<cfset stResult = oWorkflow.setData(stProperties="#stProperties#") />
	
	<cfset html = oWorkflow.getView(objectid="#arguments.workflowID#", typename="farWorkflow", template="editTasks") />
	<cfoutput>#HTML#</cfoutput>
	

</cffunction>

<cffunction name="renderWorkflowDefWebskins" access="remote" output="true" returntype="void">
 	<cfargument name="workflowDefID" required="yes" type="uuid" hint="ObjectID of the workflow Definition being created.">
 	<cfargument name="lTypenames" required="yes" type="string" hint="list of typenames that can use this workflow definition">

	<cfset var oWorkflowDef = createObject("component", application.stcoapi.farWorkflowDef.packagePath) />
	<cfset var stProperties = structNew() />
	<cfset var stWorkflowDef = oWorkflowDef.getData(objectid="#arguments.workflowDefID#") />
	<cfset var stResult = structNew() />
	<cfset var html = structNew() />
	
	<cfset request.mode.ajax = true />
	
	<cfset stProperties.objectid = arguments.workflowDefID />
	<cfset stProperties.lTypenames = arguments.lTypenames />
	<cfset stResult = oWorkflowDef.setData(stProperties="#stProperties#") />
	
	<cfset html = oWorkflowDef.getView(objectid="#arguments.workflowDefID#", typename="farWorkflowDef", template="editWebskins") />
	<cfoutput>#HTML#</cfoutput>
	

</cffunction>

</cfcomponent> 

