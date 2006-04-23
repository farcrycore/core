<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_versioning/archiveObject.cfm,v 1.4 2005/08/09 03:54:40 geoff Exp $
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

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">


<cfscript>
	stResult = structNew();
	stResult.result = false;
	stResult.message = 'No update has taken place';
	if (NOT isDefined("typename"))
	{
		q4 = createObject("component","farcry.fourq.fourq");
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
	
