<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/_dmSec.cfm,v 1.4 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-0 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: initialise dmSec security setup$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<!--- initialise any server/session structs that are non existant --->
<cfscript>
	oSecInit = createObject("component","#application.packagepath#.security.init");
	oSecInit.initServer();
	oSecInit.initSession();
</cfscript>


<cfsetting enablecfoutputonly="no">