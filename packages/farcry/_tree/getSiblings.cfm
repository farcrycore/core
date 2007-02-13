<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_tree/getSiblings.cfm,v 1.10 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.10 $

|| DESCRIPTION || 
$Description: getSiblings Function $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfscript>
	// get parent
	qParent = getParentID(arguments.objectid);
	// don't get self
	if(NOT arguments.bIncludeSelf) temp = arrayAppend(arguments.aFilter,"t.objectid <> '#arguments.objectid#'");
	// get siblings
	qReturn = getDescendants(objectid=qParent.parentid,depth=1, afilter=arguments.aFilter,lColumns=arguments.lColumns);
</cfscript>

<cfsetting enablecfoutputonly="no">