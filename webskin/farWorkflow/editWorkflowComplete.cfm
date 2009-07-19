<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<cfset oTask = createObject("component", application.stcoapi.farTask.packagepath) />
<cfset oWorkflow = createObject("component", application.stcoapi.farWorkflow.packagepath) />


<ft:processForm action="action">
	<cfif structKeyExists(form, "selectedObjectID") and len(form.selectedObjectID)>
		<cfoutput>GO EDIT</cfoutput>
		<cfset stTask = oTask.getData(objectID="#form.selectedObjectID#") />
		
		<cfquery datasource="#application.dsn#" name="qWorkflow">
		SELECT * FROM farWorkflow_aTaskIDs
		WHERE data = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stTask.objectid#">
		</cfquery>
		
		<cfif qWorkflow.recordcount>
			<cfset stWorkflow = oWorkflow.getData(objectid="#qWorkflow.parentID#") />
			
			<cflocation url="#application.url.webtop#/conjuror/invocation.cfm?objectid=#stWorkflow.referenceID#&method=#stTask.taskWebskin#">
		</cfif>
		

		
	</cfif>
</ft:processForm>

<ft:processForm action="complete" url="refresh">
	<cfif structKeyExists(form, "selectedObjectID") and len(form.selectedObjectID)>
		
		<cfset stPropertes = structNew() />
		<cfset stProperties.objectid = form.selectedObjectid />
		<cfset stProperties.bWorkflowComplete = 1 />
		<cfset stResult = oTask.setData(stProperties="#stProperties#") />
	</cfif>
</ft:processForm>

<ft:processForm action="reopen" url="refresh">
	<cfif structKeyExists(form, "selectedObjectID") and len(form.selectedObjectID)>
		
		<cfset stPropertes = structNew() />
		<cfset stProperties.objectid = form.selectedObjectid />
		<cfset stProperties.bComplete = 0 />
		<cfset stResult = oTask.setData(stProperties="#stProperties#") />
	</cfif>
</ft:processForm>

<ft:processForm action="Complete Workflow">
		
	<cfset stResult = onEnd(objectid="#stobj.objectid#") />	
	
</ft:processForm>


<ft:processForm action="Decline Workflow">
	
	<cfset stResult = onStart(objectid="#stobj.objectid#") />	
	
</ft:processForm>



<ft:form>
	
<cfset bWorkflowTasksComplete = true />
		
<cfoutput><table></cfoutput>
<cfloop list="#arrayToList(stobj.aTaskIDs)#" index="i">

	<cfset stTask = oTask.getData(objectID="#i#") />
	
	<cfif not stTask.bComplete>
		<cfset bWorkflowTasksComplete = false />
	</cfif>

	<cfoutput>
	<tr>
		<td>#stTask.title#</td> 
		<cfif stTask.bComplete>	
			<td><ft:button value="reopen" selectedObjectID="#stTask.objectID#" /></td>
		<cfelse>
			<td>
				<ft:button value="action" selectedObjectID="#stTask.objectID#" />
				<ft:button value="complete" selectedObjectID="#stTask.objectID#" />
			</td>
		</cfif>
		
	</tr>
	</cfoutput>
	
</cfloop>
<cfoutput></table></cfoutput>

<cfif bWorkflowTasksComplete>
	<ft:buttonPanel>
		<ft:button value="Complete Workflow" />
		<ft:button value="Decline Workflow" />
	<ft:buttonPanel>
</cfif>

</ft:form>

<cfsetting enablecfoutputonly="false">