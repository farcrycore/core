<cfsetting enablecfoutputonly="true" />
<cfprocessingDirective pageencoding="utf-8" />
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| DESCRIPTION || 
$DESCRIPTION: Displays summary and options for editing/approving/previewing etc for selected object $
$TODO:
- Remove inline styles
- Remove remote references to YUI files
- basically rewrite.. this is horrible
GB 20071015 $

|| DEVELOPER ||
$DEVELOPER: Mat Bryant (mbryant@daemon.com.au)$
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<cfset q4 = createObject("component","farcry.core.packages.fourq.fourq")>
<cfset typename = q4.findType(url.objectid)>
<cfset o = createObject("component",application.types['#typename#'].typepath)>
<cfset stObject = o.getData(objectid)>

<!--- <cflocation url="http://agora.local/scratch/checkWebtopHTML.cfm"> --->
<!--- <admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#" onload="setupPanes('container1','tab1');" /> --->
<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
            "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title>Edit Tab Overview</title>
	<!-- Source File -->
	<link rel="stylesheet" type="text/css" href="#application.url.farcry#/css/yui/reset-fonts.css">

	<link rel="stylesheet" type="text/css" href="#application.url.farcry#/css/webtopOverview.css">
	
	<script language="JavaScript" type="text/javascript" src="#application.url.farcry#/js/webtopOverview.cfm"></script>
	
</head>
<body>
</cfoutput>



<sec:CheckPermission error="true" permission="ObjectOverviewTab">
	<skin:view objectid="#url.objectid#" webskin="renderWebtopOverview" />
</sec:CheckPermission>

<!--- setup footer --->
<!--- <admin:footer>	 --->
<cfoutput>
</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="false" />
