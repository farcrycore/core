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
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_stats/getActiveVisitors.cfm,v 1.9 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.9 $

|| DESCRIPTION || 
$Description: Shows active sessions$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- get active sessions structure (thanks to Sam at RewindLife sam@rewindlife.com) --->
<cftry>
<cflock name="getActiveVisitors"  throwontimeout="Yes" timeout="120" type="EXCLUSIVE">
<cfscript>
	tracker = createObject("java", "coldfusion.runtime.SessionTracker");
	sessions = tracker.getSessionCollection(application.applicationName);
	qSessions = queryNew("sessionId,remoteIP,views,locale,sessionTime,lastActivity");
</cfscript>

<!--- loop through sessions and get session details --->
<cfloop collection="#sessions#" item="i">
	<cfif structKeyExists(sessions[i],"startTime")>
		
		<!--- get pages viewed --->
		<cfquery name="qViews" datasource="#arguments.dsn#">
			select count(pageId) as views, max(logDateTime) as lastActivity, locale
			from #application.dbowner#stats
			WHERE sessionId = '#sessions[i].statsSession#'
			AND navid <> pageId
			group by sessionid,locale
		</cfquery>
		
		<!--- set up return structure --->
				
		
		<cfscript>
			
			queryAddRow(qSessions, 1);
			querySetCell(qSessions, "sessionId", sessions[i].statsSession);
			querySetCell(qSessions, "remoteIP", sessions[i].remoteIP);
			if(isNumeric(qViews.views))
				querySetCell(qSessions, "views", qViews.views);
			else
				querySetCell(qSessions, "views", 1);	
			querySetCell(qSessions,"locale", toString(qViews.locale));
			querySetCell(qSessions, "sessionTime",dateDiff("n", sessions[i].startTime, now()));
			if(qViews.recordcount EQ 1 AND isDate(qViews.lastActivity))
				querySetCell(qSessions, "lastActivity",dateDiff("n", qViews.lastActivity, now()));
			else
				querySetCell(qSessions, "lastActivity",dateDiff("n", sessions[i].startTime, now()));				
		</cfscript>
		
	</cfif>
</cfloop>

<cfif qSessions.recordcount>
	<!--- sort results --->
	<cfquery name="qActive" dbtype="query">
		select *
		from qSessions
		order by #arguments.order# #arguments.orderDirection#
	</cfquery>
<cfelse>
	<cfset qActive = queryNew("sessionId,remoteIP,views,locale,sessionTime,lastActivity")>
</cfif>
</cflock>   

<cfcatch>
	<cfdump var="#cfcatch#">
</cfcatch>
</cftry>
 