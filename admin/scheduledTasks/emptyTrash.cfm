<!--- @@displayname: Empty Trash --->

<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/scheduledTasks/emptyTrash.cfm,v 1.3 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: Deletes objects from the trash node older than a specified time $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: timePart - day (d) or week (ww) or month (mm) or quarter (q) or year (yyyy)$
$in: timeValue - number of days/weeks etc$
$out:$
--->
<cfprocessingDirective pageencoding="utf-8">

<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">
<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm">

<cfparam name="url.timePart" default="m">
<cfparam name="url.timeValue" default=1>

<cfscript>
	q4 = createObject("component","farcry.farcry_core.packages.fourq.fourq");
	oTree = createObject("component","#application.packagepath#.farcry.tree");
	oNav = createObject("component",application.types['dmNavigation'].typepath);
	
	// delete trash root children objects 
	stObj = oNav.getData(objectid=application.navid.rubbish);
	aNewObjectIds = arrayNew(1);
	for(i = 1;i LTE arrayLen(stObj.aObjectIds);i=i+1)
	{
		// get object details
		typename = q4.findType(stObj.aObjectIds[i]);
		if (len(typename)) {
			o = createObject("component",application.types[typename].typepath);
			stChild = o.getData(objectid=stObj.aObjectids[i]);
			try {
				// check if object older than value set above
				if (dateAdd(url.timePart, url.timeValue, stChild.dateTimeLastUpdated) lt now()) {
					// try to delete object					
						o.delete(objectid=stObj.aObjectIds[i]);
						dump(stChild);
				} else {
					// keep in new aObjectids
					arrayAppend(aNewObjectids,stObj.aObjectids[i]);		
				}
			}
			catch (Any excpt) {}
		}
	}
	
	// update trash node
	structDelete(stObj,"datetimecreated");
	stObj.datetimelastupdated = createODBCDateTime(now());	
	stObj.aObjectids = aNewObjectIds;
	oNav.setData(stProperties=stObj);
	
	// delete trash descendants
	qDesc = oTree.getDescendants(objectid=application.navid.rubbish);		
	for(i = 1;i LTE qDesc.recordCount;i=i+1)
	{	
		// get object details
		stChild = oNav.getData(objectid=qDesc.objectid[i]);
		try {
			// check if object older than value set above
			if (dateAdd(url.timePart, url.timeValue, stChild.dateTimeLastUpdated) lt now()) {
				dump(stChild);
				oNav.delete(objectid=qDesc.objectid[i]);
			}
		}
		catch (Any excpt) {}
	}
</cfscript>