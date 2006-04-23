<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/types.cfc,v 1.68.2.16 2006/02/22 02:09:17 paul Exp $
$Author: paul $
$Date: 2006/02/22 02:09:17 $
$Name: milestone_3-0-1 $
$Revision: 1.68.2.16 $

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
<cfproperty name="label" displayname="Label" type="nstring" hint="Object label or title." required="no" default=""> 
<cfproperty name="datetimecreated" displayname="Datetime created" type="date" hint="Timestamp for record creation." required="yes" default=""> 
<cfproperty name="createdby" displayname="Created by" type="nstring" hint="Username for creator." required="yes" default="">
<cfproperty name="ownedby" displayname="Owned by" type="nstring" hint="Username for owner." required="yes" default="">
<cfproperty name="datetimelastupdated" displayname="Datetime lastupdated" type="date" hint="Timestamp for record last modified." required="yes" default=""> 
<cfproperty name="lastupdatedby" displayname="Last updated by" type="nstring" hint="Username for modifier." required="yes" default="">
<cfproperty name="lockedBy" displayname="Locked by" type="nstring" hint="Username for locker." required="no" default="">
<cfproperty name="locked" displayname="Locked" type="boolean" hint="Flag for object locking." required="yes" default="0">

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
						<cfthrow type="Application" detail="Error: Template not found [#application.path.webskin#/#stObj.typename#/#arguments.template#.cfm]." >
						<!--- <cfabort showerror="Error: Template not found [#application.path.webskin#/#stObj.typename#/#arguments.template#.cfm].">  --->
					<cfelse>
						<cfrethrow /> 
						<!--- <cfif isdefined("url.debug")><cfset request.cfdumpinited = false><cfoutput>#cfcatch.message#<br />#cfcatch.detail#</cfoutput><cfdump var="#cfcatch#"></cfif> --->
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
			if(NOT structKeyExists(arguments.stProperties,"typename"))			
				arguments.stProperties.typename = findType(objectid=arguments.stProperties.objectid);
				
		</cfscript>				
				
		<cfset stresult = super.setData(arguments.stProperties,arguments.dsn)>

		<!--- set friendly url for content item,if applicable 
		TODO: sort out FU allocation.. have moved this to status approval step for now.. so introducing a catch all for non-status based content types. --->
		<cfif NOT structkeyexists(arguments.stproperties, "status")>
			<cfif Application.config.plugins.FU AND (NOT StructKeyExists(application.types[arguments.stProperties.typename].stprops,"status")) AND StructKeyExists(application.types[arguments.stProperties.typename],"bFriendly") AND application.types[arguments.stProperties.typename].bFriendly AND NOT ListFindNoCase(application.config.fusettings.lExcludeObjectIDs,arguments.stProperties.objectid)>
				<cfif StructKeyExists(arguments.stProperties,"label") AND Trim(arguments.stProperties.label) NEQ "" AND arguments.stProperties.label NEQ "incomplete">
					<cfset stresult_friendly = setFriendlyURL(arguments.stProperties.objectid)>
				</cfif>
			</cfif>
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
				} 
				if (isDefined("stoutput.name")) {
					stoutput.label=stoutput.name; // match label with title
				} 
				else {
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
			- set friendly url as required
	 --->		
		<cfset var stresult = structnew()>
		<cfset var stproperties = structNew()>
		<cfset var stobj = getdata(objectid=instance.stobj.objectid)>
		<cfset var stlocal = structnew()>
		<cfset stproperties.objectid = instance.stobj.objectid> --->
		<cfset stproperties.status = "approved">
		<cfset setData(stproperties=stproperties)>
		<cfset stresult.bsuccess = true>
		<cfset stresult.message = "Content status changed to approved.">
		<!--- also approve all associated images/files (aobjectids) --->
		<cfif StructKeyExists(application.types[instance.stobj.typename].stprops,"aObjectIDs") AND ArrayLen(instance.stobj.aObjectIDs)>
			<cfset stlocal.lObjectids = ListQualify(ArrayToList(instance.stobj.aObjectIDs),"'")>
			<cfset stlocal.lTypeNames = "dmImage,dmFile">
			<cfloop index="stlocal.iTypeName" list="#stlocal.lTypeNames#">
				<cfquery name="stLocal.qUpdateStatus" datasource="#application.dsn#">
				UPDATE	#application.dbowner##stlocal.iTypeName#
				SET		status = '#stproperties.status#'
				WHERE	objectid IN (#preservesinglequotes(stlocal.lObjectids)#)
				</cfquery>				
			</cfloop>
		</cfif>
		
		<!--- 
		// Set Friendly URL 
		 - TODO: this is going to cause issues if the approval process fails or is not confirmed GB20060123
		--->
		<!--- versioned objects use parent live object for fu --->
		<cfif StructKeyExists(stObj,"versionid") AND len(stobj.versionid)>
			<cfset fuoid=stobj.versionid>
		<!--- use objectid if no versionid --->
		<cfelse>
			<cfset fuoid=stobj.objectid>
		</cfif>
		
		<!--- make sure objectid is not specifically excluded from FU --->
		<cfset bExclude = 0>
		<cfif ListFindNoCase(application.config.fusettings.lExcludeObjectIDs,fuoid)>
			<cfset bExclude = 1>
		</cfif>
		
		<!--- make sure content type requires friendly url --->
		<cfif NOT StructKeyExists(application.types[stObj.typename],"bFriendly") OR NOT application.types[stObj.typename].bFriendly>
			<cfset bExclude = 1>
		</cfif> 
		
		<!--- set friendly url --->
		<cfif NOT bExclude>
			<cfset objTypes = CreateObject("component","#application.types[stObj.typename].typepath#")>
			<cfset stresult_friendly = objTypes.setFriendlyURL(objectid=fuoid)>
		</cfif>

 		<cfreturn stResult>
	</cffunction>

	<cffunction name="setFriendlyURL" access="public" returntype="struct" hint="Default setfriendlyurl() method for content items." output="false">
		<cfargument name="objectid" required="false" default="#instance.stobj.objectid#" type="uuid" hint="Content item objectid.">
		<cfset var stReturn = StructNew()>
		<cfset var stobj = getdata(arguments.objectid)>
		<cfset var stFriendlyURL = StructNew()>
		<cfset var objFU = CreateObject("component","#Application.packagepath#.farcry.fu")>
		<cfset var objNavigation = CreateObject("component","#Application.packagepath#.types.dmNavigation")>
		<cfset var qNavigation=querynew("objectid")>
		
		<!--- default return structure --->
		<cfset stReturn.bSuccess = 1>
		<cfset stReturn.message = "Set friendly URL for #arguments.objectid#.">

		<!--- default stFriendlyURL structure --->
		<cfset stFriendlyURL.objectid = stobj.objectid>
		<cfset stFriendlyURL.friendlyURL = "">
		<cfset stFriendlyURL.querystring = "">
		
		<!--- This determines the friendly url by where it sits in the navigation node  --->
		<cfset qNavigation = objNavigation.getParent(stobj.objectid)>
		
		<!--- if its got a tree parent, build from navigation folders --->
		<!--- TODO: this might be better done by checking for bUseInTree="true" 
					or remove it entirely.. ie let tree content have its own fu as well as folder fu
					or set up tree content to have like page1.cfm style suffixs
					PLUS need collision detection so don't overwrite another tree based content item fro utility nav
					PLUS need to exclude trash branch (perhaps just from total rebuild?
					GB 20060117 --->
		<cfif qNavigation.recordcount>
			<cfset stFriendlyURL.friendlyURL = objFU.createFUAlias(qNavigation.objectid)>
		
		<!--- otherwise, generate friendly url based on content type --->
		<cfelse> 
			<cfif StructkeyExists(application.types[stobj.typename],"displayName")>
				<cfset stFriendlyURL.friendlyURL = "/#application.types[stobj.typename].displayName#">
			<cfelse>
				<cfset stFriendlyURL.friendlyURL = "/#ListLast(application.types[stobj.typename].name,'.')#">
			</cfif>
		</cfif>
		
		<!--- set friendly url in database --->
		<cfset stFriendlyURL.friendlyURL = stFriendlyURL.friendlyURL & "/#stobj.label#">
		<cfset objFU.setFU(stFriendlyURL.objectid, stFriendlyURL.friendlyURL, stFriendlyURL.querystring)>
		
		<cflog application="true" file="futrace" text="types.setFriendlyURL: #stFriendlyURL.friendlyURL#" />
 		<cfreturn stReturn />
	</cffunction>
	
	<cffunction name="fRebuildFriendlyURLs" access="public" returntype="struct" hint="rebuilds friendly urls for a particular type" output="true">
		<!--- TODO: this is the wrong place for this method! try fu.cfc maybe? GB 20060117 --->
		<cfargument name="typeName" required="true" type="string">
		
		<cfset var stLocal = structnew()>
		<cfset stLocal.returnstruct = StructNew()>
		<cfset stLocal.returnstruct.bSuccess = 1>
		<cfset stLocal.returnstruct.message = "">

		<cfquery name="stLocal.qList" datasource="#application.dsn#">
		SELECT	objectid, label
		FROM	#application.dbowner##arguments.typeName#
		WHERE	label != '(incomplete)'
		</cfquery>

		<!--- clean out any friendly url for objects that have been deleted --->
		<cfquery name="stLocal.qDelete" datasource="#application.dsn#">
		DELETE
		FROM	#application.dbowner#reffriendlyURL
		WHERE	refobjectid NOT IN (SELECT objectid FROM #application.dbowner#refObjects)
		</cfquery>

		<!--- delete old friendly url for this type --->
		<cfquery name="stLocal.qDelete" datasource="#application.dsn#">
		DELETE
		FROM	#application.dbowner#reffriendlyURL
		WHERE	refobjectid IN (SELECT objectid FROM #application.dbowner##arguments.typeName#)
		</cfquery>
		
		<cfset stLocal.iCounterUnsuccess = 0>
		<cftry>
			<cfloop query="stLocal.qList">
				<cfset stlocal.stInstance = getData(objectid=stLocal.qList.objectid,bShallow=true)>
				<cfset setFriendlyURL(stlocal.stInstance.objectid)>
			</cfloop>
			<cfcatch>
				<cfset stLocal.iCounterUnsuccess = stLocal.iCounterUnsuccess + 1>
			</cfcatch>
		</cftry>
		<cfset stLocal.iCounterSuccess = stLocal.qList.recordcount - stLocal.iCounterUnsuccess>
		<cfset stLocal.returnstruct.message = "#stLocal.iCounterSuccess# #arguments.typeName# rebuilt successfully.<br />">
 		<cfreturn stLocal.returnstruct>
	</cffunction>
</cfcomponent>