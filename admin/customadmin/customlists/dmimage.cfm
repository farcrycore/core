<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| DESCRIPTION ||
$Description: Image library administration. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!--- set up page header --->
<admin:header title="Image Admin" />

<ft:objectadmin 
	typename="dmImage"
	permissionset="news"
	title="#application.adminBundle[session.dmProfile.locale].MediaLibraryImageAdministration#"
	columnList="title,datetimelastUpdated,status,ThumbnailImage" 
	sortableColumns="title,datetimelastUpdated,status"
	lFilterFields="title"
	sqlorderby="datetimelastUpdated desc"
	module="customlists/dmimage.cfm" />

<admin:footer />


