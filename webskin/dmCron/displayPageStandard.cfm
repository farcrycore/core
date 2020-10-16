<cfsetting enablecfoutputonly="true" /> 
<!--- @@displayname: Core standard cron display --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au)--->

<cfset executionKey = application.fapi.getConfig("tasks", "executionKey") />
<cfif not structKeyExists(url, "executionKey") or url.executionKey neq executionKey>
	<cflog file="cron" text="Ignored scheduled task due to invalid execution key [#cgi.query_string#]" />
	<cfexit>
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