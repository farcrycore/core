<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/logSearch.cfm,v 1.1 2003/09/04 06:34:01 brendan Exp $
$Author: brendan $
$Date: 2003/09/04 06:34:01 $
$Name: b201 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: Logs searches performed by user within the site$
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
		insert into #application.dbowner#statsSearch
		(logID,logdatetime,searchString,lCollections,results,referer,locale,remoteip)
		values
		(<cfoutput>'#CreateUUID()#',#createodbcdatetime(now())#,'#arguments.searchString#','#arguments.lCollections#',#arguments.results#,'#arguments.referer#','#session.userLocale#','#arguments.remoteIP#'</cfoutput>)
	</cfquery>
	<cfcatch>
	<cfoutput>
		#cfcatch.detail#
	</cfoutput>
	</cfcatch>
</cftry>
