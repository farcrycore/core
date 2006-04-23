<cfoutput><html dir="#session.writingDir#" lang="#session.userLanguage#"></cfoutput>
<head>
<title>Untitled Document</title>
<meta content="text/html; charset=UTF-8" http-equiv="content-type">
<LINK href="../css/admin.css" rel="stylesheet" type="text/css">
</head>

<body>

<div><cfoutput>#application.adminBundle[session.dmProfile.locale].adminHomePage#</cfoutput></div>

</body>
</html>
