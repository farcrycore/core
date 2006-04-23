<cfprocessingDirective pageencoding="utf-8">
<cfoutput>
<html dir="#session.writingDir#" lang="#session.userLanguage#">
<head>
<title>Untitled Document</title>
<meta content="text/html; charset=UTF-8" http-equiv="content-type">
<LINK href="../css/admin.css" rel="stylesheet" type="text/css">
</head>
<body>
<div>#application.adminBundle[session.dmProfile.locale].securityHomePage#</div>
</body>
</html>
</cfoutput>