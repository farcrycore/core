<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| DESCRIPTION || 
$Description: dmCron Type (scheduled tasks) $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfcomponent extends="types" displayname="Scheduled Tasks" hint="Scheduled tasks to maintain a FarCry site" bschedule="0" bsystem="true">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty ftseq="1" ftfieldset="General Details" name="title" ftlabel="Title" type="nstring" hint="Title of the feed" required="no" default="">
<cfproperty ftseq="2" ftfieldset="General Details" name="description" ftlabel="Description" type="longchar" hint="Description of the feed" required="no" default="">
<cfproperty ftseq="3" ftfieldset="General Details" name="template" ftlabel="Template" type="string" hint="Url of file to be scheduled" required="no" default="" fttype="list" ftlistdata="getTemplateList">

<cfproperty ftseq="21" ftfieldset="Settings" name="parameters" type="string" hint="Url parameters for file" required="no" default="">
<cfproperty ftseq="22" ftfieldset="Settings" name="frequency" type="string" hint="How often task is run" required="no" default="daily" fttype="list" ftlist="Once:Run once,Daily:Every day,Weekly:Every week,Monthly:Every month,3600:Every hour,1800:Every half-hour,900:Every 15. minute,60:Every minute">
<cfproperty ftseq="23" ftfieldset="Settings" name="startDate" fttype="datetime" type="date" hint="Start date for task" required="no" ftDefault="now()" ftDefaultType="evaluate">
<cfproperty ftseq="24" ftfieldset="Settings" name="endDate" fttype="datetime" type="date" hint="End date for task" required="no">
<cfproperty ftseq="25" ftfieldset="Settings" name="timeOut" type="numeric" hint="time out period" required="no" default="60" fttype="int">


<!------------------------------------------------------------------------
object methods 
------------------------------------------------------------------------->	
<cffunction name="display" access="public" output="true" hint="runs the scheduled task">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = getData(arguments.objectid)>
	
	<!--- include scheduled task code and pass in parameters --->
	<cfinclude template="#stObj.template#">
</cffunction>

<cffunction name="listTemplates" access="public" output="true" returntype="query" hint="Lists available scheduled tasks, both core and custom">
	
	<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">

	<cfset qTemplates = queryNew("displayName, path")>
		
	<!--- get core templates --->	
	<nj:listTemplates typename="dmCron" path="#application.path.core#/admin/scheduledTasks" prefix="" r_qMethods="qCore">
	
	<cfloop query="qCore">
		<cfset queryAddRow(qTemplates, 1)>
		<cfset querySetCell(qTemplates, "displayname", "#displayname# #application.adminBundle[session.dmProfile.locale].core#")>
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
				<cfset querySetCell(qTemplates, "displayname", "#displayname# #application.adminBundle[session.dmProfile.locale].custom#")>
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
			startdate = "#dateFormat(arguments.stProperties.startDate,'dd/mmm/yyyy')#"
			starttime = "#timeFormat(arguments.stProperties.startDate,'hh:mm tt')#"
			enddate = "#dateFormat(arguments.stProperties.endDate,'dd/mmm/yyyy')#"
			requesttimeout = "#arguments.stProperties.timeout#">
	</cfif>	
	
	<!--- update object --->
	<cfset super.setData(arguments.stProperties)>
	
</cffunction>

</cfcomponent>