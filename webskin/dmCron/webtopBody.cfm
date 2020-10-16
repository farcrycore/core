<cfsetting enablecfoutputonly="true">

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<!--- remove any legacy jobs from pre-7.0 environments --->
<cfset removeLegacyJobs()>

<!--- 
 // process custom actions 
--------------------------------------------------------------------------------->
<ft:processform action="Run Task" url="refresh">
	<cfset stTask = getData(objectid=form.selectedobjectid)>
	<cftry>
		<cfschedule action="run" task="#application.applicationname#: #sttask.title#">
		<skin:bubble title="#stTask.title# Run" message="The task has been run from the app server schedule." tags="success" />
		<cfcatch>
			<skin:bubble title="#stTask.title# Failed" message="#cfcatch.message#" tags="error" />
		</cfcatch>
	</cftry>
</ft:processform>

<ft:processform action="Disable Task" url="refresh">
	<cfset removeJob(form.selectedobjectid)>
	<cfset stTask = getData(objectid=form.selectedobjectid)>
	<skin:bubble title="#stTask.title# Disabled" message="The task has been removed from the app servers jobs list." tags="info" />
</ft:processform>

<ft:processform action="Enable Task" url="refresh">
	<cfset addJob(form.selectedobjectid)>
	<cfset stTask = getData(objectid=form.selectedobjectid)>
	<skin:bubble title="#stTask.title# Enabled" message="The task has been added to the app servers jobs list." tags="success" />
</ft:processform>

<ft:processform action="Last Run Output">
	<cfset outputURL = application.fapi.getLink(type="dmCron", objectid=form.selectedobjectid, view="webtopPageModal", bodyView="webtopBodyOutput") />
	<skin:onReady><cfoutput>
		$fc.objectAdminAction('Task Output', '#outputURL#');
	</cfoutput></skin:onReady>
</ft:processform>


<cfset aCustomColumns = [
	{
		"title": "Job Status",
		"webskin": "cellJobStatus"
	},
	"title",
	{
		"title": "Description",
		"webskin": "cellDescription"
	},
	"template",
	"bAutostart",
	"frequency",
	"datetimeLastExecuted",
	"datetimeLastFinished",
	{
		"title": "Next execution",
		"webskin": "cellNextRun"
	}
] />

<cfif not application.fapi.getConfig("tasks", "bEnabled")>
	<cfoutput><div class="alert alert-warning">Scheduled tasks have been disabled for this server. Tasks will not execute automatically.</div></cfoutput>
</cfif>

<ft:objectadmin 
	typename="dmCron"
	title="Scheduled Tasks"
	aCustomColumns="#aCustomColumns#"
	columnList="title,template,bAutostart,frequency,datetimeLastExecuted,datetimeLastFinished"
	sortableColumns="title,datetimelastUpdated,datetimeLastExecuted,datetimeLastFinished,lastupdatedby"
	lFilterFields="title"
	sqlorderby="datetimelastUpdated desc"
	bPreviewCol="false"
	lCustomActions="Run Task,Disable Task,Enable Task,Last Run Output" />

<cfsetting enablecfoutputonly="false">