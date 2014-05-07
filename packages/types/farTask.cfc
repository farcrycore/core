<cfcomponent 
	displayname="FarCry Task Instance" 
	extends="types" output="false" 
	hint="Task instance used to keep track of work to be done in a workflow." 
	fuAlias="fc-task" bSystem="true"
	icon="fa-ban">

	<cfproperty ftSeq="1" ftFieldset="General Details" name="title" type="string" default="" hint="Title of task definition" ftLabel="Title" ftType="string" />
	<cfproperty ftSeq="2" ftFieldset="General Details" name="description" type="longchar" default="" hint="Description of task definition" ftLabel="Notes" />
	<cfproperty ftSeq="3" ftFieldset="General Details" name="userID" type="UUID" default="" hint="specific user to edit this task" ftLabel="User Responsible" ftJoin="dmProfile" ftRenderType="list" ftLibraryData="getProfileList" ftShowLibraryLink="false" />		

	<cfproperty name="taskWebskin" type="string" default="" hint="view to render on task activation; based on associated content type" ftLabel="Webskin" ftPrefix="workflow" ftDefault="edit" />	
	<cfproperty name="taskDefID" type="UUID" default="" hint="Reference to parent workflow definition" ftLabel="Task Definition" ftType="uuid" ftJoin="farTaskDef" ftAllowLibraryEdit="farTaskDef" />
	<cfproperty name="bComplete" type="boolean" default="0" hint="Boolean for task completion" ftLabel="Complete" />
	
	
	<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

	
	<cffunction name="getProfileList" access="public" output="false" returntype="query" hint="Returns query of users to be used for the userID field list">
		
		<cfargument name="primaryID" type="uuid" required="true" />
		
		<cfset var stTask = getData(objectid="#arguments.primaryID#") />
		<cfset var stTaskDef = createObject("component", application.stcoapi.farTaskDef.packagePath).getData(objectid="#stTask.taskDefID#") />
		<cfset var q = queryNew("objectid,label")>
		<cfset var lProfileIDs	= createObject("component", application.stcoapi.farRole.packagePath).getAuthenticatedProfiles(roles="#arrayToList(stTaskDef.aRoles)#") />
		
		<cfif len(lProfileIDs)>
			<cfquery datasource="#application.dsn#" name="q">
			SELECT objectid, firstName as label
			FROM dmProfile
			WHERE objectid IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lProfileIDs#">)
			order by username
			</cfquery>
		</cfif>
		<cfreturn q />
	</cffunction>
		
	<cffunction name="afterSave" output="false" hint="fires the workflowEnd webskin when workflow is complete">
		<cfargument name="stProperties" required="true">
		
		<cfset var bTasksComplete = true />
		<cfset var qWorkflow = queryNew("blah") />
		<cfset var qWorkflowTasks = queryNew("blah") />
		<cfset var stUpdateWorkflow = structNew() />
		<cfset var stResult = structNew() />
		<cfset var oWorkflow	= '' />
		<cfset var stWorkflow	= '' />
		<cfset var oWorkflowDef	= '' />
		<cfset var stWorkflowDef	= '' />

		<cfquery datasource="#application.dsn#" name="qWorkflow">
		SELECT * FROM farWorkflow_aTaskIDs
		WHERE data = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stProperties.objectid#">
		</cfquery>
		
		<cfif qWorkflow.recordcount>
		
			<cfset oWorkflow = createObject("component", application.stcoapi.farWorkflow.packagepath) />
			<cfset stWorkflow = oWorkflow.getData(objectid="#qWorkflow.parentID#") />
			<cfset oWorkflowDef = createObject("component", application.stcoapi.farWorkflowDef.packagepath) />
			<cfset stWorkflowDef = oWorkflowDef.getData(objectid="#stWorkflow.workflowDefID#") />
			
			<cfquery datasource="#application.dsn#" name="qWorkflowTasks">
			SELECT * FROM farTask
			WHERE objectid IN (
				SELECT data FROM farWorkflow_aTaskIDs
				WHERE parentID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qWorkflow.parentID#">
			)

			</cfquery>

			
			<cfloop query="qWorkflowTasks">
				<cfif not qWorkflowTasks.bComplete>
					<cfset bTasksComplete = false />
					<cfbreak />
				</cfif>
			</cfloop>

			
			<cfset stUpdateWorkflow = structNew() />
			<cfset stUpdateWorkflow.objectid = stWorkflow.objectid />
			<cfset stUpdateWorkflow.bTasksComplete = bTasksComplete />
			
			<cfset stResult = oWorkflow.setData(stProperties="#stUpdateWorkflow#") />
			
			<cfif bTasksComplete>	
				<skin:view objectid="#stWorkflow.referenceid#" template="#stWorkflowDef.workflowEnd#" alternateHTML="" />				
			</cfif>
		</cfif>
	</cffunction>


</cfcomponent>