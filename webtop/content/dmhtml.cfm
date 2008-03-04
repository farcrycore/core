<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2005, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/content/dmhtml.cfm,v 1.2.2.1 2006/01/04 07:45:53 paul Exp $
$Author: paul $
$Date: 2006/01/04 07:45:53 $
$Name: milestone_3-0-1 $
$Revision: 1.2.2.1 $

|| DESCRIPTION ||
$Description: Generic type administration. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/widgets/" prefix="widgets">

<cfset editobjectURL = "#application.url.farcry#/conjuror/invocation.cfm?objectid=##recordset.objectID[recordset.currentrow]##&typename=dmhtml">

<!--- set up page header --->
<admin:header title="HTML Admin" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#" onload="setupPanes('container1');">

<widgets:typeadmin 
	typename="dmHTML"
	permissionset="news"
	title="#apapplication.rb.getResource("SiteTreeContentHtmlAdministration")#"
	bdebug="0">
</widgets:typeadmin>

<admin:footer>
