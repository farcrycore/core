<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_tree/getChildren.cfm,v 1.5 2003/03/31 02:36:03 internal Exp $
$Author: internal $
$Date: 2003/03/31 02:36:03 $
$Name: b131 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: getChildren Function $
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfscript>
sql = "select objectid, objectname from nested_tree_objects
		where parentid =  '#stArgs.objectid#'
		order by nleft";
children = query(sql=sql, dsn=stArgs.dsn);		
</cfscript>

<!--- set return variable --->
<cfset qReturn=children>

<cfsetting enablecfoutputonly="no">