<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getActiveVisitors.cfm,v 1.6 2003/10/24 02:17:07 paul Exp $
$Author: paul $
$Date: 2003/10/24 02:17:07 $
$Name: b201 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: Shows active sessions$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- get active sessions structure (thanks to Sam at RewindLife sam@rewindlife.com) --->
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
			querySetCell(qSessions, "locale", qViews.locale);
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