<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/container/container.cfm,v 1.16 2005/01/10 06:30:46 paul Exp $
$Author: paul $
$Date: 2005/01/10 06:30:46 $
$Name: milestone_2-3-2 $
$Revision: 1.16 $

|| DESCRIPTION || 
$Description: Displays containers$
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/container/" prefix="dm">
<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">

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

<cfscript>
	// TODO: this should be using the factory container object, no? GB
	oCon = createObject("component","#application.packagepath#.rules.container");
	qGetContainer = oCon.getContainer(dsn=application.dsn,label=attributes.label);

	if (NOT qGetContainer.recordCount) {
	// create a new container if one doesn't exist
		// if defaultMirror set then look-up and apply
		if (len(attributes.defaultMirrorID) AND REFindNoCase("^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{16}$", attributes.defaultmirrorid)) {
			// if UUID then lookup container by objectid
			stMirror = oCon.getData(dsn=application.dsn,objectid=attributes.defaultMirrorid);
			// TODO: if this returns emptystruct then we need to make sure mirror container is created with this UUID GB
		} else if (len(attributes.defaultMirrorlabel)) {
			// else lookup container by label
			stMirror = oCon.getContainerbylabel(dsn=application.dsn,label=attributes.defaultMirrorlabel);
		} else {
			// no default mirror specified
			stmirror=structnew();
			stmirror.objectid="";
		} 

		// create the mirror container if it is specified but missing
		if (NOT structkeyexists(stMirror, "objectid")) {
			// create the default mirror container
			stMirror=structNew();
			stMirror.objectid = createUUID();
			stMirror.label = attributes.defaultmirrorlabel;
			if (NOT len(stMirror.label)) {
				stMirror.label="Mirror Container: #stMirror.objectid#"; }
			stMirror.mirrorid="";
			stMirror.bShared=1;
			oCon.createData(dsn=application.dsn,stProperties=stMirror);
			// dump(stmirror);
		}

		// set default container properties
		stProps=structNew();
		stProps.objectid = createUUID();
		stProps.label = attributes.label;
		stProps.mirrorid=stmirror.objectid;
		stProps.bShared=0;
		containerID = stProps.objectID;
		oCon.createData(dsn=application.dsn,stProperties=stProps,parentobjectid=attributes.objectid);
		
	} else {
		containerID = qGetContainer.objectID;
	}
	
	// get the container data
	stConObj = oCon.getData(dsn=application.dsn,objectid=containerid);
	// if a mirrored container has been set then reset the container data
	if (structkeyexists(stConObj, "mirrorid") AND len(stConObj.mirrorid))
		stConObj = oCon.getData(dsn=application.dsn,objectid=stConObj.mirrorid);
	
	// if container instance exists, check for refContainer data
	// if it doesn't exist then create appropriate references.
	/*
	//TODO: commented this out to get mirror working... does this serve any purpose?? GB
	qRefCon = oCon.refContainerDataExists(objectid=attributes.objectid,containerid=containerid);
	if (NOT qRefCon.recordCount)
		oCon.createDataRefContainer(objectid=attributes.objectid,containerid=containerid);
	*/
</cfscript>

<!--- display edit widget --->
<cfif request.mode.design and request.mode.showcontainers gt 0>
	<dm:containerControl objectID="#containerID#" label="#attributes.label#" mode="design">
</cfif>	

<cfif arrayLen(stConObj.aRules)>

	<!--- delay the populate so we can see the content --->
	<cfsavecontent variable="conOutput">
		<cfscript>
			oCon.populate(aRules=stConObj.aRules);
		</cfscript>
	</cfsavecontent>

	<!--- output if conOutput is not empty or the bShowIfEmpty attribute is set to true --->
	<cfparam name="stConObj.displayMethod" default="">
	<cfif len(stConObj.displayMethod)>
		<cfset oCon.getDisplay(containerBody=conOutput,template=stConObj.displayMethod)>
		
	<cfelseif len(trim(conOutput)) OR attributes.bShowIfEmpty>
		<cfscript>
			if(attributes.preHTML neq "")
				writeoutput(attributes.preHTML);
			writeoutput(conOutput);
			if (attributes.postHTML neq "")
				writeoutput(attributes.postHTML);
		</cfscript>
	</cfif>
</cfif>
