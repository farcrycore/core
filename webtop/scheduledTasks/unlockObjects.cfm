<cfprocessingDirective pageencoding="utf-8">

<!--- @@displayname: Unlock Objects --->

<cfoutput><html dir="#session.writingDir#" lang="#session.userLanguage#"></cfoutput>
<head>
<title>Untitled Document</title>
<meta content="text/html; charset=UTF-8" http-equiv="content-type">
</head>

<body>

<cfinvoke component="#application.packagepath#.farcry.locking" method="scheduledUnlock" returnvariable="scheduledUnlockRet">
	<cfinvokeargument name="days" value="0"/>
</cfinvoke>

<cfdump var="#scheduledUnlockRet#">

</body>
</html>
