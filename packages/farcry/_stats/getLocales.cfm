<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_stats/getLocales.cfm,v 1.10 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.10 $

|| DESCRIPTION || 
$Description: Shows locales$


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
			WHERE locale <> 'unknown' and isocode = upper(SUBSTR(locale,char_length(locale)-1,2))
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


