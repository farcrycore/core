<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_versioning/checkIsDraft.cfm,v 1.2 2003/09/10 12:21:48 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 12:21:48 $
$Name: b201 $
$Revision: 1.2 $

|| DESCRIPTION || 
Checks to see if object is an underlying draft object

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: 
out:
--->

<!--- check not already a draft version --->
<cfquery datasource="#arguments.dsn#" name="qCheckIsDraft">
	SELECT objectID,status from #application.dbowner##arguments.type# where versionID = '#arguments.objectID#' 
</cfquery>