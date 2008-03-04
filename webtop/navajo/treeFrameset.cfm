<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html dir="#session.writingDir#" lang="#session.userLanguage#">
<head>
	<title>#application.rb.formatRBString("appNameAdministration","#application.applicationname#")#</title>
	<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
	<meta content="text/html; charset=UTF-8" http-equiv="content-type">
</head>

<FRAMESET COLS="270, *">
	<FRAME SRC="overview_frame.cfm" name="treeFrame" class="LeftFrame" FRAMEBORDER = "no">
	<FRAME SRC="navajoHome.cfm" name="editFrame" FRAMEBORDER = "no">
</FRAMESET><noframes></noframes> 

</html>

</cfoutput>
<cfsetting enablecfoutputonly="No">
