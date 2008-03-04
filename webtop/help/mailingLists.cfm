<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/help/mailingLists.cfm,v 1.3 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
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

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec">

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="MainNavHelpTab">
	<cfoutput>
		<div class="formtitle">#apapplication.rb.getResource("mailingLists")#</div>
		
		<div style="padding-left:30px;padding-bottom:30px;padding-right:30px;">
		<p>#apapplication.rb.getResource("farcryListBlurb")#</p>
		<p>&nbsp;</p>
		
		<div class="formtitle">farcry-dev (public)</div>
		
		<span class="frameMenuBullet">&raquo;</span> <a href="mailto:farcry-dev@lists.daemon.com.au">farcry-dev@lists.daemon.com.au</a>
		<p>#apapplication.rb.getResource("farcryDevListBlurb")#</p>
		<ul>
		    <li>#apapplication.rb.getResource("joinDevList")#</li>
		    <li>#apapplication.rb.getResource("webBasedDevList")#</li>
		    <li>#apapplication.rb.getResource("nntpDevList")#</li>
		</ul>
		
		<p>&nbsp;</p>
		<div class="formtitle">farcry-user (public)</div>
		
		<span class="frameMenuBullet">&raquo;</span> <a href="mailto:farcry-user@lists.daemon.com.au">farcry-user@lists.daemon.com.au</a>
		<p>#apapplication.rb.getResource("farcryUserListBlurb")#</p>
		<ul>
		    <li>#apapplication.rb.getResource("joinUserList")#</li>
		    <li>#apapplication.rb.getResource("webBasedUserList")#</li>
		    <li>#apapplication.rb.getResource("nntpUserList")#</li>
		</ul>
		
		</div>
	</cfoutput>
</sec:CheckPermission>

<admin:footer>