<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/log.cfm,v 1.8 2003/05/07 01:34:58 brendan Exp $
$Author: brendan $
$Date: 2003/05/07 01:34:58 $
$Name: b131 $
$Revision: 1.8 $

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
	<cfquery name="qInsertLog" datasource="#stArgs.dsn#">
		insert into #application.dbowner#stats
		(logID,logdatetime,pageID,navid,remoteip,userid,sessionId,browser,referer,locale,os)
		values
		(<cfoutput>'#CreateUUID()#',#createodbcdatetime(now())#,'#stArgs.pageID#','#stArgs.navid#','#stArgs.remoteip#','#stArgs.userid#','#stArgs.sessionId#','#stArgs.browser#','#stArgs.referer#','#stArgs.locale#','#stArgs.os#'</cfoutput>)
	</cfquery>
	<cfcatch>
	<cfoutput>
		#cfcatch.detail#
	</cfoutput>
	</cfcatch>
</cftry>
