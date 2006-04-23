<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/types.cfc,v 1.33.2.1 2005/05/06 01:01:48 guy Exp $
$Author: guy $
$Date: 2005/05/06 01:01:48 $
$Name: milestone_2-1-2 $
$Revision: 1.33.2.1 $

|| DESCRIPTION || 
$Description: Component Types Abstract class for contenttypes package.  This class defines default handlers and system attributes.$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent extends="farcry.fourq.fourq" bAbstract="true" displayname="Base Content Type" hint="Abstract class. Provides default handlers and system attributes for content object types.  This component should never be instantiated directly -- it should only be inherited.">

<!--------------------------------------------------------------------
system attributes
  properties that all content types require in FarCry
--------------------------------------------------------------------->	
<cfproperty name="ObjectID" type="UUID" hint="Primary key." required="yes">
<cfproperty name="label" type="nstring" hint="Object label or title." required="no" default=""> 
<cfproperty name="datetimecreated" type="date" hint="Timestamp for record creation." required="yes" default=""> 
<cfproperty name="createdby" type="nstring" hint="Username for creator." required="yes" default=""> 
<cfproperty name="datetimelastupdated" type="date" hint="Timestamp for record last modified." required="yes" default=""> 
<cfproperty name="lastupdatedby" type="nstring" hint="Username for modifier." required="yes" default="">
<cfproperty name="lockedBy" type="nstring" hint="Username for locker." required="no" default="">
<cfproperty name="locked" type="boolean" hint="Flag for object locking." required="yes" default="0">

<!--------------------------------------------------------------------
default handlers
  handlers that all types require
  these will likely be overloaded in production
--------------------------------------------------------------------->	
	<cffunction name="getDisplay" access="public" output="Yes">
		<cfargument name="objectid" required="yes" type="UUID">
		<cfargument name="template" required="yes" type="string">
		<cfargument name="dsn" required="no" type="string" default="#application.dsn#">
		<!--- get the data for this instance --->
		<cfset stObj = getData(objectid=arguments.objectID,dsn=arguments.dsn)>		
		<cfif NOT structIsEmpty(stObj)> 
			<cftry>
				<cfinclude template="/farcry/#application.applicationname#/#application.path.handler#/#stObj.typename#/#arguments.template#.cfm">
				<cfcatch>
					<!--- check to see if the displayMethod template exists --->
					<cfif NOT fileExists("#application.path.webskin#/#stObj.typename#/#arguments.template#.cfm")>
						 <cfabort showerror="Error: Template not found [#application.path.webskin#/#stObj.typename#/#arguments.template#.cfm]."> 
					<cfelse>
						<cfif isdefined("url.debug")><cfset request.cfdumpinited = false><cfdump var="#cfcatch#"></cfif>
					</cfif>
				</cfcatch>
			</cftry>
		</cfif>
	</cffunction>

	<cffunction name="display" access="public" returntype="any" output="Yes">
		<cfargument name="objectid" required="yes" type="UUID">
		<cfoutput><p>This is the default output of <strong>types.Display()</strong>:</p></cfoutput>
		<cfset myObject = getData(arguments[1])>
		<cfdump var="#myObject#">
	</cffunction>
	
	<cffunction name="createData" access="public" returntype="any" output="false" hint="Creates an instance of an object">
		<cfargument name="stProperties" type="struct" required="true" hint="Structure of properties for the new object instance">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="#session.dmSec.authentication.userlogin#">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Created">
		
		<cfscript>
			if(NOT structKeyExists(arguments.stProperties,"objectid"))
				arguments.stProperties.objectid = createUUID();
			if(NOT structKeyExists(arguments.stProperties,"datetimecreated"))
				arguments.stProperties.datetimecreated = createODBCDateTime(now());	
			if(NOT structKeyExists(arguments.stProperties,"datetimelastupdated"))
				arguments.stProperties.datetimelastupdated = createODBCDateTime(now());		
			if(NOT structKeyExists(arguments.stProperties,"locked"))
				arguments.stProperties.locked = 0;			
			if(NOT structKeyExists(arguments.stProperties,"lockedby"))
				arguments.stProperties.lockedby = '';
			if(NOT structKeyExists(arguments.stProperties,"createdby"))
				arguments.stProperties.createdby = arguments.user;		
			if(NOT structKeyExists(arguments.stProperties,"lastupdatedby"))
				arguments.stProperties.lastupdatedby = arguments.user;	
				
			stNewObject = super.createData(arguments.stProperties);
			application.factory.oAudit.logActivity(auditType="Create", username=arguments.user, location=cgi.remote_host, note=arguments.auditNote,objectid=stNewObject.objectid);
		</cfscript>
		
		<cfreturn stNewObject>
	</cffunction>
	
	<cffunction name="setData" access="public" output="false" hint="Update the record for an objectID including array properties.  Pass in a structure of property values; arrays should be passed as an array.">
		<cfargument name="stProperties" required="true">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="#session.dmSec.authentication.userlogin#">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Updated">
		<cfargument name="bAudit" type="boolean" required="No" default="1" hint="Pass in 0 if you wish no audit to take place">
		<cfargument name="dsn" required="No" default="#application.dsn#"> 
		
		<cfscript>
			//fill in the gaps in case user has forgotten any core properties
			if(NOT structKeyExists(arguments.stProperties,"datetimelastupdated"))
				arguments.stProperties.datetimelastupdated = createODBCDateTime(now());		
			if(NOT structKeyExists(arguments.stProperties,"locked"))
				arguments.stProperties.locked = 0;			
			if(NOT structKeyExists(arguments.stProperties,"lockedby"))
				arguments.stProperties.lockedby = '';
			if(NOT structKeyExists(arguments.stProperties,"lastupdatedby"))
				arguments.stProperties.lastupdatedby = arguments.user;	
		</cfscript>				
		
		
		<cfset super.setData(arguments.stProperties,arguments.dsn)>
		
		<!--- log update --->
		<cfif arguments.bAudit>
			<cfset application.factory.oAudit.logActivity(auditType="Update", username=arguments.user, location=cgi.remote_host, note=arguments.auditNote,objectid=arguments.stProperties.objectid,dsn=arguments.dsn)>	
		</cfif>
	</cffunction>
	
	<cffunction name="edit" access="public" output="false" returntype="struct">
		<!--- 
		Properties code not quite running yet... (driver -> Spike)
		GB 20020518
		<cfinclude template="_types/edit.cfm"> 
		--->
		<cfthrow message="This is the default types.edit() handler.  You need to build an edit interface!">
		<cfset stReturn = structNew()>
		<cfreturn stReturn>
	</cffunction>
	
	<cffunction name="delete" access="public" hint="Basic delete method for all objects.">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="#session.dmSec.authentication.userlogin#">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Deleted">
		<!--- get the data for this instance --->
		<cfset stObj = getData(arguments.objectID)>		
		<cfinclude template="_types/delete.cfm">
		<cfset application.factory.oAudit.logActivity(auditType="Delete", username=arguments.user, location=cgi.remote_host, note=arguments.auditNote,objectid=arguments.objectid)>	
	</cffunction>	
	
	<cffunction name="renderObjectOverview" access="public" hint="Renders entire object overiew" output="false">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the selected object">
		<cfset var html = ''>
		<!--- get object details --->
		<cfset stObj = getData(arguments.objectid)>
		<!--- default status for objects that don't require status --->
		<cfparam name="stobj.status" default="approved">
		
		<cfinclude template="_types/renderObjectOverview.cfm">
		
		<cfreturn html>
	</cffunction>
	
	
	<cffunction name="renderOverview" access="public" hint="Renders options available on the overview page" output="false">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the selected object">
		<!--- get object details --->
		<cfset stObj = getData(arguments.objectid)>
		
		<cfinclude template="_types/renderOverview.cfm">
		
		<cfreturn html>
	</cffunction>
</cfcomponent>

