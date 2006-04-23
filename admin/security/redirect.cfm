
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="<cfoutput>#application.url.farcry#</cfoutput>/css/admin.css" rel="stylesheet" type="text/css">
<!--// load the qForm JavaScript API //-->
<SCRIPT SRC="<cfoutput>#application.url.farcry#</cfoutput>/includes/lib/qforms.js"></SCRIPT>
<!--// you do not need the code below if you plan on just
       using the core qForm API methods. //-->
<!--// [start] initialize all default extension libraries  //-->
<SCRIPT LANGUAGE="JavaScript">
<!--//
// specify the path where the "/qforms/" subfolder is located
qFormAPI.setLibraryPath("<cfoutput>#application.url.farcry#</cfoutput>/includes/lib/");
// loads all default libraries
qFormAPI.include("*");
//-->


</SCRIPT>
<!--// [ end ] initialize all default extension libraries  //-->
</head>

<body>
<cfmodule template="/farcry/farcry_core/tags/security/ui/dmSecUI_Redirect.cfm">

</body>
</html>
