<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">
<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2005, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/navajo/overview_frame.cfm,v 1.10 2005/08/28 01:34:54 geoff Exp $
$Author: geoff $
$Date: 2005/08/28 01:34:54 $
$Name: milestone_3-0-1 $
$Revision: 1.10 $

|| DESCRIPTION || 
$Description: 	Iframe for the site tree overview page.  
				Gradually trying to refactor this area but its sensitive to change. GB $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">

<cftry>
<!--- TODO: not sure how beneficial this lock is. not sure of its history either :( GB --->
<cflock timeout="0" throwontimeout="Yes" name="refreshLockout_#session.sessionId#" type="EXCLUSIVE">
	<!--- include icon image paths. sets variables.customIcons (not great GB) --->
	<cfinclude template="_customIcons.cfm">
	
	<cfoutput>
	<html dir="#session.writingDir#" lang="#session.userLanguage#">
	<HEAD>
	<TITLE>#application.adminBundle[session.dmProfile.locale].overviewTree#</TITLE>
	<LINK href="#application.url.farcry#/css/overviewFrame.css" rel="stylesheet" type="text/css">
	<meta content="text/html; charset=UTF-8" http-equiv="content-type">
	</HEAD>
		
	<body>
		<div id="tree">
			</cfoutput>
				<nj:Overview customIcons="#customIcons#">
			<cfoutput>
		</div>
	</body>
	</html>
	</cfoutput>
</cflock>

	<cfcatch type="Lock">
		<cfoutput>
		<p>#application.adminBundle[session.dmProfile.locale].overviewTreeLoadingBlurb#</p>
		<p><a href="">Refresh Tree</a></p>
		</cfoutput>
	</cfcatch>
</cftry>

<cfsetting enablecfoutputonly="No">
