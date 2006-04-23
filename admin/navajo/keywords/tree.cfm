<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/navajo/keywords/tree.cfm,v 1.2 2003/05/16 01:47:32 brendan Exp $
$Author: brendan $
$Date: 2003/05/16 01:47:32 $
$Name: b131 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: Displays category tree $
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfoutput><div id="tree"></cfoutput>
<cfscript>
	oCat = createObject("component","#application.packagepath#.farcry.category");
	oCat.displayTree();
</cfscript>
<cfoutput></div></cfoutput>