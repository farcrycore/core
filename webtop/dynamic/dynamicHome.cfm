<cfoutput>
<html dir="#session.writingDir#" lang="#session.userLanguage#">
<head>
<title>Untitled Document</title>
	<LINK href="../css/admin.css" rel="stylesheet" type="text/css">
	<meta content="text/html; charset=UTF-8" http-equiv="content-type">
</head>

<body>

<div>#apapplication.rb.getResource("dynamicHomePage")#</div>

</body>
</html>
</cfoutput>