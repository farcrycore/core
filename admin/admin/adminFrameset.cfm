<cfsetting enablecfoutputonly="Yes">
<cfprocessingDirective pageencoding="utf-8">

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html dir="#session.writingDir#" lang="#session.userLanguage#">
<head>
	<title>#application.applicationName# Administration</title>
	<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
	<meta content="text/html; charset=UTF-8" http-equiv="content-type">
</head>

<FRAMESET COLS="270, *">
	<FRAME SRC="adminMenuFrame.cfm" name="adminMenuFrame" class="LeftFrame" frameborder="no">
	<FRAME SRC="adminHome.cfm" name="editFrame" frameborder="no">
</FRAMESET><noframes></noframes> 

</html>

</cfoutput>
<cfsetting enablecfoutputonly="No">

