<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/statsClear.cfm,v 1.3 2004/07/15 01:51:48 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:51:48 $
$Name: milestone_2-3-2 $
$Revision: 1.3 $

|| DESCRIPTION || 
Rebuilds statistics tables

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: 
out:
--->

<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iStatsTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ReportingStatsTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iStatsTab eq 1>
	<cfoutput><div class="formtitle">#application.adminBundle[session.dmProfile.locale].clearStatsLog#</div></cfoutput>
	
	<!--- drop tables and recreate --->
	<cfscript>
		deployRet = application.factory.oStats.deploy(bDropTable="1");
	</cfscript>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #deployRet.message#...<p></p></cfoutput><cfflush>
	
	<cfoutput>#application.adminBundle[session.dmProfile.locale].allDone#</cfoutput>
<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">