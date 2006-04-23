<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/dmCron.cfc,v 1.6 2005/08/10 01:18:55 guy Exp $
$Author: guy $
$Date: 2005/08/10 01:18:55 $
$Name: milestone_3-0-0 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: dmCron Type (scheduled tasks) $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

--->
<cfcomponent extends="types" displayname="Scheduled Tasks" hint="Scheduled tasks to maintain a FarCry site" bSchedule="0">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty name="title" type="nstring" hint="Title of the feed" required="no" default="">
<cfproperty name="description" type="longchar" hint="Description of the feed" required="no" default="">
<cfproperty name="template" type="string" hint="Url of file to be scheduled" required="no" default="">
<cfproperty name="parameters" type="string" hint="Url parameters for file" required="no" default="">
<cfproperty name="frequency" type="string" hint="How often task is run" required="no" default="daily">
<cfproperty name="startDate" type="date" hint="Start date for task" required="no" default="">
<cfproperty name="endDate" type="date" hint="End date for task" required="no" default="">
<cfproperty name="timeOut" type="numeric" hint="time out period" required="no" default="60">


<!------------------------------------------------------------------------
object methods 
------------------------------------------------------------------------->	
<cffunction name="edit" access="public" output="true" hint="edit handler for dmCron objects">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = getData(arguments.objectid)>
	<cfinclude template="_dmCron/edit.cfm">
</cffunction>

<cffunction name="display" access="public" output="true" hint="runs the scheduled task">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = getData(arguments.objectid)>
	
	<!--- include scheduled task code and pass in parameters --->
	<cfinclude template="#stObj.template#">
</cffunction>

<cffunction name="listTemplates" access="public" output="true" returnType="query" hint="Lists available scheduled tasks, both core and custom">
	
	<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">

	<cfset qTemplates = queryNew("displayName, path")>
		
	<!--- get core templates --->	
	<nj:listTemplates typename="dmCron" path="#application.path.core#/admin/scheduledTasks" prefix="" r_qMethods="qCore">
	
	<cfloop query="qCore">
		<cfset queryAddRow(qTemplates, 1)>
		<cfset querySetCell(qTemplates, "displayname", "#displayname# #application.adminBundle[session.dmProfile.locale].core#")>
		<cfset querySetCell(qTemplates, "path", "/farcry/farcry_core/admin/scheduledTasks/#methodName#.cfm")>
	</cfloop>
	
	<!--- get custom templates --->	
	<cftry>
		<nj:listTemplates typename="dmCron" path="#application.path.project#/system/dmCron" prefix="" r_qMethods="qCustom">
		<cfloop query="qCustom">
			<!--- ignore cvs file --->
			<cfif methodName neq "_donotdelete">
				<cfset queryAddRow(qTemplates, 1)>
				<cfset querySetCell(qTemplates, "displayname", "#displayname# #application.adminBundle[session.dmProfile.locale].custom#")>
				<cfset querySetCell(qTemplates, "path", "/farcry/#application.applicationName#/system/dmCron/#methodName#.cfm")>
			</cfif>
		</cfloop>
		<cfcatch></cfcatch>
	</cftry>	
	
	<cfreturn qTemplates>
</cffunction>

<cffunction name="delete" access="public" output="false" hint="Deletes the scheduled task and actual dmCron object" returntype="struct">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object deletion --->
	<cfset var stObj = getData(arguments.objectid)>
	<cfset var stReturn = StructNew()>
	<cfset stReturn.bSuccess = 1>
	<cfset stReturn.message = "">
	
	<!--- delete scheduled task --->
	<cfschedule	action="Delete"	task = "#application.applicationName#_#stObj.title#">
	
	<!--- delete dmCron object --->
	<cfset super.delete(stObj.objectId)>

	<cfreturn stReturn>
</cffunction>

<cffunction name="setData" access="public" output="true" hint="Creates a scheduled task and actual dmCron object">
	<cfargument name="stProperties" required="true">
	
	<cfif structKeyExists(arguments.stProperties,"title")>
		
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
			startDate = "#dateFormat(arguments.stProperties.startDate,'dd/mmm/yyyy')#"
			startTime = "#timeFormat(arguments.stProperties.startDate,'hh:mm tt')#"
			endDate = "#dateFormat(arguments.stProperties.endDate,'dd/mmm/yyyy')#"
			requestTimeOut = "#arguments.stProperties.timeout#">
	</cfif>	
	
	<!--- update object --->
	<cfset super.setData(arguments.stProperties)>
	
</cffunction>

</cfcomponent>

