<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| DESCRIPTION ||
$Description: Flash library administration. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!--- set up page header --->
<admin:header title="Flash Admin" />

<ft:objectadmin 
	typename="dmFlash"
	permissionset="news"
	title="#application.rb.getResource("MediaLibraryFlashAdministration")#"
	columnList="label,datetimelastUpdated,status" 
	sortableColumns="label,datetimelastUpdated,status"
	lFilterFields="label"
	sqlorderby="datetimelastUpdated desc"
	module="customlists/dmflash.cfm" />

<admin:footer />
