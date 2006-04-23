<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/types.cfc,v 1.46.2.1 2005/06/07 02:58:44 guy Exp $
$Author: guy $
$Date: 2005/06/07 02:58:44 $
$Name: milestone_2-3-2 $
$Revision: 1.46.2.1 $

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
		<cfset var stObj = getData(objectid=arguments.objectID,dsn=arguments.dsn)>		
		<cfif NOT structIsEmpty(stObj)> 
			<cftry>
				<cfinclude template="/farcry/#application.applicationname#/#application.path.handler#/#stObj.typename#/#arguments.template#.cfm">
				<cfcatch>
					<!--- check to see if the displayMethod template exists --->
					<cfif NOT fileExists("#application.path.webskin#/#stObj.typename#/#arguments.template#.cfm")>
						 <cfabort showerror="Error: Template not found [#application.path.webskin#/#stObj.typename#/#arguments.template#.cfm]."> 
					<cfelse>
						<cfif isdefined("url.debug")><cfset request.cfdumpinited = false><cfoutput>#cfcatch.message#<br />#cfcatch.detail#</cfoutput><cfdump var="#cfcatch#"></cfif>
					</cfif>
				</cfcatch>
			</cftry>
		</cfif>
	</cffunction>

	<cffunction name="display" access="public" returntype="any" output="Yes">
		<cfargument name="objectid" required="yes" type="UUID">
		<cfset var myObject = getData(arguments[1])>
		<cfoutput><p>This is the default output of <strong>types.Display()</strong>:</p></cfoutput>
		<cfdump var="#myObject#">
	</cffunction>
	
	<cffunction name="createData" access="public" returntype="any" output="false" hint="Creates an instance of an object">
		<cfargument name="stProperties" type="struct" required="true" hint="Structure of properties for the new object instance">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="#session.dmSec.authentication.userlogin#">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="Created">
		<cfargument name="dsn" required="No" default="#application.dsn#"> 
		
		<cfscript>
			var stNewObject = "";
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
				
			stNewObject = super.createData(arguments.stProperties,arguments.stProperties.objectid,arguments.dsn);
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
		
		<cfset var stResult=structnew()>
		
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
			if(NOT structKeyExists(arguments.stProperties,"filesize"))
				arguments.stProperties.filesize = 0;
		</cfscript>
				
		<cfset stresult=super.setData(arguments.stProperties,arguments.dsn)>
		
		<!--- log update --->
		<cfif arguments.bAudit>
			<cfset application.factory.oAudit.logActivity(auditType="Update", username=arguments.user, location=cgi.remote_host, note=arguments.auditNote,objectid=arguments.stProperties.objectid,dsn=arguments.dsn)>	
		</cfif>
		<cfreturn stresult>
	</cffunction>
	
	<cffunction name="edit" access="public" displayname="Edit handler." hint="Default edit method for objects. Self posting form dynamically generated from the type metadata.  Calls farcry.locking for update.  Override as required." output="true">
		<cfargument name="objectid" required="yes" type="UUID">
		<!--- getData for object edit --->
		<cfset var stObj=getData(arguments.objectid)>
		<cfset var stProps=application.types[stobj.typename].stprops>
		<cfset var displayname=application.types[stobj.typename].displayname>
		<cfset var hint=application.types[stobj.typename].hint>
	
		<cfsetting enablecfoutputonly="Yes">
	
		<!--- update object with changes --->
		<cfif isDefined("form.update")>
			<cfscript>
				stoutput=structNew();
				stoutput=form;
				stoutput.typename=stobj.typename;
				if (isDefined("stoutput.title")) {
					stoutput.label=stoutput.title; // match label with title
				} else {
					stoutput.label=displayname & ": " & dateFormat(now(), "dd-mmm-yy") & timeFormat(now(), "HH:mm");
				}
			</cfscript>
			<!--- unlock object and save object --->
			<cfinvoke component="#application.packagepath#.farcry.locking" method="unlock" returnvariable="stresult">
				<cfinvokeargument name="stObj" value="#stOutput#"/>
				<cfinvokeargument name="objectid" value="#stOutput.objectid#"/>
				<cfinvokeargument name="typename" value="#stOutput.typename#"/>
			</cfinvoke>
			
			<!--- all done in one window so relocate back to main page --->
			<!--- <cflocation url="#application.url.farcry#/admin/customadmin.cfm?module=accounts/listprojects.cfm" addtoken="no"> --->
			<cfoutput><h3>Object updated!</h3></cfoutput>
			<cfdump var="#stresult#">
		<cfelse>
			<!--- render update form for object --->
			<cfoutput>
			<h3>#stobj.label#</h3>
			<p>#displayname#: #hint#</p>
			
			<form name="edit" action="#CGI.SCRIPT_NAME#?#query_string#" method="post" class="form-columns">
			<input type="hidden" name="update" value="true">
			<input type="hidden" name="objectid" value="#stobj.objectid#">
					
			<cfloop collection="#stprops#" item="prop">
			<cfset sttmp=stprops[prop]>
			<cfif stprops[prop].origin neq "farcry.farcry_core.packages.types.types" AND NOT isarray(stobj[prop])>
			<!--- #stprops[prop].origin# --->
			<!--- <cfdump var="#stprops[prop]#"> --->
			<DIV class="label"><LABEL for="#prop#"><cfif isDefined("sttmp.metadata.displayname") AND len(sttmp.metadata.displayname)>#stprops[prop].metadata.displayname#<cfelse>#prop#</cfif><cfif isDefined("sttmp.metadata.required") AND sttmp.metadata.required><SPAN class="required">*</SPAN></cfif></LABEL></DIV>
			
			<cfswitch expression="#stprops[prop].metadata.type#">
			<cfcase value="nstring,string">
			<DIV class="field"><INPUT type="text" class="textfield wide" name="#prop#" id="#prop#" value="#stobj[prop]#" maxlength="255" tabindex="110" /></DIV>
			<BR class="clear-both"/>
			</cfcase>
	
			<cfcase value="longchar">
			<DIV class="field"><TEXTAREA name="#prop#" id="#prop#" cols="45" rows="10" wrap="VIRTUAL" maxlength="2000" class="wide" tabindex="120">#stobj[prop]#</TEXTAREA></DIV>
			<BR class="clear-both"/>
			</cfcase>
			
			<cfdefaultcase>
			<DIV class="field"><INPUT type="text" class="textfield wide" name="#prop#" id="#prop#" value="#stobj[prop]#" maxlength="255" tabindex="110" /></DIV>
			<BR class="clear-both"/>
			</cfdefaultcase>
			</cfswitch>
			</cfif>
			</cfloop> 
			
			<P class="nav-right"><INPUT type="submit" name="Submit" value="Submit" class="submit" tabindex="190" /></P>
			</FORM>
			
			<p>#stobj.typename#: #stobj.objectid#</p>
			<!--- debugging output --->
			<!--- reset dump variable in request scope 
			<cfset request.cfdumpinited = false>
			<cfdump var="#stprops#" expand="no" label="Complete Type Metadata.stprops">
			<cfdump var="#stobj#" expand="no" label="Complete stObj">
			--->
			</cfoutput>
		</cfif>
		
		<cfsetting enablecfoutputonly="No">
			
	</cffunction>
	
	<cffunction name="delete" access="public" hint="Basic delete method for all objects.">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
		<cfargument name="user" type="string" required="true" hint="Username for object creator" default="#session.dmSec.authentication.userlogin#">
		<cfargument name="auditNote" type="string" required="true" hint="Note for audit trail" default="">
		
		<!--- get the data for this instance --->
		<cfset var stObj = getData(arguments.objectID)>		
		<cfset var lTypesWithContainers = "">
		<cfset var oCon = "">
		<cfset var i = "">
		<cfset var objType = "">
		<cfset var oType = "">
		<cfset var oConfig = "">
		<cfset var stCollections = "">
		<cfset var collectionName = "">
		<cfif not len(arguments.auditNote)>
			<cfset arguments.auditNote = "#stObj.label# (#stObj.typename#) deleted">
		</cfif>

		<cfinclude template="_types/delete.cfm">
		<cfset application.factory.oAudit.logActivity(auditType="Delete", username=arguments.user, location=cgi.remote_host, note=arguments.auditNote,objectid=arguments.objectid)>	
	</cffunction>	
	
	<cffunction name="renderObjectOverview" access="public" hint="Renders entire object overiew" output="false">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the selected object">
			
		<!--- get object details --->
		<cfset var stObj = getData(arguments.objectid)>
		<cfset var html = ''>
		
		<cfinclude template="_types/renderObjectOverview.cfm">
		
		<cfreturn html>
	</cffunction>

	
	<cffunction name="renderOverview" access="public" hint="Renders options available on the overview page" output="false">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the selected object">
		<!--- get object details --->
		<cfset var stObj = getData(arguments.objectid)>
		<cfset var overviewHtml = ''>
		
		<cfinclude template="_types/renderOverview.cfm">
		
		<cfreturn overviewHtml>
	</cffunction>
	
	<cffunction name="archiveObject" access="public" returntype="struct" hint="Archives any farcry object">
		<cfargument name="objectID" type="uuid" required="true">
		<cfargument name="typename" type="string" required="false">
			
 		<cfset var stResult = application.factory.oVersioning.archiveObject(objectid=arguments.objectid,typename=arguments.typename)>
		
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="archiveRollback" access="public" returntype="struct" hint="Sends a archived object live and archives current version">
		<cfargument name="objectID" type="uuid" required="true">
		<cfargument name="archiveID"  type="uuid" required="true" hint="the archived object to be sent back live">
		<cfargument name="typename" type="string" default="" required="false">
		
 		<cfset var stResult = application.factory.oVersioning.rollbackArchive(objectid=arguments.objectid,typename=arguments.typename,archiveID=arguments.archiveID)>
		
		<cfreturn stResult>
	</cffunction>
</cfcomponent>

