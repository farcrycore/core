<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| DESCRIPTION ||
$Description: Workflow Definitions. $

|| DEVELOPER ||
$Developer: Matthew Bryant (mbryant@daemon.com.au) $
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!--- set up page header --->
<admin:header title="Workflow Definitions" />

<ft:objectadmin 
	typename="farWorkflowDef"
	title="Workflow Definitions"
	columnList="title" 
	sortableColumns="title"
	lFilterFields="title"
	sqlorderby="title asc" />

<admin:footer />