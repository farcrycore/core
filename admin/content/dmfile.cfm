<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2005, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/content/dmfile.cfm,v 1.3 2005/09/14 03:51:46 daniela Exp $
$Author: daniela $
$Date: 2005/09/14 03:51:46 $
$Name: milestone_3-0-1 $
$Revision: 1.3 $

|| DESCRIPTION ||
$Description: Generic type administration. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/farcry_core/tags/widgets/" prefix="widgets">

<cfset editobjectURL = "#application.url.farcry#/conjuror/invocation.cfm?objectid=##recordset.objectID[recordset.currentrow]##&typename=dmFile">

<!--- set up page header --->
<admin:header title="File Admin" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#" onload="setupPanes('container1');">

<widgets:typeadmin 
	typename="dmFile"
	permissionset="news"
	title="#application.adminBundle[session.dmProfile.locale].MediaLibraryFileAdministration#"
	bdebug="0">
</widgets:typeadmin>

<admin:footer>
