<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/help/support.cfm,v 1.3 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-0 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: support page for help tab. $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iHelpTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="MainNavHelpTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iHelpTab eq 1>
<cfoutput>
	<div class="formtitle">#application.adminBundle[session.dmProfile.locale].commericalSupport#</div>
	
	<div style="padding-left:30px;padding-bottom:30px;">
	<a href="http://www.daemon.com.au" target="_blank"><img src="../images/daemon_logo.gif" alt="Daemon Internet Consultants" border="0"></a>
	#application.adminBundle[session.dmProfile.locale].iLoveDaemonBlurb#	
	<p><span class="frameMenuBullet">&raquo;</span> <a href="http://www.daemon.com.au/go/farcry-support">#application.adminBundle[session.dmProfile.locale].daemonCommercialFarcrySupport#</a></p>
	</div>
</cfoutput>
<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>
