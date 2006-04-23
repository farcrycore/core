<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_tree/getRootNode.cfm,v 1.6 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: getRootNode Function $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfquery datasource="#arguments.dsn#" name="qRoot">
SELECT * FROM #application.dbowner#nested_tree_objects
WHERE 	nlevel = 0
AND typename = '#arguments.typename#'
</cfquery>

<cfif qRoot.recordcount gt 1>
	<cfthrow errorcode="utils.tree" detail="getRootNode(): Returned multiple roots for '#arguments.typename#'.  Nested tree model is corrupt.">
</cfif>

<!--- set return variable --->
<cfset qReturn=qRoot>

<cfsetting enablecfoutputonly="no">