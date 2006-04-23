<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/statsVisitorPathDetail.cfm,v 1.4 2003/12/10 23:41:33 brendan Exp $
$Author: brendan $
$Date: 2003/12/10 23:41:33 $
$Name: milestone_2-2-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Displays path taken by visitor during session$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
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
	<cfimport taglib="/farcry/farcry_core/tags/webskin/" prefix="skin">
	<cfimport taglib="/farcry/fourq/tags" prefix="q4">
	
	<!--- get stats --->
	<cfscript>
		qVisitorPath = application.factory.oStats.getVisitorPath(sessionid='#url.sessionId#');
	</cfscript>
	
	<cfoutput>
	<br><div class="formtitle">Visitor Path</div>
	</cfoutput>
	
	<cfloop query="qVisitorPath">
		<cftry>
			<q4:contentobjectget objectID="#objectid#" r_stobject="stObject">
			<skin:breadcrumb 
			separator=" &raquo; " 
			objectid = "#navid#"
			here= "#stObject.title#"
			linkclass="breadcrumb">
			<cfoutput> (#timeSpent#)<p></p></cfoutput>
			<cfcatch></cfcatch>
		</cftry>
	</cfloop>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="no">