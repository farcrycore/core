<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/_farcryOnRequestEnd.cfm,v 1.3 2003/04/01 01:51:15 brendan Exp $
$Author: brendan $
$Date: 2003/04/01 01:51:15 $
$Name: b131 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: Functionality to be run at the end of every page, including stats logging$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<!--- log visit to page --->
<cf_statsLog>

<cfsetting enablecfoutputonly="no">