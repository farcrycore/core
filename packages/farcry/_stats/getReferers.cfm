<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getReferers.cfm,v 1.2 2003/05/06 08:12:47 brendan Exp $
$Author: brendan $
$Date: 2003/05/06 08:12:47 $
$Name: b131 $
$Revision: 1.2 $

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
<cfif stArgs.maxRows eq "all">
	<cfquery datasource="#stArgs.dsn#" name="qMax">
		SELECT count(logid) as maxrows
		FROM #application.dbowner#Stats
	</cfquery>
	<cfset stArgs.maxrows = qMax.maxrows>
</cfif>

<!--- get downloads from stats --->
<cfquery datasource="#stArgs.dsn#" name="qGetReferers" maxrows="#stArgs.maxRows#">
	SELECT referer, count(logId) as count_referers
	FROM #application.dbowner#Stats
	WHERE referer <> 'unknown'
	<cfif stArgs.dateRange neq "all">
		AND logDateTime > #dateAdd("#stArgs.dateRange#",-1,now())#
	</cfif>
	<cfif stArgs.filter neq "all">
		AND referer not like '%#stArgs.filter#%'
	</cfif>
	GROUP By referer
	ORDER BY count_referers DESC
</cfquery>

