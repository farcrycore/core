<cfcomponent 
	displayname="FarCry Workflow Instance" 
	extends="types" output="false" 
	hint="Workflow instance contains details of the work to be performed" 
	fuAlias="fc-workflow" bSystem="true"
	icon="fa-cogs">

	<cfproperty ftSeq="1" ftFieldset="" name="title" type="string" default="" hint="Title of workflow instance" ftLabel="Title" ftType="string" ftValidation="required" />
	<cfproperty ftSeq="2" ftFieldset="" name="description" type="longchar" default="" hint="Description of work to be performed" ftLabel="Description" />
	<cfproperty ftSeq="3" ftFieldset="" name="aTaskIDs" type="array" default="" hint="An array of task instances that make up the workflow process" ftLabel="Tasks" ftType="array" ftJoin="farTask" />
	<cfproperty ftSeq="4" ftFieldset="" name="completionDate" type="date" default="" hint="Date of expected workflow completion. Defaults to now plus value of minToComplete from workflow definition" ftLabel="Completion Date" ftType="dateTime" ftDefault="getDefaultCompletionDate" ftDefaultType="function" />

	<cfproperty ftSeq="8" ftFieldset="" name="workflowDefID" type="UUID" default="" hint="Reference to parent workflow definition" ftLabel="Workflow Definition" ftType="uuid" ftValidation="required" ftJoin="farWorkflowDef" ftRenderType="list" ftLibraryData="workflowDefIDLibraryData" ftShowLibraryLink="false" />
	<cfproperty ftSeq="9" ftFieldset="" name="referenceID" type="UUID" default="" hint="Reference to the underlying content item" ftLabel="Reference Content Item" ftType="string" />
	<cfproperty ftSeq="10" ftFieldset="" name="bWorkflowSetupComplete" type="boolean" default="0" hint="Boolean for workflow setup complete" ftLabel="setup complete" ftDefault="0" />
	<cfproperty ftSeq="10" ftFieldset="" name="bTasksComplete" type="boolean" default="0" hint="Boolean for workflow completion" ftLabel="Complete" ftDefault="0" />
	<cfproperty ftSeq="10" ftFieldset="" name="bWorkflowComplete" type="boolean" default="0" hint="Boolean for workflow completion" ftLabel="Complete" ftDefault="0" />
	<cfproperty ftSeq="11" ftFieldset="" name="bActive" type="boolean" default="1" hint="Boolean for if the workflow is active" ftLabel="Active" ftDefault="1" />

	<cffunction name="hasInstance" access="public" output="false" returntype="struct" hint="Determines if the objectid passed in has a workflow instance assigned.">
		<cfargument name="referenceID" required="true" />
		
		<cfset var q = queryNew("blah") />
		<cfset var stResult = structNew() />
		
		<cfquery datasource="#application.dsn#" name="q">
		SELECT objectid from farWorkflow
		WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.referenceID#">
		AND bActive = 1
		</cfquery>
		
		<cfif q.recordCount>
			<cfset stResult = getData(objectid="#q.objectid#") />
		</cfif>
		
		<cfreturn stResult />
		
	</cffunction>
	
	
	<cffunction name="getDefaultCompletionDate" access="public" output="false" returntype="string" hint="Calculates the default completion date">
		<cfargument name="stProperties" type="struct" required="true" />
		
		<cfset var result = "" />
		<cfset var stWorkflowDef	= '' />
		
  		<cfif structKeyExists(stProperties, "workflowDefID") AND len(stProperties.workflowDefID)>
			<cfset stWorkflowDef = createObject("component", application.stcoapi.farWorkflowDef.packagePath).getData(objectid="#stProperties.workflowDefID#") />
			
			<cfset result = dateAdd("n", stWorkflowDef.minToComplete, now()) />
			
			<cfset result = createODBCDate(result) />
		</cfif>
		<cfreturn "result" />
	</cffunction> 

	<cffunction name="workflowDefIDLibraryData" access="public" output="false" returntype="query" hint="Return a query for with all relevent workflow definitions.">
		<cfargument name="primaryID" type="uuid" required="true" hint="ObjectID of the object that we are attaching to" />
		<cfargument name="qFilter" type="query" required="false" default="#queryNew('blah')#" hint="If a library verity search has been run, this is the qResultset of that search" />
	
		<cfset var q = queryNew("blah") />
	
		<cfset var stObject = getData(objectid="#arguments.primaryID#") />

		<cfset var referenceTypename = application.coapi.coapiUtilities.findType(objectid="#stObject.referenceID#") />		

		<cfset var lWorkflowList = getWorkflowList(typename="#referenceTypename#") />
		
		<!---
		Run the entire query and return in to the library. Let the library handle the pagination.
		 --->
		<cfquery datasource="#application.dsn#" name="q">
		SELECT objectid, label
		FROM farWorkflowDef
		WHERE ObjectID IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lWorkflowList#">)
		<cfif arguments.qFilter.RecordCount>
			AND ObjectID IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#ValueList(qFilter.key)#" />
		</cfif>
		ORDER BY title
		</cfquery>

		<cfreturn q />
	
	</cffunction>
	
	
	<cffunction name="deactivateWorkflow" access="public" output="false" returntype="void" hint="Deactivates any workflows if the underlying content item is not draft.">
		<cfargument name="referenceID" required="true" />
		<cfargument name="referenceTypename" required="true" />
				
		<cfset var q = queryNew("blah") />
		<cfset var stResult = structNew() />
		<cfset var stProperties = structNew() />
		<cfset var o = createObject("component", application.stcoapi[arguments.referenceTypename].packagePath) />
		<cfset var st = o.getData(objectid="#arguments.referenceID#") />
		

	
		<cfquery datasource="#application.dsn#" name="q">
		SELECT objectid from farWorkflow
		WHERE referenceID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.referenceID#">
		AND bActive = 1
		</cfquery>

		<cfloop query="q">
			<cfset stProperties = structNew() />
			<cfset stProperties.objectid = q.objectid />
			<cfset stProperties.bActive = 0 />
			<cfset stResult = setData(stProperties="#stProperties#") />
		</cfloop>
	

		
	</cffunction>
	
	
	<cffunction name="getWorkflowList" access="public" output="false" returntype="string" hint="Returns the list of workflow ids available for a typename.">
		<cfargument name="typename" required="true" />
		
		<cfset var rHTML = "" />
		<cfset var lWorkflowIDs = "" />
		<cfset var qWorkflowDefs = queryNew("blah") />
		<cfset var stWorkflow = structNew() />
		<cfset var workflowTypename = "" />
		
		
		<cfquery datasource="#application.dsn#" name="qWorkflowDefs">
		SELECT * from farWorkflowDef
		</cfquery>
	
		<cfloop query="qWorkflowDefs">
			<cfif listLen(qWorkflowDefs.lTypenames)>
				<cfloop list="#qWorkflowDefs.lTypenames#" index="workflowTypename">
					<cfif workflowTypename EQ arguments.typename>
						<cfset lWorkflowIDs = listAppend(lWorkflowIDs, qWorkflowDefs.objectid) />
						<cfbreak />
					</cfif>
				</cfloop>
			<cfelse>
				<cfset lWorkflowIDs = listAppend(lWorkflowIDs, qWorkflowDefs.objectid) />
			</cfif>
		</cfloop>
		
		
		<cfreturn lWorkflowIDs />

	</cffunction>
	
	
	
	<cffunction name="setupInstance" access="public" output="false" returntype="string" hint="If the passed object requires workflow and has no instance assigned, show the instance creation.">
		<cfargument name="referenceID" required="true" />
		<cfargument name="referenceTypename" required="true" />
		
		<cfset var rHTML = "" />
		<cfset var lWorkflowIDs = "" />
		<cfset var qWorkflowDefs = queryNew("blah") />
		<cfset var stWorkflow = structNew() />
		<cfset var stInstance = structNew() />
		<cfset var stResult = structNew() />
		
		
		<cfset lWorkflowIDs = getWorkflowList(typename="#arguments.referenceTypename#") />
		
		<cfif listLen(lWorkflowIDs)>
			<cfset stWorkflow = structNew() />
			
			<cfset stInstance = hasInstance(referenceID="#arguments.referenceID#") />
			<cfif not structIsEmpty(stInstance)>
				<cfset stWorkflow.objectid = stInstance.objectID />
			<cfelse>
				<cfset stWorkflow.objectid = application.fc.utils.createJavaUUID() />
			</cfif>		
			<cfset stWorkflow.referenceID = arguments.referenceID />
			<cfset stResult = setData(stProperties="#stWorkflow#") />
			<cfset rHTML = getView(objectid="#stWorkflow.objectid#", template="edit") />
			
		</cfif>
		
		<cfreturn rHTML />
	</cffunction>

	<cffunction name="onStart" access="public" output="false" hint="Runs default workflowStart webskin when workflow is created">
		<cfargument name="objectid" required="true" />
		
		<cfset var stWorkflow = getData(objectid="#arguments.objectID#") />
		<cfset var stWorkflowDef = createobject("component", application.stcoapi.farWorkflowDef.packagePath).getData(objectid="#stWorkflow.workflowDefID#") />
		<cfset var stResult = structNew() />
		
		<cflocation url="#application.url.webtop#/conjuror/invocation.cfm?objectid=#stWorkflow.referenceID#&method=#stWorkflowDef.workflowStart#">
		
		<cfreturn stResult />
		
	</cffunction>
	<cffunction name="onTaskChange" access="public" output="false" hint="Event fires whenever an associated task changes. Checks to see if all tasks are complete">
		<cfargument name="objectid" required="true" />
		
		<cfset var stWorkflow = getData(objectid="#arguments.objectID#") />
		
	</cffunction>
	<cffunction name="onEnd" access="public" output="false" hint="Runs default workflowEnd webskin when workflow is complete" returntype="void">
		<cfargument name="objectid" required="true" />
		
		<cfset var stWorkflow = getData(objectid="#arguments.objectID#") />
		<cfset var stWorkflowDef = createobject("component", application.stcoapi.farWorkflowDef.packagePath).getData(objectid="#stWorkflow.workflowDefID#") />
		<cfset var stResult = structNew() />
				
		<cflocation url="#application.url.webtop#/conjuror/invocation.cfm?objectid=#stWorkflow.referenceID#&method=#stWorkflowDef.workflowEnd#">

		
	</cffunction>
	
	<cffunction name="getWorkflowContentObject" access="public" output="false" hint="Returns the object referenced in the referenceID" returntype="struct">
		<cfargument name="objectid" required="true" />
		
		<cfset var stWorkflow = getData(objectid="#arguments.objectid#") />
		<cfset var typename = createObject("component", "farcry.core.packages.fourq.fourq").findType(objectid="#stWorkflow.referenceID#") />
		<cfset var stContentObject = createObject("component", application.stCoapi[typename].packagepath).getData(objectid="#stWorkflow.referenceID#") />
		
		<cfreturn stContentObject />
	</cffunction>
	
	<cffunction name="renderWorkflow" access="public" output="false" returntype="string" hint="Returns the workflow administration for an object">
		<cfargument name="referenceID" required="true" />
		<cfargument name="referenceTypename" required="true">
		
		<cfset var returnHTML = "" />
		<cfset var lWorkflowIDs = "" />
		<cfset var stInstance = structNew() />
		<cfset var stObject = createObject("component", application.stcoapi["#arguments.referenceTypename#"].packagepath).getData(objectid="#arguments.referenceID#") />
		<cfset var bShowActions	= '' />
		
		<cfif structKeyExists(stobject, "status") AND stObject.status EQ "draft">
			<cfset lWorkflowIDs = getWorkflowList(typename="#stObject.typename#") />
			
			<cfif listLen(lWorkflowIDs)>
				<cfset stInstance = hasInstance(referenceID="#stObject.objectid#") />
				
				<cfif not structIsEmpty(stInstance) and stInstance.bWorkflowSetupComplete>
					<cfset returnHTML = getView(objectid="#stInstance.objectid#", template="editWorkflowActive") />
				<cfelse>
					<cfset returnHTML = setupInstance(referenceID="#stObject.objectid#", referenceTypename="#stObject.typename#") />
					
					<cfset bShowActions = false />
				</cfif>
			<cfelse>
				<cfset deactivateWorkflow(referenceID="#stObject.objectid#", referenceTypename="#stObject.typename#") />
			</cfif>
		<cfelse>
			<cfset deactivateWorkflow(referenceID="#stObject.objectid#", referenceTypename="#stObject.typename#") />
		</cfif>

		<cfreturn returnHTML />
		
	</cffunction>
			
</cfcomponent>
