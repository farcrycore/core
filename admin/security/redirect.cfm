<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/security/redirect.cfm,v 1.7 2004/07/15 01:52:20 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:52:20 $
$Name: milestone_2-3-2 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: Security tags redirect $
$TODO: need more secure method of permission checks$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iSecurityTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="SecurityUserManagementTab");
	iSecurityTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="SecurityPolicyManagementTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iSecurityTab eq 1 or iSecurityTab eq 1>

	<cfmodule template="/farcry/farcry_core/tags/security/ui/dmSecUI_Redirect.cfm">

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>