<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/container/container.cfm,v 1.11.2.1 2004/10/18 05:55:40 geoff Exp $
$Author: geoff $
$Date: 2004/10/18 05:55:40 $
$Name: milestone_2-2-1 $
$Revision: 1.11.2.1 $

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
<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">

<cfparam name="attributes.label" default="">
<cfparam name="attributes.objectID" default="#request.stobj.objectid#">
<cfparam name="attributes.preHTML" default="">
<cfparam name="attributes.postHTML" default="">
<cfparam name="attributes.bShowIfEmpty" type="boolean" default="true">
<cfparam name="request.mode" default="false">

<cfif NOT len(attributes.label) AND NOT len(attributes.objectID)>
	<cfthrow type="container" message="Insufficient parameters (label of objectID are required) passed">
</cfif>

<cfscript>
	oCon = createObject("component","#application.packagepath#.rules.container");
	qGetContainer = oCon.getContainer(dsn=application.dsn,label=attributes.label);
	if (NOT qGetContainer.recordCount)
	{
		stProps=structNew();
		//extended fourq specific properties
		stProps.objectid = createUUID();
		stProps.label = attributes.label;
		containerID = stProps.objectID;
		oCon.createData(dsn=application.dsn,stProperties=stProps,parentobjectid=attributes.objectid);
	}
	else if(qGetContainer.recordCount GT 1) {
		//stick the results in a list - useful if more than one result is returned and we wanna grab the first only
		containerIDList = valueList(qGetContainer.objectID);
		containerID = listGetAt(containerIDList,listLen(containerIDList));
	} else {
		containerID = qGetContainer.objectID;
	}
	stObjCon = oCon.getData(dsn=application.dsn,objectid=containerid);
	
	//this amounts to a check for the container in refObjects - will be phased out for next milestine release(post V2)
	qRefCon = oCon.refContainerDataExists(objectid=attributes.objectid,containerid=containerid);
	if (NOT qRefCon.recordCount)
		oCon.createDataRefContainer(objectid=attributes.objectid,containerid=containerid);
</cfscript>


<!--- display edit widget --->
<cfif request.mode.design and request.mode.showcontainers gt 0>
	<dm:containerControl objectID="#containerID#" label="#attributes.label#" mode="design">
</cfif>	


<cfif arrayLen(stObjCon.aRules)>

	<!--- delay the populate so we can see the content --->
	<cfsavecontent variable="conOutput">
		<cfscript>
			oCon.populate(aRules=stObjCon.aRules);
		</cfscript>
	</cfsavecontent>

	<!--- output if conOutput is not empty or the bShowIfEmpty attribute is set to true --->
	<cfif len(trim(conOutput)) OR attributes.bShowIfEmpty>
		<cfscript>
			if(attributes.preHTML neq "")
				writeoutput(attributes.preHTML);
			writeoutput(conOutput);
			if (attributes.postHTML neq "")
				writeoutput(attributes.postHTML);
		</cfscript>
	</cfif>
	
</cfif>