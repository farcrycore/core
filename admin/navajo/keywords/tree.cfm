<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/navajo/keywords/tree.cfm,v 1.7 2005/09/06 12:39:39 paul Exp $
$Author: paul $
$Date: 2005/09/06 12:39:39 $
$Name: milestone_3-0-1 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: Displays category tree $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfprocessingDirective pageencoding="utf-8">
<cfimport taglib="/farcry/farcry_core/tags/admin" prefix="admin">

<cfoutput>
<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr" lang="en">
<head>
</head>
<body class="iframed-content">
</cfoutput>
<cfscript>
	oCat = createObject("component","#application.packagepath#.farcry.category");
	oCat.displayTree();
</cfscript>
<cfoutput>
</body>
</html>
</cfoutput>
