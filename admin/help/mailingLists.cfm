<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/help/mailingLists.cfm,v 1.3 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-0 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: mailing list page for help tab. $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iHelpTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="MainNavHelpTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iHelpTab eq 1>
<cfoutput>
	<div class="formtitle">#application.adminBundle[session.dmProfile.locale].mailingLists#</div>
	
	<div style="padding-left:30px;padding-bottom:30px;padding-right:30px;">
	<p>#application.adminBundle[session.dmProfile.locale].farcryListBlurb#</p>
	<p>&nbsp;</p>
	
	<div class="formtitle">farcry-dev (public)</div>
	
	<span class="frameMenuBullet">&raquo;</span> <a href="mailto:farcry-dev@lists.daemon.com.au">farcry-dev@lists.daemon.com.au</a>
	<p>#application.adminBundle[session.dmProfile.locale].farcryDevListBlurb#</p>
	<ul>
	    <li>#application.adminBundle[session.dmProfile.locale].joinDevList#</li>
	    <li>#application.adminBundle[session.dmProfile.locale].webBasedDevList#</li>
	    <li>#application.adminBundle[session.dmProfile.locale].nntpDevList#</li>
	</ul>
	
	<p>&nbsp;</p>
	<div class="formtitle">farcry-user (public)</div>
	
	<span class="frameMenuBullet">&raquo;</span> <a href="mailto:farcry-user@lists.daemon.com.au">farcry-user@lists.daemon.com.au</a>
	<p>#application.adminBundle[session.dmProfile.locale].farcryUserListBlurb#</p>
	<ul>
	    <li>#application.adminBundle[session.dmProfile.locale].joinUserList#</li>
	    <li>#application.adminBundle[session.dmProfile.locale].webBasedUserList#</li>
	    <li>#application.adminBundle[session.dmProfile.locale].nntpUserList#</li>
	</ul>
	
	</div>
</cfoutput>
<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>