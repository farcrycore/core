<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2005, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/content/dmnews.cfm,v 1.5.2.1 2006/01/04 08:05:18 paul Exp $
$Author: paul $
$Date: 2006/01/04 08:05:18 $
$Name: milestone_3-0-1 $
$Revision: 1.5.2.1 $

|| DESCRIPTION ||
$Description: Generic type administration. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/farcry_core/tags/widgets/" prefix="widgets">

<cfset editobjectURL = "#application.url.farcry#/conjuror/invocation.cfm?objectid=##recordset.objectID[recordset.currentrow]##&typename=dmnews">

<!--- set up page header --->
<admin:header title="News Admin" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#" onload="setupPanes('container1');">

<widgets:typeadmin 
	typename="dmNews"
	permissionset="news"
	title="#application.adminBundle[session.dmProfile.locale].newsAdministration#"
	bdebug="0">
</widgets:typeadmin>

<admin:footer>
