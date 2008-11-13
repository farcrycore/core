<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: ObjectID table cell --->

<cfif structkeyexists(url,"createdmcron") and url.createdmcron eq stObj.objectid>
	<cfset stCron = structnew() />
	<cfset stCron.objectid = application.fc.utils.createJavaUUID() />
	<cfset stCron.label = "Generate #stObj.title# XML" />
	<cfset stCron.title = "Generate #stObj.title# XML" />
	<cfset stCron.template = "/farcry/core/admin/scheduledTasks/updateXMLFeed.cfm" />
	<cfset stCron.parameters = "oid=#stObj.objectid#" />
	<cfset stCron.frequency = "Daily" />
	<cfset stCron.startDate = now() />
	<cfset stCron.endDate = "" />
	<cfset stCron.timeOut = 60 />
	<cfset createobject("component",application.stCOAPI.dmCron.packagepath).setData(stProperties=stCron) />
</cfif>

<cfquery datasource="#application.dsn#" name="qCron">
	select		objectid,parameters
	from		#application.dbowner#dmCron
	where		parameters like '%#stObj.objectid#%'
</cfquery>

<cfif qCron.recordcount>
	<cfoutput><a href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#qCron.objectid[1]#&typename=dmCron">Edit task</a> | <a href="#application.url.webroot#/index.cfm?objectid=#qCron.objectid[1]#&#qCron.parameters[1]#&flushcache=1">Run task</a></cfoutput>
<cfelse>
	<cfoutput><a href="#cgi.script_name#?createdmcron=#stObj.objectid#">Create task</a></cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false" />