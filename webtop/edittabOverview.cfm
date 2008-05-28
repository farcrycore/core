<cfsetting enablecfoutputonly="true" />
<cfprocessingDirective pageencoding="utf-8" />
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
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
