<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/types.cfc,v 1.68 2005/10/11 15:48:10 tom Exp $
$Author: tom $
$Date: 2005/10/11 15:48:10 $
$Name: milestone_3-0-0 $
$Revision: 1.68 $

|| DESCRIPTION || 
$Description: Component Types Abstract class for contenttypes package.  
This class defines default handlers and system attributes.$

|| DEVELOPER ||
$Developer: Geoff Bowers (geoff@daemon.com.au) $
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
<cfproperty name="ownedby" type="nstring" hint="Username for owner." required="yes" default="">
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
		
		<cfset var stResult = StructNew()>
		<cfset var stresult_friendly = StructNew()>

		<cfscript>
			// TODO should prepopulate with values set in cfproperty
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
				
		<cfset stresult = super.setData(arguments.stProperties,arguments.dsn)>
		<cfif Application.config.plugins.FU AND StructKeyExists(arguments.stProperties,"label") AND Trim(arguments.stProperties.label) NEQ "" AND arguments.stProperties.label NEQ "incomplete">
			<cfset stresult_friendly = setFriendlyURL(arguments.stProperties)>
		</cfif>
		<!--- log update --->
		<cfif arguments.bAudit>
			<cfset application.factory.oAudit.logActivity(auditType="Update", username=arguments.user, location=cgi.remote_host, note=arguments.auditNote,objectid=arguments.stProperties.objectid,dsn=arguments.dsn)>	
		</cfif>
		<cfreturn stresult>
	</cffunction>
	
	<cffunction name="setLock" access="public" output="false" hint="Lock a content item to prevent simultaneous editing." returntype="void">
		<cfargument name="locked" type="boolean" required="true" hint="Turn the lock on or off.">
		<cfargument name="lockedby" type="string" required="false" hint="Name of the user locking the object." default="#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#">
		<cfargument name="bAudit" type="boolean" required="No" default="1" hint="Pass in 0 if you wish no audit to take place">
		<cfargument name="dsn" required="No" default="#application.dsn#"> 
		<cfargument name="stobj" required="No" default="#StructNew()#"> 
				
		<!--- if the properties struct not passed in grab the instance --->
		<cfif StructIsEmpty(arguments.stObj)>
			<cfset instance.stobj.locked=arguments.locked>
			<cfif arguments.locked>
				<cfset instance.stobj.lockedby=arguments.lockedby>
			<cfelse>
				<cfset instance.stobj.lockedby="">
			</cfif>
			<!--- call fourq.setdata() (ie super) to bypass prepop of sys attributes by types.setdata() --->
			<cfset setdata(instance.stobj, arguments.lockedby, 0)>
		<cfelse>
			<cfset arguments.stobj.locked = arguments.locked>
			<cfif arguments.locked>
				<cfset arguments.stobj.lockedby=arguments.lockedby>
			<cfelse>
				<cfset arguments.stobj.lockedby="">
			</cfif>
		</cfif>

		<!--- log event --->
		<cfif arguments.bAudit>
			<cfset application.factory.oAudit.logActivity(auditType="Lock", username=arguments.lockedby, location=cgi.remote_host, note="Locked: #yesnoformat(arguments.locked)#",objectid=instance.stobj.objectid,dsn=arguments.dsn)>
		</cfif>
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
	
	<cffunction name="delete" access="public" hint="Basic delete method for all objects. Deletes content item and removes Verity entries." returntype="struct" output="false">
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
		<cfset var stlocal = StructNew()>
		<cfset var stReturn = StructNew()>
		
		<cfif structisempty(stobj)>
			<cfset stReturn.bSuccess = false>
			<cfset stReturn.message = "Content item (#arguments.objectid#) does not exsit.">
			<cfreturn stReturn>
		</cfif>

		<!--- done first cause need to remove associtaion to library object --->
		<cfinclude template="_types/delete.cfm">

		<!--- check if need to archive object --->
		<cfif application.config.general.bDoArchive EQ "true">
			<cfset stLocal.archiveObject = createobject("component",application.types.dmArchive.typepath)>
			<cfset stLocal.returnVar = stLocal.archiveObject.fArchiveObject(stObj)>
		</cfif>

		<!--- write audit trail --->
		<cfif not len(arguments.auditNote)>
			<cfset arguments.auditNote = "#stObj.label# (#stObj.typename#) deleted.">
		</cfif>
		<cfset application.factory.oAudit.logActivity(auditType="Delete", username=arguments.user, location=cgi.remote_host, note=arguments.auditNote,objectid=arguments.objectid)>	

		<cfset stReturn.bSuccess = true>
		<cfset stReturn.message = "#stObj.label# (#stObj.typename#) deleted.">
		<cfreturn stReturn>
	</cffunction>
	

	<cffunction name="renderObjectOverview" access="public" hint="Renders entire object overiew" output="true">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the selected object">
			
		<!--- get object details --->
		<cfset var stObj = getData(arguments.objectid)>
		<cfset var stLocal = StructNew()>
		<cfset stLocal.html = "">		
		<cfinclude template="_types/renderObjectOverview.cfm">
		<cfreturn stLocal.html>

	</cffunction>
		
	<cffunction name="fDisplayObjectOverview" returntype="string" output="true">
		<cfargument name="stObject" required="true" type="struct">
		<cfargument name="stPermissions" required="true" type="struct">
	
		<cfset stObject = arguments.stObject>
		<cfset stPermissions = arguments.stPermissions>
		<cfset displayContent = "">
		<cfinclude template="_types/_fDisplayObjectOverview.cfm">
		<cfreturn displayContent>
	</cffunction>


	<!--- <cffunction name="renderOverview" access="public" hint="Renders options available on the overview page" output="false">
		<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the selected object">
		<!--- get object details --->
		<cfset var stObj = getData(arguments.objectid)>
		<cfset var overviewHtml = ''>
		
		<cfinclude template="_types/renderOverview.cfm">
		
		<cfreturn overviewHtml>
	</cffunction> --->
	
	<cffunction name="archiveObject" access="public" returntype="struct" hint="Archives any farcry object">
		<!--- TODO: move out of this abstract class to proposed version abstract class 20050802 GB --->
		<cfargument name="objectID" type="uuid" required="true">
		<cfargument name="typename" type="string" required="false">

		<cfset var stLocal = StructNew()> <!--- local struct to hold all local values --->			
		<cfset var stObj = getData(arguments.objectID)>
 		<!--- <cfset var stResult = application.factory.oVersioning.archiveObject(objectid=arguments.objectid,typename=arguments.typename)> --->

		<cfset stLocal.objArchive = CreateObject("component","#application.packagepath#.types.dmArchive")>
		<cfset stLocal.returnStruct = stLocal.objArchive.fArchiveObject(stObj)>

		<cfreturn stLocal.returnStruct>
	</cffunction>
	
	<cffunction name="archiveRollback" access="public" returntype="struct" hint="Sends a archived object live and archives current version">
		<!--- TODO: move out of this abstract class to proposed version abstract class 20050802 GB --->
		<cfargument name="objectID" type="uuid" required="true">
		<cfargument name="archiveID"  type="uuid" required="true" hint="the archived object to be sent back live">
		<cfargument name="typename" type="string" default="" required="false">
		
 		<cfset var stResult = application.factory.oVersioning.rollbackArchive(objectid=arguments.objectid,typename=arguments.typename,archiveID=arguments.archiveID)>
		
		<cfreturn stResult>
	</cffunction>

	<!--- // STATUS: default status changing methods --->
	<cffunction name="statustodraft" access="public" returntype="struct" hint="Sends object to draft state." output="false">
	<!--- 	
	// TODO: 
		update comment log if its here
		notify owner of status change if owner didn't change
		check audit is firing from setdata()
		Versioning (via versions.cfc)
			- delete underlying draft if it exists
	 --->		
		<cfset var stresult=structnew()>
		<cfset var stproperties=structNew()>
		<cfset stproperties.objectid=instance.stobj.objectid>
		<cfset stproperties.status="draft">
		<cfset setData(stproperties=stproperties)>
		<cfset stresult.bsuccess=true>
		<cfset stresult.message="Content status changed to draft.">
		<cfreturn stResult>
	</cffunction>

	<cffunction name="statustopending" access="public" returntype="struct" hint="Sends object to pending state." output="false">
	<!--- 	
	// TODO: 
		update comment log if its here
		notify owner of status change if owner didn't change
		notify approvers
	 --->		
		<cfset var stresult=structnew()>
		<cfset var stproperties=structNew()>
		<cfset stproperties.objectid=instance.stobj.objectid>
		<cfset stproperties.status="pending">
		<cfset setData(stproperties=stproperties)>
		<cfset stresult.bsuccess=true>
		<cfset stresult.message="Content status changed to pending.">
		<cfreturn stResult>
	</cffunction>
	<cffunction name="statustoapproved" access="public" returntype="struct" hint="Sends object to approved state." output="false">
	<!--- 	
	// TODO: 
		update comment log if its here
		notify owner of status change if owner didn't change
		Versioning (via versions.cfc)
			- archive current live
	 --->		
		<cfset var stresult=structnew()>
		<cfset var stproperties=structNew()>
		<cfset stproperties.objectid=instance.stobj.objectid>
		<cfset stproperties.status="approved">
		<cfset setData(stproperties=stproperties)>
		<cfset stresult.bsuccess=true>
		<cfset stresult.message="Content status changed to pending.">
 		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="buildTreeCreateTypes" access="public" returntype="array" hint="Creates array of content types that can be created" output="false">
		<cfargument name="lTypes" required="true" type="string">
		<!--- this function is migrated from the dmNavigation renderOverview --->
		<cfset var aReturn = ArrayNew(1)>
		<cfset var aTypes = listToArray(arguments.lTypes)>
		<!--- build core types first --->
		<cfloop index="i" from="1" to="#arrayLen(aTypes)#">
			<cfif structKeyExists(Application.types[aTypes[i]],"bUseInTree") AND Application.types[aTypes[i]].bUseInTree AND NOT application.types[aTypes[i]].bcustomType>
				<cfset stType = structNew()>
				<cfset stType.typename = aTypes[i]>
				
				<cfif structKeyExists(application.types[aTypes[i]],"displayname")> <!--- displayname *seemed* most appropriate without adding new metadata --->
					<cfset stType.description = application.types[aTypes[i]].displayName>
				<cfelse>
					<cfset stType.description = aTypes[i]>
				</cfif>
				<cfset ArrayAppend(aReturn,stType)>
			</cfif>
		</cfloop>

<!--- 
			//now custom types
			for(i=1;i LTE arrayLen(aTypes);i = i+1)
			{		
				if (structKeyExists(application.types[aTypes[i]],'bUseInTree') AND application.types[aTypes[i]].bUseInTree AND application.types[aTypes[i]].bcustomType)
				{	stType = structNew();
					stType.typename = aTypes[i];
					if (structKeyExists(application.types[aTypes[i]],'displayname'))   //displayname *seemed* most appropriate without adding new metadata
						stType.description = application.types[aTypes[i]].displayName;
					else
						stType.description = aTypes[i];
					arrayAppend(a,stType);
				}	
			}	
 --->			
			
		<cfreturn aReturn>
	</cffunction>

	<cffunction name="setFriendlyURL" access="public" returntype="struct" hint="the default set friendly url for an object." output="true">
		<cfargument name="stProperties" required="true" type="struct">
		
		<cfset var stLocal = structnew()>
		<cfset stLocal.returnstruct = StructNew()>
		<cfset stLocal.returnstruct.bSuccess = 1>
		<cfset stLocal.returnstruct.message = "">

		<cfset stLocal.stFriendlyURL = StructNew()>
		<cfset stLocal.stFriendlyURL.objectid = arguments.stProperties.objectid>
		<cfset stLocal.stFriendlyURL.friendlyURL = "">
		<cfset stLocal.stFriendlyURL.querystring = "">

		<cfset stLocal.objFU = CreateObject("component","#Application.packagepath#.farcry.fu")>
		<!--- used to retrieve default of where item is in tree --->
		<cfset stLocal.objNavigation = CreateObject("component","#Application.packagepath#.types.dmnavigation")>

		<!--- This determines the friendly url by where it sits in the navigation node  --->
		<cfset stLocal.qNavigation = stLocal.objNavigation.getParent(arguments.stProperties.objectid)>

		<cfif stLocal.qNavigation.recordcount>
			<cfset stLocal.stFriendlyURL.friendlyURL = stLocal.objFU.createFUAlias(stLocal.qNavigation.objectid)>
		<cfelse> <!--- generate friendly url based on content type --->
			<cfif StructkeyExists(application.types[arguments.stProperties.typename],"displayName")>
				<cfset stLocal.stFriendlyURL.friendlyURL = "/#application.types[arguments.stProperties.typename].displayName#">
			<cfelse>
				<cfset stLocal.stFriendlyURL.friendlyURL = "/#ListLast(application.types[arguments.stProperties.typename].name,'.')#">
			</cfif>
		</cfif>

		<cfset stLocal.stFriendlyURL.friendlyURL = stLocal.stFriendlyURL.friendlyURL & "/#arguments.stProperties.label#">
		<cfset stLocal.objFU.setFU(stLocal.stFriendlyURL.objectid, stLocal.stFriendlyURL.friendlyURL, stLocal.stFriendlyURL.querystring)>

 		<cfreturn stLocal.returnstruct>
	</cffunction>
</cfcomponent>

