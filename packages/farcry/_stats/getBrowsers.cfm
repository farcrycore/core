<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getBrowsers.cfm,v 1.4 2003/06/05 03:00:56 brendan Exp $
$Author: brendan $
$Date: 2003/06/05 03:00:56 $
$Name: b131 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Shows browser types used$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- get browsers from stats --->

<cfquery name="qVisitors" datasource="#stArgs.dsn#">
	select browser, count(distinct sessionid) as views
	from #application.dbowner#stats
	WHERE 1=1
	<cfif stArgs.dateRange neq "all">
		AND logDateTime > #dateAdd("#stArgs.dateRange#",-1,now())#
	</cfif>
	AND browser <> 'unknown'
	GROUP BY browser	
	ORDER BY views DESC
</cfquery>
