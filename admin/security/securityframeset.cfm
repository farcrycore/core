<cfsetting enablecfoutputonly="Yes">

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>#application.applicationname# Administration</title>
	<link href="#application.url.farcry#/css/admin.css" rel="stylesheet" type="text/css">
</head>

<FRAMESET COLS="270, *">
	<FRAME SRC="securityMenuFrame.cfm" name="securityMenuFrame" class="LeftFrame" frameborder="no">
	<FRAME SRC="securityHome.cfm" name="editFrame" frameborder="no">
</FRAMESET><noframes></noframes> 

</html>

</cfoutput>
<cfsetting enablecfoutputonly="No">
