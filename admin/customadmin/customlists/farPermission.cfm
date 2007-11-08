<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| DESCRIPTION ||
$Description: Permission administration. $

|| DEVELOPER ||
$Developer: Blair McKenzie (blair@daemon.com.au) $
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!--- set up page header --->
<admin:header title="Permission Admin" />

<ft:objectadmin 
	typename="farPermission"
	permissionset="news"
	title="Permission Admin"
	columnList="title,relatedtypes" 
	sortableColumns="title,relatedtypes"
	lFilterFields="title"
	sqlorderby="title asc" />

<admin:footer />

