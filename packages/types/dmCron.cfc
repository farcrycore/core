<!--- @@Copyright: Daemon Pty Limited 2002-2014, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
TODO
	[ ] deal with tasks that change titles; ie can't be found as jobs
		- maybe change job name to APPNAME: UUID
		- maybe deal with it on set data
	[ ] clean up jobs on task deletion
	[ ] activate job on create and edit; afterSave()?
--->

<cfcomponent 
	extends="types" displayname="Scheduled Tasks" 
	hint="Scheduled tasks can be created to run periodic maintenance tasks unattended. Select from a list of available tasks and schedule when they should run." 
	bsystem="true" bojectbroker="true"
	icon="fa-tasks">


<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
	<cfproperty name="title" type="string" required="no" default="" 
		ftSeq="1" ftFieldset="General Details" ftLabel="Title"
		fthint="Title for the scheduled task.">

	<cfproperty name="description" type="longchar" required="no" default="" 
		ftSeq="2" ftFieldset="General Details" ftLabel="Description"
		fthint="Description for the scheduled task; what does it do?">


	<cfproperty name="template" type="string" required="no" default="" 
		ftSeq="11" ftFieldset="Task to Perform" ftLabel="Task to Perform" 
		ftType="list" 
		ftListData="getTemplateList"
		hint="List of available scheduled tasks.">

	<cfproperty name="parameters" type="string" required="no" default="" 
		ftSeq="12" ftFieldset="Task to Perform" ftLabel="URL Parameters"
		fthint="Optional. Any URL parameters that should be appended to the task URL; for example, myvar1=value&amp;myvar2=value">

	<cfproperty name="bAutoStart" type="boolean" required="true" default="true" 
		ftSeq="13" ftFieldset="Task to Perform" ftLabel="Autocreate Job"
		fttype="boolean"
		fthint="Task will be automatically rescheduled if it is missing when the application restarts.">


	<cfproperty name="datetimeLastExecuted" type="date" required="false" 
		ftSeq="21" ftFieldset="Status" ftLabel="Last Executed"
		ftType="datetime" ftDefaultType="Evaluate" ftDefault="now()" 
		ftDateFormatMask="dd mmm yyyy" ftTimeFormatMask="hh:mm tt" 
		ftShowTime="true">

	<cfproperty name="datetimeLastFinished" type="date" required="false" 
		ftSeq="22" ftFieldset="Status" ftLabel="Last Finished"
		ftType="datetime" ftDefaultType="Evaluate" ftDefault="now()" 
		ftDateFormatMask="dd mmm yyyy" ftTimeFormatMask="hh:mm tt" 
		ftShowTime="true">

	<cfproperty name="lastExecutionOutput" type="longchar" required="false"
		ftSeq="23" ftFieldset="Status" ftLabel="Last Execution Output">


	<cfproperty name="frequency" type="string" required="no" default="daily" 
		ftSeq="31" ftFieldset="Task Schedule" ftLabel="Frequency"
		ftType="list" 
		ftList="Once:Run once,Daily:Every day,Weekly:Every week,Monthly:Every month,3600:Every hour,1800:Every half-hour,900:Every 15. minute,60:Every minute"
		fthint="How often the task is run.">

	<cfproperty name="startDate" type="date" required="true" default=""
		ftSeq="32" ftFieldset="Task Schedule" ftLabel="Start Date"
		ftType="datetime" ftValidation="required"
		fthint="Start date/time for the task.">

	<cfproperty name="endDate" type="date" required="true" default=""
		ftSeq="33" ftFieldset="Task Schedule" ftLabel="End Date"
		ftType="datetime" ftValidation="required"
		fthint="End date/time for the task.">

	<cfproperty name="timeOut" type="integer" required="no" default="60" 
		ftSeq="34" ftFieldset="Task Schedule" ftLabel="Timeout"
		ftType="integer"
		fthint="How long will the task wait until it times out in seconds.">


<!--- 
 // formtool helper methods 
--------------------------------------------------------------------------------->
<cffunction name="getTemplateList" returntype="string" output="false" hint="returns a list (column name 'tmeplate') of available templates.">
	<cfset var lTemplates = "">
	<cfset var qListTemplates = listTemplates()>
	<cfloop query="qListTemplates">
		<cfset lTemplates = listAppend(lTemplates,"#qListTemplates.path#:#qListTemplates.displayname#")>
	</cfloop>
	<cfreturn lTemplates>
</cffunction>


<!--- 
 // controller: old skool invocation (please refactor) 
--------------------------------------------------------------------------------->
<cffunction name="display" access="public" output="true" hint="runs the scheduled task">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<cfset var thisparam = "" />
	
	<!--- getData for object edit --->
	<cfset var stObj = getData(arguments.objectid)>
	
	<cfloop list="#stObj.parameters#" index="thisparam" delimiters="&">
		<cfset url[listfirst(thisparam,"=")] = listlast(thisparam,"=") />
	</cfloop>
	
	<cftry>
	<!--- include scheduled task code and pass in parameters --->
	<cfinclude template="#stObj.template#">
	<cfcatch type="any"><cfdump var="#cfcatch#"></cfcatch>
	</cftry>
</cffunction>


<!--- 
 // scheduling cron jobs
--------------------------------------------------------------------------------->
<cffunction name="addJob" returntype="boolean" output="false" hint="Schedules a task on app server jobs list.">
	<cfargument name="objectid" type="uuid" required="false">
	<cfargument name="stobject" type="struct" required="false">
	
	<cfset var attr = structnew() />
	<cfset var dt = dateAdd('d', -1, now()) />
	
	<cfif structKeyExists(arguments, "objectid")>
		<cfset arguments.stobject = getData(objectid=arguments.objectid)>	
	</cfif>
	
	<cfif structIsEmpty(stobject)>
		<cfthrow type="Application" message="Argument *stobject* is empty.">
	</cfif>
	
	<cfscript>
	attr.action = "UPDATE";
	attr.task = "#application.applicationName#: #stobject.title#";
	attr.operation = "HTTPRequest";
	attr.url = "http://#cgi.HTTP_HOST##application.url.conjurer#?objectid=#stobject.objectid#&#stobject.parameters#";
	attr.interval = "#stobject.frequency#";
	if (application.fapi.getConfig('tasks', 'bEnabled')) {
		attr.startdate = "#dateFormat(stobject.startDate,'dd/mmm/yyyy')#";
		attr.starttime = "#timeFormat(stobject.startDate,'hh:mm tt')#";
		attr.enddate = "#dateFormat(stobject.endDate,'dd/mmm/yyyy')#";
		attr.endtime= "#timeFormat(stobject.endDate,'hh:mm tt')#";
	}
	else {
		// when scheduled tasks are "disabled", tasks are created as a run-once task in the
		// past so that they can still be executed from the webtop
		attr.startdate = "#dateFormat(dt,'dd/mmm/yyyy')#";
		attr.starttime = "#timeFormat(dt,'hh:mm tt')#";
		attr.enddate = "#dateFormat(dt,'dd/mmm/yyyy')#";
		attr.endtime= "#timeFormat(dt,'hh:mm tt')#";
	}
	attr.requesttimeout = "#stobject.timeout#";
	</cfscript>

	<cfif len(application.fapi.getConfig("tasks", "executionKey"))>
		<cfset attr.url &= "&executionKey=" & application.fapi.getConfig("tasks", "executionKey") />
	</cfif>

	<cfschedule attributeCollection="#attr#">
		
	<cfreturn true>
</cffunction>

<cffunction name="removeJob" returntype="boolean" output="false" hint="Removes a task from the app server jobs list.">
	<cfargument name="objectid" type="uuid" required="true">
	<cfset var stobject = getData(objectid=arguments.objectid)>
	<cfschedule	action="Delete"	task = "#application.applicationname#: #stobject.title#">
	<cfreturn true>
</cffunction>

<cffunction name="checkJobStatus" returntype="boolean" output="false" hint="Checks for the presence of a task on app server jobs list.">
	<cfargument name="objectid" type="uuid" required="true">
	<cfset var qJobs = listJobs()>
	<cfset var stobject = getdata(objectid=arguments.objectid)>
	<cfset var qJobStatus = queryNew("")>

	<cfquery dbtype="query" name="qJobStatus">
		SELECT task FROM qJobs WHERE task = '#application.applicationname#: #stobject.title#'
	</cfquery>

	<cfif qJobStatus.recordcount>
		<cfreturn true>
	<cfelse>
		<cfreturn false>
	</cfif>
</cffunction>

<cffunction name="listJobs" returntype="query" output="false" hint="Return a query of tasks on the job list.">
	<cfset var qJobs = queryNew("task,path,file,startdate,starttime,enddate,endtime,url,port,interval,timeout,username,password,proxyserver,proxyport,proxyuser,proxypassword,resolveurl,publish,valid,paused,autoDelete")>
	<cfset var stAttributes = structNew()>

	<cfset stAttributes.action = "list">
	<cfif isDefined("application.sysinfo.engine.engine") and application.sysinfo.engine.engine eq "coldfusion">
		<cfset stAttributes.result = "qJobs">
	<cfelseif isDefined("application.sysinfo.engine.engine") and application.sysinfo.engine.engine eq "lucee" and application.sysinfo.engine.productversion gte 5>
		<cfset stAttributes.result = "qJobs">
	<cfelse>
		<cfset stAttributes.returnvariable = "qJobs">
	</cfif>

	<cftry>
		<cfschedule action="#stAttributes.action#" attributeCollection="#stAttributes#">
		<cfcatch>
			<!--- 
			TODO: CF8/9 compatibility
				- Need to convert the old getCronService() hack into the equivalent action="list" query for this function 
				- <cfset aTasks = createobject("java","coldfusion.server.ServiceFactory").getCronService().listall()>
				- can only rely on the following columns: task, path, file, startdate, starttime, enddate, endtime, url, port, interval, timeout, username, password, proxyserver, proxyport, proxyuser, proxypassword, resolveurl, publish, valid, paused, autoDelete
			--->
			<!--- <cfthrow type="Application" message='CF8 and CF9 not supported' detail='Submit a pull request that integrates createobject("java","coldfusion.server.ServiceFactory").getCronService().listall() instead.'> --->
		</cfcatch>
	</cftry>
	<cfreturn qJobs>
</cffunction>

<cffunction name="addMissingJobs" returntype="boolean" output="true" hint="Add any missing tasks to the app server jobs list.">
	<cfset var qTasks = application.fapi.getcontentobjects(typename="dmCron", lproperties="objectid, title", bAutoStart_eq="1")>
	<cfset var qJobs = listJobs()>
	<cfset var qJobCheck = queryNew("")>

	<cfloop query="qTasks">
		<cfquery dbtype="query" name="qJobCheck">
			SELECT task FROM qJobs WHERE task = '#application.applicationname#: #qTasks.title#'
		</cfquery>
		<cfif qJobCheck.recordcount eq 0>
			<cfset addJob(qTasks.objectid)>
		</cfif>
	</cfloop>

	<cfreturn true>
</cffunction>

<cffunction name="removeLegacyJobs" returntype="boolean" output="false" hint="Removes any tasks using the old naming format from app server jobs list.">
	<cfset var qJobs = listJobs()>

	<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

	<cfquery dbtype="query" name="qJobs">
		SELECT * FROM qJobs WHERE task LIKE '#application.applicationname#\_%'
		ESCAPE '\';
	</cfquery>

	<cfloop query="qJobs">
		<cfschedule	action="Delete"	task = "#qJobs.task#">
		<skin:bubble title="#qJobs.task# Removed" message="The task has been removed from the app server jobs list." tags="info" />
	</cfloop>

	<cfreturn true>
</cffunction>


<!--- 
 //  type functions 
--------------------------------------------------------------------------------->
<cffunction name="setData" access="public" output="true" hint="Creates a scheduled task and actual dmCron object">
	<cfargument name="stProperties" required="true">
	<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
	<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Updated">
	<cfargument name="bAudit" type="boolean" required="No" default="1" hint="Pass in 0 if you wish no audit to take place">
	<cfargument name="dsn" required="No" default="#application.dsn#">
	<cfargument name="bSessionOnly" type="boolean" required="false" default="false"><!--- This property allows you to save the changes to the Temporary Object Store for the life of the current session. ---> 
	<cfargument name="bAfterSave" type="boolean" required="false" default="true" hint="This allows the developer to skip running the types afterSave function.">	
	<cfargument name="bUpdateTask" type="boolean" required="false" default="true" hint="Custom flag to allow turning off the task update">

	<cfset var stExistingObj	= '' />
	
	<cfif not arguments.bSessionOnly and structKeyExists(arguments.stProperties,"title")>
		<!--- check if task has been renamed --->
		<cfset stExistingObj = getData(arguments.stProperties.objectid)>	
		<cfif stExistingObj.title neq arguments.stProperties.title>
			<cftry>
				<!--- delete old task --->
				<cfschedule	action="Delete"	task = "#application.applicationName#: #stExistingObj.title#">
				<cfcatch></cfcatch>
			</cftry>
		</cfif>
		
		<!--- add/update task --->
		<cfset addJob(stobject=arguments.stProperties)>
	</cfif>	
	
	<!--- update object --->
	<cfreturn super.setData(arguments.stProperties,arguments.user,arguments.auditNote,arguments.bAudit,arguments.dsn,arguments.bSessionOnly,arguments.bAfterSave) />
</cffunction>

<cffunction name="delete" access="public" hint="Remove task from CFML Engine, then remove from database" returntype="struct" output="false">
	<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
	<cfargument name="user" type="string" required="true" hint="Username for object creator" default="">
	<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="">
		
	<cfset removeJob(arguments.objectid)>

	<cfreturn super.delete(argumentCollection = arguments) />
</cffunction>

<cffunction name="latestRunningWindow" access="public" output="false" returntype="struct" hint="Calculates the most recent running window">
	<cfargument name="stCron" type="struct" required="true">
	<cfargument name="dt" type="datetime" required="false" default="#now()#">

	<cfset var currentDate = arguments.dt />

	<cfif currentDate lt arguments.stCron.startDate>
		<cfreturn {}><!--- Hasn't started --->
	</cfif>
	<cfif currentDate gt arguments.stCron.endDate>
		<cfset currentDate = arguments.stCron.endDate><!--- Has finished --->
	</cfif>

	<!--- Figure out most recent start time --->
	<cfset var recentStart = currentDate />
	<cfset var diff = 0 />
	<cfswitch expression="#arguments.stCron.frequency#">
		<cfcase value="Once">
			<cfset recentStart = arguments.stCron.startDate />
		</cfcase>
		<cfcase value="Daily">
			<cfset diff = dateDiff("d", arguments.stCron.startDate, recentStart) />
			<cfset recentStart = dateAdd("d", diff, arguments.stCron.startDate) />
		</cfcase>
		<cfcase value="Weekly">
			<cfset diff = dateDiff("ww", arguments.stCron.startDate, recentStart) />
			<cfset recentStart = dateAdd("ww", diff, arguments.stCron.startDate) />
		</cfcase>
		<cfcase value="Monthly">
			<cfset diff = dateDiff("m", arguments.stCron.startDate, recentStart) />
			<cfset recentStart = dateAdd("m", diff, arguments.stCron.startDate) />
		</cfcase>
		<cfcase value="3600">
			<cfset diff = dateDiff("h", arguments.stCron.startDate, recentStart) />
			<cfset recentStart = dateAdd("h", diff, arguments.stCron.startDate) />
		</cfcase>
		<cfcase value="1800">
			<cfset diff = floor(dateDiff("n", arguments.stCron.startDate, recentStart) / 30) />
			<cfset recentStart = dateAdd("n", diff * 30, arguments.stCron.startDate) />
		</cfcase>
		<cfcase value="900">
			<cfset diff = floor(dateDiff("n", arguments.stCron.startDate, recentStart) / 15) />
			<cfset recentStart = dateAdd("n", diff * 15, arguments.stCron.startDate) />
		</cfcase>
		<cfcase value="60">
			<cfset diff = dateDiff("n", arguments.stCron.startDate, recentStart) />
			<cfset recentStart = dateAdd("n", diff, arguments.stCron.startDate) />
		</cfcase>

		<cfdefaultcase>
			<cfreturn false>
		</cfdefaultcase>
	</cfswitch>

	<cfreturn {
		"start" = recentStart,
		"end" = dateAdd("s", arguments.stCron.timeout, recentStart)
	} />
</cffunction>

<cffunction name="nextRunningWindow" access="public" output="false" returntype="struct" hint="Calculates the next running window">
	<cfargument name="stCron" type="struct" required="true">
	<cfargument name="dt" type="datetime" required="false" default="#now()#">

	<cfset var currentDate = arguments.dt />

	<cfif currentDate lt arguments.stCron.startDate>
		<cfreturn {
			"start" = arguments.stCron.startDate,
			"end" = dateAdd("s", arguments.stCron.timeout, arguments.stCron.startDate)
		} /><!--- Scheduled for the future --->
	</cfif>
	<cfif currentDate gt arguments.stCron.endDate>
		<cfreturn {}><!--- Has finished --->
	</cfif>

	<!--- Figure out most recent start time --->
	<cfset var nextStart = currentDate />
	<cfset var diff = 0 />
	<cfswitch expression="#arguments.stCron.frequency#">
		<cfcase value="Daily">
			<cfset diff = dateDiff("d", arguments.stCron.startDate, nextStart) />
			<cfset nextStart = dateAdd("d", diff + 1, arguments.stCron.startDate) />
		</cfcase>
		<cfcase value="Weekly">
			<cfset diff = dateDiff("ww", arguments.stCron.startDate, nextStart) />
			<cfset nextStart = dateAdd("ww", diff + 1, arguments.stCron.startDate) />
		</cfcase>
		<cfcase value="Monthly">
			<cfset diff = dateDiff("m", arguments.stCron.startDate, nextStart) />
			<cfset nextStart = dateAdd("m", diff + 1, arguments.stCron.startDate) />
		</cfcase>
		<cfcase value="3600">
			<cfset diff = dateDiff("h", arguments.stCron.startDate, nextStart) />
			<cfset nextStart = dateAdd("h", diff + 1, arguments.stCron.startDate) />
		</cfcase>
		<cfcase value="1800">
			<cfset diff = floor(dateDiff("n", arguments.stCron.startDate, nextStart) / 30) />
			<cfset nextStart = dateAdd("n", (diff + 1) * 30, arguments.stCron.startDate) />
		</cfcase>
		<cfcase value="900">
			<cfset diff = floor(dateDiff("n", arguments.stCron.startDate, nextStart) / 15) />
			<cfset nextStart = dateAdd("n", (diff + 1) * 15, arguments.stCron.startDate) />
		</cfcase>
		<cfcase value="60">
			<cfset diff = dateDiff("n", arguments.stCron.startDate, nextStart) />
			<cfset nextStart = dateAdd("n", diff + 1, arguments.stCron.startDate) />
		</cfcase>

		<cfdefaultcase>
			<cfreturn false>
		</cfdefaultcase>
	</cfswitch>

	<cfif nextStart gt arguments.stCron.endDate>
		<cfreturn {}><!--- Will finish before next window can start --->
	</cfif>

	<cfreturn {
		"start" = nextStart,
		"end" = dateAdd("s", arguments.stCron.timeout, nextStart)
	} />
</cffunction>

<cffunction name="inRunningWindow" access="public" output="false" returntype="boolean" hint="Attempts to determine if a given time is in one of a tasks execution windows">
	<cfargument name="stCron" type="struct" required="true">
	<cfargument name="dt" type="datetime" required="false" default="#now()#">

	<cfset var recentWindow = latestRunningWindow(argumentCollection=arguments) />
	<cfif structIsEmpty(recentWindow)>
		<cfreturn false />
	</cfif>

	<cfreturn recentWindow.start lte now() and now() lte recentWindow.end />
</cffunction>

<!--- 
 // private functions 
--------------------------------------------------------------------------------->
<cffunction name="listTemplates" access="private" output="false" returntype="query" hint="Returns a query of available core and custom task methods.">
	
	<cfset var qTemplates	= queryNew("displayName, path") />
	<cfset var plugin	= '' />
	<cfset var paths = {} />
	<cfset var metadata = {} />
	<cfset var fullpath = "" />
	<cfset var pathname = "" />

	<cfset paths[application.rb.getResource('coapi.dmCron.tasktype.core@label','Core')] = "#application.path.core#/webtop/scheduledTasks" />
	<cfset paths[application.rb.getResource('coapi.dmCron.tasktype.custom@label','Custom')] = "#application.path.project#/system/dmCron" />

	<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">

	<cfloop list="#application.plugins#" index="plugin">
		<cfset paths["#plugin# plugin"] = "#application.path.plugins#/#plugin#/system/dmCron" />
	</cfloop>

	<!--- get core templates --->	
	<nj:listTemplates path="#paths#" prefix="" r_metadata="metadata" r_fullpath="fullpath" r_pathname="pathname">
		<cfset queryAddRow(qTemplates, 1)>
		<cfset querySetCell(qTemplates, "displayname", "#metadata.displayname# (#pathname#)")>
		<cfset querySetCell(qTemplates, "path", fullpath)>
	</nj:listTemplates>

	<cfreturn qTemplates>
</cffunction>

</cfcomponent>
