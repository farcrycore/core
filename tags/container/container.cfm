<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/container/container.cfm,v 1.19 2005/10/30 09:12:41 geoff Exp $
$Author: geoff $
$Date: 2005/10/30 09:12:41 $
$Name: milestone_3-0-0 $
$Revision: 1.19 $

|| DESCRIPTION || 
$Description: Displays containers$


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/container/" prefix="dm">

<!--- quit tag if running in end mode --->
<cfif thistag.executionmode eq "end"><cfexit /></cfif>

<cfparam name="attributes.label" default="" type="string">
<cfparam name="attributes.objectID" default="">
<cfparam name="attributes.preHTML" default="" type="string">
<cfparam name="attributes.postHTML" default="" type="string">
<cfparam name="attributes.bShowIfEmpty" type="boolean" default="true">
<cfparam name="attributes.defaultMirrorID" default="" type="string"><!--- optional UUID --->
<cfparam name="attributes.defaultMirrorLabel" default="" type="string">

<!--- try and set objectid by looking for request.stobj.objectid --->
<cfif NOT len(attributes.objectid) AND isDefined("request.stobj.objectid")>
	<cfset attributes.objectid=request.stobj.objectid>
</cfif>

<!--- must have at least a label or objectid to lookup container instance --->
<cfif NOT len(attributes.label) AND NOT len(attributes.objectID)>
	<cfthrow type="container" message="Missing parameters: label or objectID is required to invoke a container.">
</cfif>

<!--- TODO: this should be using the factory container object, no? GB --->
<cfset oCon = createObject("component","#application.packagepath#.rules.container")>
<cfset qGetContainer = oCon.getContainer(dsn=application.dsn,label=attributes.label)>
<cfif qGetContainer.recordCount EQ 0>
	<!--- create a new container if one doesn't exist --->
	<!--- if defaultMirror set then look-up and apply --->
	<cfif Len(attributes.defaultMirrorID) AND REFindNoCase("^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$", attributes.defaultmirrorid)>
		<!--- if UUID then lookup container by objectid --->
		<cfset stMirror = oCon.getData(dsn=application.dsn,objectid=attributes.defaultMirrorid)>
		<!--- TODO: if this returns emptystruct then we need to make sure mirror container is created with this UUID GB --->
	<cfelseif Len(attributes.defaultMirrorlabel)>
		<!--- else lookup container by label --->
		<cfset stMirror = oCon.getContainerbylabel(dsn=application.dsn,label=attributes.defaultMirrorlabel)>
	<cfelse>
		<!--- no default mirror specified --->
		<cfset stMirror = StructNew()>
		<cfset stMirror.objectID = "">
	</cfif>

	<!--- create the mirror container if it is specified but missing --->
	<cfif NOT StructKeyExists(stMirror, "objectid")>
		<!--- create the default mirror container --->
		<cfset stMirror = StructNew()>
		<cfset stMirror.objectid = createUUID()>
		<cfset stMirror.label = attributes.defaultmirrorlabel>
		<cfif Len(stMirror.label) EQ 0>
			<cfset stMirror.label="Mirror Container: #stMirror.objectid#">
		</cfif>

		<cfset stMirror.mirrorid = "">
		<cfset stMirror.bShared = 1>
		<cfset oCon.createData(dsn=application.dsn,stProperties=stMirror)>
	</cfif>

	<!--- set default container properties --->
	<cfset stProps = structNew()>
	<cfset stProps.objectid = createUUID()>
	<cfset stProps.label = attributes.label>
	<cfset stProps.mirrorid = stmirror.objectid>
	<cfset stProps.bShared = 0>
	<cfset containerID = stProps.objectID>
	<cfset oCon.createData(dsn=application.dsn, stProperties=stProps, parentobjectid=attributes.objectid)>
<cfelse>
	<cfset containerID = qGetContainer.objectID>
</cfif>

<!--- get the container data --->
<cfset stConObj = oCon.getData(dsn=application.dsn,objectid=containerid)>
<!--- if a mirrored container has been set then reset the container data --->
<cfif (StructKeyExists(stConObj, "mirrorid") AND Len(stConObj.mirrorid))>
	<cfset stConObj = oCon.getData(dsn=application.dsn,objectid=stConObj.mirrorid)>
</cfif>

<!--- display edit widget --->
<cfif request.mode.design and request.mode.showcontainers gt 0>
	<dm:containerControl objectID="#containerID#" label="#attributes.label#" mode="design">
</cfif>	

<cfif arrayLen(stConObj.aRules)>

	<!--- delay the populate so we can see the content --->
	<cfsavecontent variable="conOutput">
		<cfset oCon.populate(aRules=stConObj.aRules)>
	</cfsavecontent>

	<!--- output if conOutput is not empty or the bShowIfEmpty attribute is set to true --->
	<cfparam name="stConObj.displayMethod" default="">
	<cfif len(stConObj.displayMethod)>
		<cfset oCon.getDisplay(containerBody=conOutput,template=stConObj.displayMethod)>		
	<cfelseif Len(Trim(conOutput)) OR attributes.bShowIfEmpty>
		<cfif attributes.preHTML NEQ "">
			<cfoutput>#attributes.preHTML#</cfoutput>
		</cfif>
		<cfoutput>#conOutput#</cfoutput>
		
		<cfif attributes.postHTML NEQ "">
			<cfoutput>#attributes.postHTML#</cfoutput>
		</cfif>
	</cfif>
</cfif>
