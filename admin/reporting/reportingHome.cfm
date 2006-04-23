<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/reporting/reportingHome.cfm,v 1.2 2004/07/15 01:51:48 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:51:48 $
$Name: milestone_2-3-2 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: Home page for reporting tab. $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfprocessingDirective pageencoding="utf-8">

<cfoutput>
<html dir="#session.writingDir#" lang="#session.userLanguage#">
<head>
<title>Untitled Document</title>
<meta content="text/html; charset=UTF-8" http-equiv="content-type">
<LINK href="../css/admin.css" rel="stylesheet" type="text/css">
</head>

<body>

<div>#application.adminBundle[session.dmProfile.locale].reportingHomePage#</div>

</body>
</html>
</cfoutput>
