<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/logSearch.cfm,v 1.3 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: Logs searches performed by user within the site$


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
		(<cfoutput>'#CreateUUID()#',#createodbcdatetime(now())#,'#arguments.searchString#','#arguments.lCollections#',#arguments.results#,'#arguments.referer#','#session.dmProfile.locale#','#arguments.remoteIP#'</cfoutput>)
	</cfquery>
	<cfcatch>
	<cfoutput>
		#cfcatch.detail#
	</cfoutput>
	</cfcatch>
</cftry>
