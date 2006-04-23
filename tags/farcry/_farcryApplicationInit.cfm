<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/_farcryApplicationInit.cfm,v 1.4 2003/04/08 08:25:43 paul Exp $
$Author: paul $
$Date: 2003/04/08 08:25:43 $
$Name: b131 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: initialise application level code. Sets up site config and permissions cache$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- set up general config variables --->
<cfinclude template="_config.cfm">

<!--- Initialise the permissions cache for navajo/overview.cfm if they don't already exist (which they should) --->
<cfscript>
	oInit = createObject("component","#application.packagepath#.security.init");
	oInit.initPermissionCache();
</cfscript>

