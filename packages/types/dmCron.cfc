<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
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
|| DESCRIPTION || 
$Description: dmCron Type (scheduled tasks) $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfcomponent extends="types" displayname="Scheduled Tasks" hint="Scheduled tasks can be created to run periodic maintenance tasks unattended. Select from a list of available tasks and schedule when they should run." bsystem="true">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty ftseq="1" ftfieldset="General Details" name="title" ftlabel="Title" type="nstring" hint="Title of the feed" required="no" default="">
<cfproperty ftseq="2" ftfieldset="General Details" name="description" ftlabel="Description" type="longchar" hint="Description of the feed" required="no" default="">
<cfproperty ftseq="3" ftfieldset="General Details" name="template" ftlabel="Template" type="string" hint="Url of file to be scheduled" required="no" default="" fttype="list" ftlistdata="getTemplateList">

<cfproperty ftseq="21" ftfieldset="Settings" name="parameters" type="string" hint="Url parameters for file" required="no" default="">
<cfproperty ftseq="22" ftfieldset="Settings" name="frequency" type="string" hint="How often task is run" required="no" default="daily" fttype="list" ftlist="Once:Run once,Daily:Every day,Weekly:Every week,Monthly:Every month,3600:Every hour,1800:Every half-hour,900:Every 15. minute,60:Every minute">
<cfproperty ftseq="23" ftfieldset="Settings" name="startDate" fttype="datetime" type="date" hint="Start date for task" required="no" default="">
<cfproperty ftseq="24" ftfieldset="Settings" name="endDate" fttype="datetime" type="date" hint="End date for task" required="no" default="">
<cfproperty ftseq="25" ftfieldset="Settings" name="timeOut" type="numeric" hint="time out period" required="no" default="60" fttype="int">


<!------------------------------------------------------------------------
object methods 
------------------------------------------------------------------------->	
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

<cffunction name="listTemplates" access="public" output="true" returntype="query" hint="Lists available scheduled tasks, both core and custom">
	
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


<cffunction name="getTemplateList" returntype="string" output="false" hint="returns a list (column name 'tmeplate') of available templates.">
	<cfset var lTemplates = "">
	<cfset var qListTemplates = listTemplates()>
	<cfloop query="qListTemplates">
		<cfset lTemplates = listAppend(lTemplates,"#qListTemplates.path#:#qListTemplates.displayname#")>
	</cfloop>
	<cfreturn lTemplates>
</cffunction>

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
		<cfschedule 
			action="UPDATE" 
			task = "#application.applicationName#_#arguments.stProperties.title#"
			operation = "HTTPRequest"
			url = "http://#cgi.HTTP_HOST##application.url.conjurer#?objectid=#arguments.stProperties.objectid#&#arguments.stProperties.parameters#"
			interval = "#arguments.stProperties.frequency#"
			startdate = "#dateFormat(arguments.stProperties.startDate,'dd/mmm/yyyy')#"
			starttime = "#timeFormat(arguments.stProperties.startDate,'hh:mm tt')#"
			enddate = "#dateFormat(arguments.stProperties.endDate,'dd/mmm/yyyy')#"
			requesttimeout = "#arguments.stProperties.timeout#">
	</cfif>	
	
	<!--- update object --->
	<cfreturn super.setData(arguments.stProperties,arguments.user,arguments.auditNote,arguments.bAudit,arguments.dsn,arguments.bSessionOnly,arguments.bAfterSave) />
</cffunction>

</cfcomponent>