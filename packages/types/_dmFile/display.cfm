<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmFile/display.cfm,v 1.3 2003/09/10 23:46:11 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 23:46:11 $
$Name: b201 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: dmFile display method$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<cflocation url="#application.url.webroot#/download.cfm?DownloadFile=#stobj.objectid#" addtoken="no">
	
<cfsetting enablecfoutputonly="No">