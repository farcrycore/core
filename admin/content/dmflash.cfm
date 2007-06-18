<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2005, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/content/dmflash.cfm,v 1.2.2.1 2006/01/04 08:05:18 paul Exp $
$Author: paul $
$Date: 2006/01/04 08:05:18 $
$Name: milestone_3-0-1 $
$Revision: 1.2.2.1 $

|| DESCRIPTION ||
$Description: Generic type administration. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!--- set up page header --->
<admin:header title="Flash Admin" />

<ft:objectadmin 
	typename="dmFlash"
	permissionset="news"
	title="#application.adminBundle[session.dmProfile.locale].MediaLibraryFlashAdministration#"
	columnList="label,datetimelastUpdated,status" 
	sortableColumns="label,datetimelastUpdated,status"
	lFilterFields="label"
	sqlorderby="datetimelastUpdated desc" />

<admin:footer />
