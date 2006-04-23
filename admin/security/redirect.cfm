<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/security/redirect.cfm,v 1.6 2003/09/03 04:06:55 brendan Exp $
$Author: brendan $
$Date: 2003/09/03 04:06:55 $
$Name: b201 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: Security tags redirect $
$TODO: need more secure method of permission checks$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<!--- check permissions --->
<cfscript>
	iSecurityTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="SecurityUserManagementTab");
	iSecurityTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="SecurityPolicyManagementTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iSecurityTab eq 1 or iSecurityTab eq 1>

	<cfmodule template="/farcry/farcry_core/tags/security/ui/dmSecUI_Redirect.cfm">

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>