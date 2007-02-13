<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/statsVisitorPathDetail.cfm,v 1.7 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: Displays path taken by visitor during session$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
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
	<cfimport taglib="/farcry/farcry_core/tags/webskin/" prefix="skin">
	<cfimport taglib="/farcry/farcry_core/packages/fourq/tags/" prefix="q4">
	
	<!--- get stats --->
	<cfscript>
		qVisitorPath = application.factory.oStats.getVisitorPath(sessionid='#url.sessionId#');
	</cfscript>
	
	<cfoutput>
	<h3>#application.adminBundle[session.dmProfile.locale].visitorPath#</h3>
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