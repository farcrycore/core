<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/log.cfm,v 1.10 2003/10/15 01:15:05 brendan Exp $
$Author: brendan $
$Date: 2003/10/15 01:15:05 $
$Name: b201 $
$Revision: 1.10 $

|| DESCRIPTION || 
$Description: Logs visit of page including pageId, navid,ip address and user (if applicable) $
$TODO: $

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
