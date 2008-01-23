<cfprocessingDirective pageencoding="utf-8">
<cfoutput><html dir="#session.writingDir#" lang="#session.userLanguage#"></cfoutput>
<head>
<title>Untitled Document</title>
<meta content="text/html; charset=UTF-8" http-equiv="content-type">
</head>

<body>
<cfinvoke 
 component="#application.packagepath#.farcry.category"
 method="displayTree">
	
</cfinvoke>

</body>
</html>
