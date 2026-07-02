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

<cfsavecontent variable="html">
	<cftry>
		<!--- include scheduled task code and pass in parameters --->
		<cfinclude template="#stObj.template#">
		<cfcatch type="any"><cfdump var="#cfcatch#"></cfcatch>
	</cftry>

	<cfoutput>Done</cfoutput>
</cfsavecontent>

<cfset stObj.datetimeLastFinished = now() />
<cfset stObj.lastExecutionOutput = html />
<cfset setData(stProperties=stObj, bUpdateTask=false) />

<cfsetting enablecfoutputonly="false" /> 