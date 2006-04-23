<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getOS.cfm,v 1.3 2003/09/10 12:21:48 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 12:21:48 $
$Name: b201 $
$Revision: 1.3 $

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
<cfif arguments.maxRows eq "all">
	<cfquery datasource="#arguments.dsn#" name="qMax">
		SELECT count(logid) as maxrows
		FROM #application.dbowner#stats
	</cfquery>
	<cfset arguments.maxrows = qMax.maxrows>
</cfif>

<!--- get downloads from stats --->
<cfquery datasource="#arguments.dsn#" name="qGetOS" maxrows="#arguments.maxRows#">
	SELECT os, count(distinct sessionid) as count_os
	FROM #application.dbowner#stats
	WHERE os <> 'unknown'
	<cfif arguments.dateRange neq "all">
		AND logDateTime > #dateAdd("#arguments.dateRange#",-1,now())#
	</cfif>
	GROUP By os
	ORDER BY count_os DESC
</cfquery>

