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

<cfset aCustomColumns = arraynew(1) />
<cfset aCustomColumns[1] = structnew() />
<cfset aCustomColumns[1].webskin = "displayRelatedTypes" />
<cfset aCustomColumns[1].title = "Join on" />
<cfset aCustomColumns[1].sortable = false />

<ft:objectadmin 
	typename="farPermission"
	permissionset="news"
	title="Permission Admin"
	columnList="title"
	aCustomColumns="#aCustomColumns#"
	sortableColumns="title"
	lFilterFields="title"
	sqlorderby="title asc" />

<admin:footer />

