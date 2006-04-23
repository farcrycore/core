<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/navajo/keywords/tree.cfm,v 1.4 2004/08/19 04:34:53 paul Exp $
$Author: paul $
$Date: 2004/08/19 04:34:53 $
$Name: milestone_2-3-2 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Displays category tree $
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfprocessingDirective pageencoding="utf-8">

<cfscript>
	oCat = createObject("component","#application.packagepath#.farcry.category");
	oCat.displayTree();
</cfscript>

