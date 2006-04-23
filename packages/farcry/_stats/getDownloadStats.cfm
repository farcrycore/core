<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getDownloadStats.cfm,v 1.3 2003/09/10 12:21:48 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 12:21:48 $
$Name: b201 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: Works out downloaded files, name and stats$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- get all downloads from stats --->
<cfquery datasource="#arguments.dsn#" name="qGetDownloadStats">
	SELECT pageid, count(logId) as count_downloads, title
	FROM stats, dmFile
	WHERE navid = pageid
	AND objectid = pageid
	GROUP By pageid, title
	ORDER BY count_downloads DESC
</cfquery>