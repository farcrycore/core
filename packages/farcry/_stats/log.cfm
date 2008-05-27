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
$Header: /cvs/farcry/core/packages/farcry/_stats/log.cfm,v 1.11 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.11 $

|| DESCRIPTION || 
$Description: Logs visit of page including pageId, navid,ip address and user (if applicable) $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cftry>
	<!--- insert log entry --->
	<cfquery name="qInsertLog" datasource="#arguments.dsn#">
		insert into #application.dbowner#stats
		(logID,logdatetime,pageID,navid,remoteip,userid,sessionId,browser,referer,locale,os)
		values
		(<cfoutput>'#CreateUUID()#',#createodbcdatetime(now())#,'#arguments.pageID#','#arguments.navid#','#arguments.remoteip#','#arguments.userid#','#arguments.sessionId#','#arguments.browser#','#arguments.referer#','#arguments.locale#','#arguments.os#'</cfoutput>)
	</cfquery>
	<cfcatch></cfcatch>
</cftry>
