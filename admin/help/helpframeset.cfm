<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/help/helpframeset.cfm,v 1.1 2003/09/17 04:53:30 brendan Exp $
$Author: brendan $
$Date: 2003/09/17 04:53:30 $
$Name: b201 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: Help tab frameset$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>#application.applicationname# Administration</title>
	<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
</head>

<FRAMESET COLS="270, *">
	<FRAME SRC="helpMenuFrame.cfm" name="reportingMenuFrame" class="LeftFrame" frameborder="no">
	<FRAME SRC="helpHome.cfm" name="editFrame" frameborder="no">
</FRAMESET><noframes></noframes> 

</html>

</cfoutput>
<cfsetting enablecfoutputonly="No">
