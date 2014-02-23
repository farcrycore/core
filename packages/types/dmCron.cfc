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
		ftSeq="3" ftFieldset="Task to Perform" ftLabel="Task to Perform" 
		ftType="list" 
		ftListData="getTemplateList"
		hint="List of available scheduled tasks.">

	<cfproperty name="parameters" type="string" required="no" default="" 
		ftSeq="4" ftFieldset="Task to Perform" ftLabel="URL Parameters"
		fthint="Optional. Any URL parameters that should be appended to the task URL; for example, myvar1=value&amp;myvar2=value">

	<cfproperty name="bAutoStart" type="boolean" required="true" default="true" 
		ftSeq="5" ftFieldset="Task to Perform" ftLabel="Auto Start Job"
		fttype="boolean"
		fthint="Task will be automatically rescheduled if it is missing when the application restarts.">

	<cfproperty name="frequency" type="string" required="no" default="daily" 
		ftSeq="6" ftFieldset="Task Schedule" ftLabel="Frequency"
		ftType="list" 
		ftList="Once:Run once,Daily:Every day,Weekly:Every week,Monthly:Every month,3600:Every hour,1800:Every half-hour,900:Every 15. minute,60:Every minute"
		fthint="How often the task is run.">

	<cfproperty name="startDate" type="date" required="true" default=""
		ftSeq="7" ftFieldset="Task Schedule" ftLabel="Start Date"
		ftType="datetime" ftValidation="required"
		fthint="Start date/time for the task.">

	<cfproperty name="endDate" type="date" required="true" default=""
		ftSeq="8" ftFieldset="Task Schedule" ftLabel="End Date"
		ftType="datetime" ftValidation="required"
		fthint="End date/time for the task.">

	<cfproperty name="timeOut" type="integer" required="no" default="60" 
		ftSeq="9" ftFieldset="Task Schedule" ftLabel="Timeout"
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

	<cfif structKeyExists(arguments, "objectid")>
		<cfset arguments.stobject = getData(objectid=arguments.objectid)>	
	</cfif>
	
	<cfif structIsEmpty(stobject)>
		<cfthrow type="Application" message="Argument *stobject* is empty.">
	</cfif>

	<cfschedule 
		action="UPDATE" 
		task = "#application.applicationName#: #stobject.title#"
		operation = "HTTPRequest"
		url = "http://#cgi.HTTP_HOST##application.url.conjurer#?objectid=#stobject.objectid#&#stobject.parameters#"
		interval = "#stobject.frequency#"
		startdate = "#dateFormat(stobject.startDate,'dd/mmm/yyyy')#"
		starttime = "#timeFormat(stobject.startDate,'hh:mm tt')#"
		enddate = "#dateFormat(stobject.endDate,'dd/mmm/yyyy')#"
		requesttimeout = "#stobject.timeout#">

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
	<cfset stAttributes.returnvariable = "qJobs">

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
	
	<cfset var stExistingObj	= '' />
	
	<cfif not arguments.bSessionOnly and structKeyExists(arguments.stProperties,"title")>
		<!--- check if task has been renamed --->
		<cfset stExistingObj = getData(arguments.stProperties.objectid)>	
		<cfif stExistingObj.title neq arguments.stProperties.title>
			<cftry>
				<!--- delete old task --->
				<cfschedule	action="Delete"	task = "#application.applicationName#_#stExistingObj.title#">
				<cfcatch></cfcatch>
			</cftry>
		</cfif>
		
		<!--- add/update task --->
		<cfset addJob(stobject=arguments.stProperties)>
	</cfif>	
	
	<!--- update object --->
	<cfreturn super.setData(arguments.stProperties,arguments.user,arguments.auditNote,arguments.bAudit,arguments.dsn,arguments.bSessionOnly,arguments.bAfterSave) />
</cffunction>


<!--- 
 // private functions 
--------------------------------------------------------------------------------->
<cffunction name="listTemplates" access="private" output="false" returntype="query" hint="Returns a query of available core and custom task methods.">
	
	<cfset var qTemplates	= queryNew("displayName, path") />
	<cfset var plugin	= '' />
	<cfset var qCore	= '' />
	<cfset var qCustom	= '' />

	<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">

	<!--- get core templates --->	
	<nj:listTemplates typename="dmCron" path="#application.path.core#/webtop/scheduledTasks" prefix="" r_qMethods="qCore">
	
	<cfloop query="qCore">
		<cfset queryAddRow(qTemplates, 1)>
		<cfset querySetCell(qTemplates, "displayname", "#displayname# #application.rb.getResource('coapi.dmCron.tasktype.core@label','Core')#")>
		<cfset querySetCell(qTemplates, "path", "/farcry/core/webtop/scheduledTasks/#methodName#.cfm")>
	</cfloop>
	
	<!--- get custom templates --->	
	<cftry>
		<cfloop list="#application.plugins#" index="plugin">
			<nj:listTemplates typename="dmCron" path="#application.path.plugins#/#plugin#/system/dmCron" prefix="" r_qMethods="qCustom">
			<cfloop query="qCustom">
				<!--- ignore cvs file --->
				<cfif methodName neq "_donotdelete">
					<cfset queryAddRow(qTemplates, 1)>
					<cfset querySetCell(qTemplates, "displayname", "#displayname# (#plugin# plugin)")>
					<cfset querySetCell(qTemplates, "path", "/farcry/plugins/#plugin#/system/dmCron/#methodName#.cfm")>
				</cfif>
			</cfloop>
		</cfloop>
		
		<nj:listTemplates typename="dmCron" path="#application.path.project#/system/dmCron" prefix="" r_qMethods="qCustom">
		<cfloop query="qCustom">
			<!--- ignore cvs file --->
			<cfif methodName neq "_donotdelete">
				<cfset queryAddRow(qTemplates, 1)>
				<cfset querySetCell(qTemplates, "displayname", "#displayname# #application.rb.getResource('coapi.dmCron.tasktype.custom@label','Custom')#")>
				<cfset querySetCell(qTemplates, "path", "/farcry/projects/#application.projectDirectoryName#/system/dmCron/#methodName#.cfm")>
			</cfif>
		</cfloop>
		<cfcatch></cfcatch>
	</cftry>	
	
	<cfreturn qTemplates>
</cffunction>


</cfcomponent>