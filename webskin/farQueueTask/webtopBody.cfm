<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<cfparam name="url.jobID" />


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
<cfset stButton.text = "Cancel Tasks" />
<cfset stButton.value = "canceltask" />
<cfset stButton.permission = "" />
<cfset stButton.onclick = "if (!confirm('Are you sure you want to cancel the selected tasks?')) return false;" />
<cfset stButton.hint = "Cancel the selected tasks">
<cfset arrayappend(aButtons,stButton) />

<cfset aColumns = arraynew(1) />

<cfset stColumn = structnew() />
<cfset stColumn.title = "Details" />
<cfset stColumn.webskin = "cellDetails" />
<cfset arrayappend(aColumns,stColumn) />

<cfset arrayappend(aColumns,"taskStatus") />
<cfset arrayappend(aColumns,"taskTimestamp") />

<ft:objectAdmin
	typename="#stObj.name#"
	columnList="taskStatus,taskTimestamp"
	sortableColumns="taskStatus,taskTimestamp"
	aCustomColumns="#aColumns#"
	lFilterFields="jobID,taskStatus"
	sqlOrderBy="taskTimestamp DESC"
	sqlWhere="jobID='#url.jobID#'"
	lButtons="testtask,canceltask"
	aButtons="#aButtons#"
	lButtonsEmpty="testtask"
	emptymessage="There are currently no tasks waiting to be processed"
	bViewCol="false"
	bPreviewCol="false"
	r_oTypeAdmin="oTypeAdmin" />

<cfsetting enablecfoutputonly="false">