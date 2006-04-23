<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/container/container.cfm,v 1.10 2004/01/12 03:43:50 paul Exp $
$Author: paul $
$Date: 2004/01/12 03:43:50 $
$Name: milestone_2-1-2 $
$Revision: 1.10 $

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

<cfparam name="attributes.label" default="">
<cfparam name="attributes.objectID" default="#request.stobj.objectid#">
<cfparam name="attributes.preHTML" default="">
<cfparam name="attributes.postHTML" default="">
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
	stObj = oCon.getData(dsn=application.dsn,objectid=containerid);
	
	//this amounts to a check for the container in refObjects - will be phased out for next milestine release(post V2)
	qRefCon = oCon.refContainerDataExists(objectid=attributes.objectid,containerid=containerid);
	if (NOT qRefCon.recordCount)
		oCon.createDataRefContainer(objectid=attributes.objectid,containerid=containerid);
</cfscript>


<!--- display edit widget --->
<cfif request.mode.design and request.mode.showcontainers gt 0>
	<dm:containerControl objectID="#containerID#" label="#attributes.label#" mode="design">
</cfif>	

<cfscript>
if (arrayLen(stObj.aRules))
{
	if(attributes.preHTML neq "")
		writeoutput(attributes.preHTML);
	oCon.populate(aRules=stObj.aRules);	
	if (attributes.postHTML neq "")
		writeoutput(attributes.postHTML);
}
</cfscript>