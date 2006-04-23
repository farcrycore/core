<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getDownloadStats.cfm,v 1.1 2003/04/08 01:42:06 brendan Exp $
$Author: brendan $
$Date: 2003/04/08 01:42:06 $
$Name: b131 $
$Revision: 1.1 $

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
<cfquery datasource="#stArgs.dsn#" name="qGetDownloadStats">
	SELECT pageid, count(logId) as count_downloads, title
	FROM Stats, dmFile
	WHERE navid = pageid
	AND objectid = pageid
	GROUP By pageid, title
	ORDER BY count_downloads DESC
</cfquery>