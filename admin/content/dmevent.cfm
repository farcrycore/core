<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2005, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/content/dmevent.cfm,v 1.4.2.2 2006/03/07 09:23:32 geoff Exp $
$Author: geoff $
$Date: 2006/03/07 09:23:32 $
$Name: milestone_3-0-1 $
$Revision: 1.4.2.2 $

|| DESCRIPTION ||
$Description: Generic type administration. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/farcry_core/tags/widgets/" prefix="widgets">

<!--- set up page header --->
<admin:header title="Event Admin" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#" onload="setupPanes('container1');">

<widgets:typeadmin 
	typename="dmEvent"
	permissionset="event"
	title="#application.adminBundle[session.dmProfile.locale].eventsAdministration#"
	bdebug="0">
</widgets:typeadmin>

<admin:footer>
