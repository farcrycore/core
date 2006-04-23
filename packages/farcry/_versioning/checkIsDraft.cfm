<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_versioning/checkIsDraft.cfm,v 1.1 2003/03/21 05:35:19 brendan Exp $
$Author: brendan $
$Date: 2003/03/21 05:35:19 $
$Name: b131 $
$Revision: 1.1 $

|| DESCRIPTION || 
Checks to see if object is an underlying draft object

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: 
out:
--->

<!--- check not already a draft version --->
<cfquery datasource="#stargs.dsn#" name="qCheckIsDraft">
	SELECT objectID,status from #application.dbowner##stargs.type# where versionID = '#stargs.objectID#' 
</cfquery>