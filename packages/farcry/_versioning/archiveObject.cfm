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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_versioning/archiveObject.cfm,v 1.4 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Archives any farcry object $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">


<cfscript>
	stResult = structNew();
	stResult.result = false;
	stResult.message = 'No update has taken place';
	if (NOT isDefined("typename"))
	{
		q4 = createObject("component","farcry.core.packages.fourq.fourq");
		typename = q4.findType(objectid=objectid);
	}
	o = createObject("component",application.types[typename].typePath);	
	stObj = o.getData(arguments.objectID);
</cfscript>
<!--- Convert current live object to WDDX for archive --->
<cfwddx input="#stObj#" output="stLiveWDDX"  action="cfml2wddx">
<cfscript>
	//set up the dmArchive structure to save
	stProps = structNew();
	stProps.objectID = createUUID();
	stProps.archiveID = stObj.objectID;
	stProps.objectWDDX = stLiveWDDX;
	stProps.label = stObj.label;
	//end dmArchive struct  
	oArchive = createobject("component",application.types['dmArchive'].typepath);
	oArchive.createData(stProperties=stProps);
</cfscript>
	
