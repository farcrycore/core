<cfsetting enablecfoutputonly="true" />
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
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/container/container.cfm,v 1.19 2005/10/30 09:12:41 geoff Exp $
$Author: geoff $
$Date: 2005/10/30 09:12:41 $
$Name: milestone_3-0-1 $
$Revision: 1.19 $

|| DESCRIPTION || 
$Description: Displays containers$


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/container/" prefix="con">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<!--- quit tag if running in end mode --->
<cfif thistag.executionmode eq "end">
	<cfsetting enablecfoutputonly="false" />
	<cfexit />
</cfif>

<cfparam name="attributes.label" default="" type="string">
<cfparam name="attributes.objectID" default="">
<cfparam name="attributes.preHTML" default="" type="string">
<cfparam name="attributes.postHTML" default="" type="string">
<cfparam name="attributes.bShowIfEmpty" type="boolean" default="true">
<cfparam name="attributes.defaultMirrorID" default="" type="string"><!--- optional UUID --->
<cfparam name="attributes.defaultMirrorLabel" default="" type="string">
<cfparam name="attributes.desc" default="" type="string"><!--- Allows the container description to be different to the actual label. --->


<!--- try and set objectid by looking for request.stobj.objectid --->
<cfif NOT len(attributes.objectid) AND isDefined("request.stobj.objectid")>
	<cfset attributes.objectid=request.stobj.objectid>
</cfif>

<!--- must have at least a label or objectid to lookup container instance --->
<cfif NOT len(attributes.label) AND NOT len(attributes.objectID)>
	<cfthrow type="container" message="Missing parameters: label or objectID is required to invoke a container.">
</cfif>

<!--- SETUP ENVIRONMENT VARIABLES --->
<cfset containerID = "" />
<cfset mirrorID = "" />
<cfif request.mode.design and request.mode.showcontainers gt 0>
	<cfset bCreateContainers = true />
<cfelse>
	<cfset bCreateContainers = false />
</cfif>

<!--- TODO: this should be using the factory container object, no? GB --->
<cfset containerID = application.fc.container.getContainerID(dsn=application.dsn,label=attributes.label)>
<cfif not len(containerID)>

	<!--- create a new container if one doesn't exist --->
	<!--- if defaultMirror set then look-up and apply --->
	<cfif Len(attributes.defaultMirrorID) AND REFindNoCase("^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$", attributes.defaultmirrorid)>
		<!--- if UUID then lookup container by objectid --->
		<cfset mirrorID = attributes.defaultMirrorID />
		<!--- TODO: if this returns emptystruct then we need to make sure mirror container is created with this UUID GB --->
	<cfelseif Len(attributes.defaultMirrorlabel) AND attributes.label NEQ attributes.defaultMirrorlabel>
		<!--- else lookup container by label --->
		<cfset mirrorID = application.fc.container.getMirrorID(dsn=application.dsn,label=attributes.defaultMirrorlabel)>
	</cfif>

	
	<cfif bCreateContainers>
	
		<!--- create the mirror container if it is specified but missing --->
		<cfif len(attributes.defaultmirrorlabel) AND NOT len(mirrorID)>
		<!--- create the default mirror container --->
			<cfset stMirror = StructNew()>
			<cfset stMirror.objectid = application.fc.utils.createJavaUUID()>
			<cfset stMirror.label = attributes.defaultmirrorlabel>
			<cfif Len(stMirror.label) EQ 0>
				<cfset stMirror.label="Mirror Container: #stMirror.objectid#">
			</cfif>
	
			<cfset stMirror.mirrorid = "">
			<cfset stMirror.bShared = 1>
			<cfset application.fc.container.createData(dsn=application.dsn,stProperties=stMirror)>
		</cfif>
	
		<!--- set default container properties --->
		<cfset stProps = structNew()>
		<cfset stProps.objectid = application.fc.utils.createJavaUUID()>
		<cfset stProps.label = attributes.label>
		<cfset stProps.mirrorid = mirrorID>
		<cfset stProps.bShared = 0>
		<cfset containerID = stProps.objectID>
		<cfset application.fc.container.createData(dsn=application.dsn, stProperties=stProps, parentobjectid=attributes.objectid)>
	</cfif>
</cfif>

<cfif not len(containerID) AND len(mirrorID)>
	<cfset containerID = mirrorID />
</cfif>




<cfif len(containerID)>
	
	<!--- Used by rules to reference the container they're a part of --->
	<cfset request.thiscontainer = containerID />
	
	<!--- get the container data --->
	<cfset stConObj = application.fc.container.getData(objectid=containerid)>
	
	<!--- PARAM THE original container ID --->
	<cfset originalID = stConObj.objectid />
	
	<!--- if a mirrored container has been set then reset the container data --->
	<cfif (StructKeyExists(stConObj, "mirrorid") AND Len(stConObj.mirrorid))>
		<cfset stConObj = application.fc.container.getData(objectid=stConObj.mirrorid) />
	</cfif>
	
	
	<!--- display edit widget --->
	<cfif request.mode.design and request.mode.showcontainers gt 0>		
	
		<skin:view stObject="#stConObj#" webskin="displayAdminToolbar" alternatehtml="" originalID="#originalID#" />		
		
	</cfif>
	
	<cfif request.mode.design and request.mode.showcontainers gt 0>
		<cfoutput><div id="#replace(originalID,'-','','ALL')#"></cfoutput>
	</cfif>
	
	
	
	<skin:view stObject="#stConObj#" webskin="displayContainer" alternatehtml="" r_html="conOutput" originalID="#originalID#" />
	
	<cfif attributes.bShowIfEmpty OR len(trim(conOutput))>
		<cfoutput>
			#attributes.preHTML#
			#conOutput#
			#attributes.postHTML#
		</cfoutput>
	</cfif>
	
	
	
	<cfif request.mode.design and request.mode.showcontainers gt 0>
		<cfoutput></div></cfoutput>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false" />