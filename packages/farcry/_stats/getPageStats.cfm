<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getPageStats.cfm,v 1.5 2003/09/10 12:21:48 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 12:21:48 $
$Name: b201 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: gets object stats $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- get page log entries --->
<cfquery name="qGetPageStats" datasource="#arguments.dsn#">
	select * 
	from #application.dbowner#stats
	where 1 = 1
	<cfif isDefined("arguments.before")>
	AND logdatetime < #arguments.before#
	</cfif>
	<cfif isDefined("arguments.after")>
	AND logdatetime > #arguments.after#
	</cfif>
	order by logdatetime desc
</cfquery>

