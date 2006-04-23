<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_tree/getRootNode.cfm,v 1.5 2003/09/10 12:21:48 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 12:21:48 $
$Name: b201 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: getRootNode Function $
$TODO: $

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