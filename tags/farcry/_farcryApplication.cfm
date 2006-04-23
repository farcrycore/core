<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/_farcryApplication.cfm,v 1.4 2003/04/08 08:25:43 paul Exp $
$Author: paul $
$Date: 2003/04/08 08:25:43 $
$Name: b201 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: application code needed for every page. Checks login status and setus up request scope$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<cfscript>
request.dmSec.oAuthorisation = createObject("component","#application.securitypackagepath#.authorisation");
request.dmSec.oAuthentication = createObject("component","#application.securitypackagepath#.authentication");
if (isDefined("url.logout") and url.logout eq 1)
	request.dmsec.oAuthentication.logout(bAudit=1);
stLoggedIn = request.dmsec.oAuthentication.getUserAuthenticationData();
request.loggedin = stLoggedin.bLoggedIn;	
</cfscript>

<!--- setup request variables --->
<cfinclude template="_requestScope.cfm">

<cfsetting enablecfoutputonly="no">