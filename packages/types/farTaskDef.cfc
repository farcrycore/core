<cfcomponent 
	displayname="FarCry Task Definition" 
	extends="types" output="false"
	hint="Task definitions are used as template to create task instances" 
	fuAlias="fc-task-def" bSystem="true"
	icon="fa-ban">

	<cfproperty ftSeq="1" ftFieldset="General Details" name="title" type="string" default="" hint="Title of task definition" ftLabel="Title" ftType="string" />
	<cfproperty ftSeq="2" ftFieldset="General Details" name="description" type="longchar" default="" hint="Description of task definition" ftLabel="Description" />
	<cfproperty ftSeq="3" ftFieldset="General Details" name="taskWebskin" type="string" default="" hint="view to render on task activation; based on associated content type" ftLabel="Webskin" ftPrefix="workflow" ftDefault="edit" />	
	<cfproperty ftSeq="10" ftFieldset="Security" name="aRoles" type="array" default="" hint="roles to edit this task" ftLabel="Roles Responsible" ftJoin="farRole" ftRenderType="list" ftShowLibraryLink="false" />		

	<cffunction name="onStart" output="false" hint="fires the workflowStart webskin when workflow is created">
	
	</cffunction>
	
	<cffunction name="onTaskChange" output="false" hint="Fires whenever an associated task changes. Checks to see if all tasks are complete; trigger for onEnd()">
	
	</cffunction>
	
	<cffunction name="onEnd" output="false" hint="fires the workflowEnd webskin when workflow is complete">
	
	</cffunction>

</cfcomponent>