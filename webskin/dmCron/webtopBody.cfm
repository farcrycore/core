<cfsetting enablecfoutputonly="true">

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<!--- remove any legacy jobs from pre-7.0 environments --->
<cfset removeLegacyJobs()>

<!--- 
 // process custom actions 
--------------------------------------------------------------------------------->
<ft:processform action="Run Task">
	<cfset stTask = getData(objectid=form.selectedobjectid)>
	<cftry>
		<cfschedule action="run" task="#application.applicationname#: #sttask.title#">
		<skin:bubble title="#stTask.title# Run" message="The task has been run from the app server schedule." tags="success" />
		<cfcatch>
			<skin:bubble title="#stTask.title# Failed" message="#cfcatch.message#" tags="error" />
		</cfcatch>
	</cftry>
	<!--- <cfset stCron = createobject("component",application.stCOAPI.dmCron.packagepath).display(objectid=form.selectedobjectid) /> --->
</ft:processform>

<ft:processform action="Disable Task">
	<cfset removeJob(form.selectedobjectid)>
	<cfset stTask = getData(objectid=form.selectedobjectid)>
	<skin:bubble title="#stTask.title# Disabled" message="The task has been removed from the app servers jobs list." tags="info" />
</ft:processform>

<ft:processform action="Enable Task">
	<cfset addJob(form.selectedobjectid)>
	<cfset stTask = getData(objectid=form.selectedobjectid)>
	<skin:bubble title="#stTask.title# Enabled" message="The task has been added to the app servers jobs list." tags="success" />
</ft:processform>



<!--- 
 // view: show grid 
--------------------------------------------------------------------------------->
<ft:objectadmin 
	typename="dmCron"
	title="Scheduled Tasks"
	lCustomColumns="Job Status:cellJobStatus"
	columnList="title,template,bAutostart,frequency"
	sortableColumns="title,datetimelastUpdated,lastupdatedby"
	lFilterFields="title"
	sqlorderby="datetimelastUpdated desc"
	bPreviewCol="false"
	lCustomActions="Run Task,Disable Task,Enable Task" />

<cfsetting enablecfoutputonly="false">