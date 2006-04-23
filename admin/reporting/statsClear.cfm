<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/statsClear.cfm,v 1.2 2003/09/03 01:50:31 brendan Exp $
$Author: brendan $
$Date: 2003/09/03 01:50:31 $
$Name: b201 $
$Revision: 1.2 $

|| DESCRIPTION || 
Rebuilds statistics tables

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: 
out:
--->

<cfsetting enablecfoutputonly="yes">

<!--- check permissions --->
<cfscript>
	iStatsTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ReportingStatsTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iStatsTab eq 1>
	<span class="formHeader">Clear Stats Log</span>
	
	<!--- drop tables and recreate --->
	<cfscript>
		deployRet = application.factory.oStats.deploy(bDropTable="1");
	</cfscript>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> #deployRet.message#...<p></p></cfoutput><cfflush>
	
	<cfoutput>All done.</cfoutput>
<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">