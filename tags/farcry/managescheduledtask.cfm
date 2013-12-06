<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: UI for manageing a scheduled task --->

<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<cfif thistag.ExecutionMode eq "end">
	<cfexit method="exittag" />
</cfif>

<cfset oCron = createobject("component",application.stCOAPI.dmCron.packagepath) />
<cfset qTasks = oCron.listTemplates() />

<cfparam name="attributes.task" />
<cfparam name="attributes.parameters" default="" />
<cfparam name="attributes.title" default="" />
<cfparam name="attributes.frequency" default="Daily" />
<cfparam name="attributes.startDate" default="#now()#" />
<cfparam name="attributes.id" default="" />

<!--- Convert struct parameters to querystring --->
<cfif isstruct(attributes.parameters)>
	<cfset temp = "" />
	<cfloop collection="#attributes.parameters#" item="thiskey">
		<cfset temp = listappend(temp,"#lcase(thiskey)#=#application.fc.lib.esapi.encodeForURL(attributes[thiskey])#","&") />
	</cfloop>
	<cfset attributes.parameters = temp />
</cfif>

<cfquery dbtype="query" name="qTasks">
	select	*
	from	qTasks
	where	path like '%/#attributes.task#.cfm'
</cfquery>

<cfif not qTasks.recordcount>
	<cfthrow message="Scheduled task type '#attributes.task#' does not exist" />
<cfelse>
	<cfset attributes.task = qTasks.path[1] />
</cfif>

<cfif not len(attributes.title)>
	<cfset attributes.title = qTasks.displayName[1] />
</cfif>

<cfif not len(attributes.id)>
	<cfset attributes.id = hash(attributes.task & attributes.parameters) />
</cfif>

<cfif structkeyexists(url,"createtask") and url.createtask eq attributes.id>
	<cfset stCron = structnew() />
	<cfset stCron.objectid = application.fc.utils.createJavaUUID() />
	<cfset stCron.label = attributes.title />
	<cfset stCron.title = attributes.title />
	<cfset stCron.template = attributes.task />
	<cfset stCron.parameters = attributes.parameters />
	<cfset stCron.frequency = attributes.frequency />
	<cfset stCron.startDate = attributes.startDate />
	<cfset stCron.endDate = "" />
	<cfset stCron.timeOut = 60 />
	<cfset oCron.setData(stProperties=stCron) />
	
	<skin:bubble message="Task '#attributes.title#' created" tags="sheduledtask,created,info" />
	
	<cflocation url="#cgi.script_name#?#rereplace(cgi.query_string,'(\?|&)createtask=[^&]*','')#" />
</cfif>

<cfif structkeyexists(url,"deletetask") and url.deletetask eq attributes.id>
	<cfquery datasource="#application.dsn#" name="qCron">
		select		objectid,parameters
		from		#application.dbowner#dmCron
		where		template=<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.task#">
					and parameters=<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.parameters#">
	</cfquery>
	
	<cfif qCron.recordcount>
		
		<cfset oCron.delete(objectid=qCron.objectid[1]) />
		<skin:bubble message="Task '#attributes.title#' deleted" tags="scheduledtask,deleted,info" />
	
	<cfelse>
	
		<skin:bubble title="Error" message="Task '#attributes.title#' does not exist" tags="scheduledtask,error" />
	
	</cfif>
	
	<cflocation url="#cgi.script_name#?#rereplace(cgi.query_string,'(\?|&)deletetask=[^&]*','')#" />
</cfif>

<cfquery datasource="#application.dsn#" name="qCron">
	select		objectid,parameters
	from		#application.dbowner#dmCron
	where		template=<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.task#">
				and parameters=<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.parameters#">
</cfquery>

<cfset redirectto = "#cgi.script_name#?#cgi.QUERY_STRING#" />

<cfif qCron.recordcount>
	<cfoutput><a href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#qCron.objectid[1]#&typename=dmCron">Edit task</a> | <a href="#application.url.webroot#/index.cfm?objectid=#qCron.objectid[1]#&#qCron.parameters[1]#&flushcache=1">Run task</a> | <a href="#redirectto#&deletetask=#attributes.id#">Delete task</a></cfoutput>
<cfelse>
	<cfoutput><a href="#redirectto#&createtask=#attributes.id#">Create task</a></cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false" />