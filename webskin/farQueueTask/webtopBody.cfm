<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif structkeyexists(url,"action") and url.action eq "testtask" and structkeyexists(url,"length")>
	<cfset application.fc.lib.tasks.addTask(action="testing.sleep",details=url.length) />
	<cflocation url="#application.fapi.fixURL(removevalues='action,length')#" addtoken="false" />
</cfif>

<ft:processform action="canceltask">
	<cfif len(form.objectID)>
		<cfloop list="#form.objectID#" index="thistask">
			<cfset application.fc.lib.tasks.removeTask(thistask) />
		</cfloop>
		<skin:bubble message="Canceled task/s" />
		<cflocation url="#application.fapi.fixURL()#" addtoken="false" />
	</cfif>
</ft:processform>


<cfset stFilterMetadata = structnew() />
<cfset stFilterMetadata.action.ftDefault = "" />
<cfset stFilterMetadata.action.ftValidation = "" />
<cfset stFilterMetadata.action.ftDisplayOnly = false />
<cfset stFilterMetadata.jobID.ftDefault = "" />
<cfset stFilterMetadata.jobID.ftValidation = "" />
<cfset stFilterMetadata.jobID.ftDisplayOnly = false />
<cfset stFilterMetadata.jobID.ftType = "string" />
<cfset stFilterMetadata.taskOwnedBy.default = "" />
<cfset stFilterMetadata.taskOwnedBy.ftDefault = "" />
<cfset stFilterMetadata.taskOwnedBy.ftValidation = "" />
<cfset stFilterMetadata.taskOwnedBy.ftDisplayOnly = false />
<cfset stFilterMetadata.taskStatus.ftDefault = "" />
<cfset stFilterMetadata.taskStatus.ftValidation = "" />
<cfset stFilterMetadata.taskStatus.ftDisplayOnly = false />

<cfset aButtons = arraynew(1) />

<cfset stButton = structnew() />
<cfset stButton.text = "Create Test Task" />
<cfset stButton.value = "testtask" />
<cfset stButton.permission = "" />
<cfset stButton.onclick = "var length = prompt('How long should the task take? (s)','30'); console.log(length);if (length) window.location='#application.url.webtop#/index.cfm?id=#url.id#&action=testtask&length='+length; return false;" />
<cfset stButton.hint = "Create a task that will take a specified length of time to complete">
<cfset arrayappend(aButtons,stButton) />

<cfset stButton = structnew() />
<cfset stButton.text = "Cancel Tasks" />
<cfset stButton.value = "canceltask" />
<cfset stButton.permission = "" />
<cfset stButton.onclick = "if (!confirm('Are you sure you want to cancel the selected tasks?')) return false;" />
<cfset stButton.hint = "Cancel the selected tasks">
<cfset arrayappend(aButtons,stButton) />

<ft:objectAdmin
	typename="#stObj.name#"
	columnList="objectid,taskOwnedBy,action,jobType,jobID,taskStatus,taskTimestamp,threadID"
	sortableColumns="taskOwnedBy,action,jobID,taskStatus,taskTimestamp"
	lFilterFields="action,jobID,taskOwnedBy,taskStatus"
	sqlOrderBy="taskTimestamp DESC"
	lButtons="testtask,canceltask"
	aButtons="#aButtons#"
	lButtonsEmpty="testtask,canceltask"
	emptymessage="There are currently no tasks waiting to be processed"
	bViewCol="false"
	bPreviewCol="false"
	r_oTypeAdmin="oTypeAdmin" />

<cfsetting enablecfoutputonly="false">