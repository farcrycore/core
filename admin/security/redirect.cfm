<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/security/redirect.cfm,v 1.9 2005/05/23 10:18:24 geoff Exp $
$Author: geoff $
$Date: 2005/05/23 10:18:24 $
$Name: milestone_3-0-1 $
$Revision: 1.9 $

|| DESCRIPTION || 
$Description: Security tags redirect $
$TODO: need more secure method of permission checks
you're telling me! This is total CRACK GB 20052005$

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iSecurityTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="SecurityUserManagementTab");
	iSecurityTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="SecurityPolicyManagementTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iSecurityTab eq 1 or iSecurityTab eq 1>

	<cfmodule template="/farcry/core/tags/security/ui/dmSecUI_Redirect.cfm">

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>
