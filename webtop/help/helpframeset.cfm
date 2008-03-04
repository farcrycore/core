<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/help/helpframeset.cfm,v 1.3 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: Help tab frameset$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html dir="#session.writingDir#" lang="#session.userLanguage#">
<head>
	<title>#apapplication.rb.getResource("appNameAdministration")#</title>
	<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
	<meta content="text/html; charset=UTF-8" http-equiv="content-type">
</head>

<FRAMESET COLS="270, *">
	<FRAME SRC="helpMenuFrame.cfm" name="reportingMenuFrame" class="LeftFrame" frameborder="no">
	<FRAME SRC="helpHome.cfm" name="editFrame" frameborder="no">
</FRAMESET><noframes></noframes> 

</html>

</cfoutput>
<cfsetting enablecfoutputonly="No">
