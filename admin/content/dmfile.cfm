<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2005, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/content/dmfile.cfm,v 1.3 2005/09/14 03:51:46 daniela Exp $
$Author: daniela $
$Date: 2005/09/14 03:51:46 $
$Name: milestone_3-0-1 $
$Revision: 1.3 $

|| DESCRIPTION ||
$Description: Generic type administration. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!--- set up page header --->
<admin:header title="File Admin" />

<ft:objectadmin 
	typename="dmFile"
	permissionset="news"
	title="#application.adminBundle[session.dmProfile.locale].MediaLibraryFileAdministration#"
	columnList="label,datetimelastUpdated,status"
	sortableColumns="label,datetimelastUpdated,status"
	lFilterFields="label"
	sqlorderby="datetimelastUpdated desc" />

<admin:footer />
