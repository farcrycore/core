<!--- @@displayname: Empty Trash --->
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
$Header: /cvs/farcry/core/webtop/scheduledTasks/emptyTrash.cfm,v 1.3 2005/08/09 03:54:40 geoff Exp $
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

<cfinclude template="/farcry/core/webtop/includes/cfFunctionWrappers.cfm">
<cfinclude template="/farcry/core/webtop/includes/utilityFunctions.cfm">

<cfparam name="url.timePart" default="m">
<cfparam name="url.timeValue" default=1>

<cfscript>
	q4 = createObject("component","farcry.core.packages.fourq.fourq");
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