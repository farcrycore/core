<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/ui/admin/Attic/statsVisitorPathDetail.cfm,v 1.3 2003/04/28 07:40:14 brendan Exp $
$Author: brendan $
$Date: 2003/04/28 07:40:14 $
$Name: b131 $
$Revision: 1.3 $

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

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/webskin/" prefix="skin">
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/fourq/tags" prefix="q4">

<admin:header>

<!--- get stats --->
<cfscript>
	oStats = createObject("component", "#application.packagepath#.farcry.stats");
	qVisitorPath = oStats.getVisitorPath(sessionid='#url.sessionId#');
</cfscript>

<cfoutput>
<br><div class="formtitle">Visitor Path</div>
</cfoutput>

<cfloop query="qVisitorPath">
	<cftry>
	<q4:contentobjectget objectID="#objectid#" r_stobject="stObject">
	<cfcatch></cfcatch>
	</cftry>
	<skin:breadcrumb 
	separator="&raquo;" 
	objectid = "#navid#"
	here= "#stObject.title#"
	linkclass="breadcrumb">
	<cfoutput> (#timeSpent#)<p></p></cfoutput>
</cfloop>

<admin:footer>

<cfsetting enablecfoutputonly="no">