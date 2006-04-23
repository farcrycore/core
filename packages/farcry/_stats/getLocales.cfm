<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getLocales.cfm,v 1.8 2004/05/20 04:41:25 brendan Exp $
$Author: brendan $
$Date: 2004/05/20 04:41:25 $
$Name: milestone_2-2-1 $
$Revision: 1.8 $

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
<cfif arguments.maxRows eq "all">
	<cfquery datasource="#arguments.dsn#" name="qMax">
		SELECT count(logid) as maxrows
		FROM #application.dbowner#stats
	</cfquery>
	<cfset arguments.maxrows = qMax.maxrows>
</cfif>

<cfswitch expression="#application.dbtype#">
	<cfcase value="ora">
		<!--- get downloads from stats --->
		<cfquery datasource="#arguments.dsn#" name="qGetLocales" maxrows="#arguments.maxRows#">
			SELECT locale, count(distinct sessionid) as count_locale, country, isocode 
			FROM #application.dbowner#stats s,#application.dbowner#statsCountries
			WHERE locale <> 'unknown' and isocode = upper(SUBSTR(locale,-2,2))
			<cfif arguments.dateRange neq "all">
				AND logDateTime > #dateAdd("#arguments.dateRange#",-1,now())#
			</cfif>
			GROUP By locale,country, isocode
			ORDER BY count_locale DESC
		</cfquery>
	</cfcase>
	
	<cfcase value="postgresql">
		<!--- get downloads from stats --->
		<cfquery datasource="#arguments.dsn#" name="qGetLocales" maxrows="#arguments.maxRows#">
			SELECT locale, count(distinct sessionid) as count_locale, country, isocode 
			FROM #application.dbowner#stats s,#application.dbowner#statsCountries
			WHERE locale <> 'unknown' and isocode = upper(SUBSTR(locale,-2,2))
			<cfif arguments.dateRange neq "all">
				AND logDateTime > #dateAdd("#arguments.dateRange#",-1,now())#
			</cfif>
			GROUP By locale,country, isocode
			ORDER BY count_locale DESC
		</cfquery>
	</cfcase>
	
	<cfdefaultcase>
		<!--- get downloads from stats --->
		<cfquery datasource="#arguments.dsn#" name="qGetLocales" maxrows="#arguments.maxRows#">
			SELECT locale, count(distinct sessionid) as count_locale, country, isocode 
			FROM #application.dbowner#stats s,#application.dbowner#statsCountries
			WHERE locale <> 'unknown' and isocode = right(locale,2)
			<cfif arguments.dateRange neq "all">
				AND logDateTime > #dateAdd("#arguments.dateRange#",-1,now())#
			</cfif>
			GROUP By locale,country, isocode
			ORDER BY count_locale DESC
		</cfquery>
	</cfdefaultcase>

</cfswitch>


