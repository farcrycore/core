<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| DESCRIPTION ||
$Description: File library administration. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!--- set up page header --->
<admin:header title="File Admin" />

<ft:objectadmin 
	typename="dmFile"
	permissionset="news"
	title="#application.rb.getResource("MediaLibraryFileAdministration")#"
	columnList="title,datetimelastUpdated,status"   
	sortableColumns="title,datetimelastUpdated,status"
	lFilterFields="title"
	sqlorderby="datetimelastUpdated desc"
	module="customlists/dmfile.cfm" />

<admin:footer />
