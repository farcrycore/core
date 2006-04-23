<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_tree/getSiblings.cfm,v 1.8 2003/09/25 05:28:17 brendan Exp $
$Author: brendan $
$Date: 2003/09/25 05:28:17 $
$Name: b201 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: getSiblings Function $
$TODO: $

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
	temp = arrayAppend(arguments.aFilter,"t.objectid <> '#arguments.objectid#'");
	// get siblings
	qReturn = getDescendants(objectid=qParent.parentid,depth=1, afilter=arguments.aFilter,lColumns=arguments.lColumns);
</cfscript>

<cfsetting enablecfoutputonly="no">