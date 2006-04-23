<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/_dmSec.cfm,v 1.3 2003/04/08 08:06:29 paul Exp $
$Author: paul $
$Date: 2003/04/08 08:06:29 $
$Name: b131 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: initialise dmSec security setup$
$TODO: $

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