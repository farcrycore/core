<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getDownloadStats.cfm,v 1.4 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-0 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Works out downloaded files, name and stats$


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