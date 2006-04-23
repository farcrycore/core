<!--- @@displayname: Unlock Objects --->

<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>

<cfinvoke component="#application.packagepath#.farcry.locking" method="scheduledUnlock" returnvariable="scheduledUnlockRet">
	<cfinvokeargument name="days" value="0"/>
</cfinvoke>

<cfdump var="#scheduledUnlockRet#">

</body>
</html>
