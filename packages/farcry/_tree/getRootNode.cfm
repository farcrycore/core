<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_tree/getRootNode.cfm,v 1.4 2003/03/31 02:36:04 internal Exp $
$Author: internal $
$Date: 2003/03/31 02:36:04 $
$Name: b131 $
$Revision: 1.4 $

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

<cfquery datasource="#stArgs.dsn#" name="qRoot">
SELECT * FROM #application.dbowner#nested_tree_objects
WHERE 	nlevel = 0
AND typename = '#stArgs.typename#'
</cfquery>

<cfif qRoot.recordcount gt 1>
	<cfthrow errorcode="utils.tree" detail="getRootNode(): Returned multiple roots for '#stArgs.typename#'.  Nested tree model is corrupt.">
</cfif>

<!--- set return variable --->
<cfset qReturn=qRoot>

<cfsetting enablecfoutputonly="no">