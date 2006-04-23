<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/help/helpHome.cfm,v 1.2 2004/07/15 01:11:37 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:11:37 $
$Name: milestone_2-3-2 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: Home page for help tab. $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfprocessingDirective pageencoding="utf-8">

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<div><cfoutput>#application.adminBundle[session.dmProfile.locale].helpHomePage#</cfoutput></div>

<admin:footer>