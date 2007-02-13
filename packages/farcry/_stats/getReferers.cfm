<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_stats/getReferers.cfm,v 1.5 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: Shows referers$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfimport taglib="/farcry/core/packages/fourq/tags" prefix="q4">

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

