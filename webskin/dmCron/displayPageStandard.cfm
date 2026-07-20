<cfsetting enablecfoutputonly="true" /> 
<!--- @@displayname: Core standard cron display --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au)--->

<cfset executionKey = application.fapi.getConfig("tasks", "executionKey") />
<cfif len(executionKey) and (not structKeyExists(url, "executionKey") or url.executionKey neq executionKey)>
	<cfset application.fapi.logEvent("cron", "warning", "ignored scheduled task: invalid execution key", {query=cgi.query_string}) />
	<cfexit>
</cfif>

<!--- in-process self-heal for the Lucee end-date bug: if this task should no longer be on the live
	schedule, re-assert its job so addJob neutralises it (past-dated "once") and it stops auto-firing.
	This fire is allowed to finish, since a manual "Run Task" reaches the same code and we must not block
	that; at worst one auto-fire leaks after expiry before the job is sealed. --->
<cfif not shouldAutoFire(stObj)>
	<cfset addJob(stObj.objectid) />
</cfif>

<cfloop list="#stObj.parameters#" index="thisparam" delimiters="&">
	<cfset url[listfirst(thisparam,"=")] = listlast(thisparam,"=") />
</cfloop>

<cfset stObj.datetimeLastExecuted = now() />
<cfset setData(stProperties=stObj, bUpdateTask=false) />

<cfset taskStartTick = getTickCount() />
<cfset taskFailed = false />
<!--- publish the task identity as ambient request context (MDC-style): every logEvent in this run - harness or task code - inherits objectid/task/source, so lines are self-describing and consistent. task/source also keep full filesystem paths out of the log. --->
<cfset stTask = describeTemplate(stObj.template) />
<cfset application.fapi.addLogContext({objectid=stObj.objectid, title=stObj.title, task=stTask.name, source=stTask.source}) />
<!--- alarm is a per-line routing signal, not provenance: the harness stamps it on outcome lines only, so an incidental error a task logs does not trip the failure alarm - failing the task does --->
<cfset taskAlarm = (structKeyExists(stObj, "bAlarm") ? stObj.bAlarm : false) />
<cfset application.fapi.logEvent("cron", "debug", "scheduled task started") />

<cfsavecontent variable="html">
	<cftry>
		<!--- include scheduled task code and pass in parameters --->
		<cfinclude template="#stObj.template#">
		<cfoutput>Done</cfoutput>
		<cfcatch type="any">
			<cfset taskFailed = true />
			<!--- surface failures instead of swallowing: exception lane (error logging + credential scrub) plus a cron event, but the fire still completes so a manual run is never blocked --->
			<cfset application.fc.lib.error.logData(application.fc.lib.error.normalizeError(cfcatch)) />
			<cfset application.fapi.logEvent("cron", "error", "scheduled task failed", {alarm=taskAlarm, durationMs=getTickCount()-taskStartTick, error=cfcatch.message}) />
			<cfoutput>FAILED: #encodeForHTML(cfcatch.message)#</cfoutput>
		</cfcatch>
	</cftry>
</cfsavecontent>

<cfif not taskFailed>
	<cfif structKeyExists(request, "cronOutcome")>
		<!--- task declared its own outcome: success->information, partial->warning, failed->error; the harness's own fields (alarm, durationMs, status) are protected from the task's stats --->
		<cfset stCronFields = {alarm=taskAlarm, durationMs=getTickCount()-taskStartTick, status=request.cronOutcome.status} />
		<cfset structAppend(stCronFields, request.cronOutcome.fields, false) />
		<cfset application.fapi.logEvent("cron", request.cronOutcome.level, "scheduled task finished", stCronFields) />
	<cfelse>
		<!--- task said nothing: honest neutral 'completed without an uncaught error', not a success claim --->
		<cfset application.fapi.logEvent("cron", "information", "scheduled task finished", {alarm=taskAlarm, durationMs=getTickCount()-taskStartTick}) />
	</cfif>
</cfif>

<cfset stObj.datetimeLastFinished = now() />
<cfset stObj.lastExecutionOutput = html />
<cfset setData(stProperties=stObj, bUpdateTask=false) />

<cfsetting enablecfoutputonly="false" /> 