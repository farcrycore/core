<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getLocales.cfm,v 1.3 2003/05/12 02:45:09 brendan Exp $
$Author: brendan $
$Date: 2003/05/12 02:45:09 $
$Name: b131 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: Shows locales$
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
<cfquery datasource="#stArgs.dsn#" name="qGetLocales" maxrows="#stArgs.maxRows#">
	SELECT locale, count(distinct sessionid) as count_locale, country 
	FROM #application.dbowner#Stats s,#application.dbowner#StatsCountries
	WHERE locale <> 'unknown' and isocode = right(locale,2)
	<cfif stArgs.dateRange neq "all">
		AND logDateTime > #dateAdd("#stArgs.dateRange#",-1,now())#
	</cfif>
	GROUP By locale,country
	ORDER BY count_locale DESC
</cfquery>

