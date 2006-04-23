<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getOS.cfm,v 1.1 2003/05/07 02:13:19 brendan Exp $
$Author: brendan $
$Date: 2003/05/07 02:13:19 $
$Name: b131 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: Shows Operating Systems$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- get maxrows if not defined --->
<cfif stArgs.maxRows eq "all">
	<cfquery datasource="#stArgs.dsn#" name="qMax">
		SELECT count(logid) as maxrows
		FROM #application.dbowner#Stats
	</cfquery>
	<cfset stArgs.maxrows = qMax.maxrows>
</cfif>

<!--- get downloads from stats --->
<cfquery datasource="#stArgs.dsn#" name="qGetOS" maxrows="#stArgs.maxRows#">
	SELECT os, count(distinct sessionid) as count_os
	FROM #application.dbowner#Stats
	WHERE os <> 'unknown'
	<cfif stArgs.dateRange neq "all">
		AND logDateTime > #dateAdd("#stArgs.dateRange#",-1,now())#
	</cfif>
	GROUP By os
	ORDER BY count_os DESC
</cfquery>

