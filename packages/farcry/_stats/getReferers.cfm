<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getReferers.cfm,v 1.4 2003/09/10 12:21:48 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 12:21:48 $
$Name: b201 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Shows referers$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfimport taglib="/farcry/fourq/tags" prefix="q4">

<!--- get maxrows if not defined --->
<cfif arguments.maxRows eq "all">
	<cfquery datasource="#arguments.dsn#" name="qMax">
		SELECT count(logid) as maxrows
		FROM #application.dbowner#stats
	</cfquery>
	<cfset arguments.maxrows = qMax.maxrows>
</cfif>

<!--- get downloads from stats --->
<cfquery datasource="#arguments.dsn#" name="qGetReferers" maxrows="#arguments.maxRows#">
	SELECT referer, count(logId) as count_referers
	FROM #application.dbowner#stats
	WHERE referer <> 'unknown'
	<cfif arguments.dateRange neq "all">
		AND logDateTime > #dateAdd("#arguments.dateRange#",-1,now())#
	</cfif>
	<cfif arguments.filter neq "all">
		AND referer not like '%#arguments.filter#%'
	</cfif>
	GROUP By referer
	ORDER BY count_referers DESC
</cfquery>

