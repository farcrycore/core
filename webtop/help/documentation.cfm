<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/help/documentation.cfm,v 1.5 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: documentation page for help tab. $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- check permissions --->

<cfprocessingDirective pageencoding="utf-8">

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec">

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="MainNavHelpTab">
	<cfoutput>
		<div class="formtitle">#apapplication.rb.getResource("documentation")#</div>
		
		<div style="padding-left:30px;padding-bottom:30px;">
		<!--- contributor guide --->
		<strong>#apapplication.rb.getResource("contributorsGuide")#</strong><br />
		<p>#apapplication.rb.getResource("farcryIsEasyBlurb")#</p>
		<p><span class="frameMenuBullet">&raquo;</span> <a href="http://farcry.daemon.com.au/go/documentation/users">#apapplication.rb.getResource("downloadContributorGuide")#</a></p>
		</div>
	
		<div style="padding-left:30px;padding-bottom:30px;">
		<!--- admin guide --->
		<strong>#apapplication.rb.getResource("adminGuide")#</strong><br />
		<p>#apapplication.rb.getResource("farcryAdminIsEasyBlurb")#</p>
		<p><span class="frameMenuBullet">&raquo;</span> <a href="http://farcry.daemon.com.au/go/documentation/developers/admin-guide">#apapplication.rb.getResource("downloadAdminGuide")#</a></p>
		</div>
		
		<div style="padding-left:30px;padding-bottom:30px;">
		<!--- developer guide --->
		<strong>#apapplication.rb.getResource("developerGuides")#</strong><br />
		
		<p><span class="frameMenuBullet">&raquo;</span> <a href="http://farcry.daemon.com.au/go/documentation/developers/how-to">#apapplication.rb.getResource("howTo")#</a></p>
		<p><span class="frameMenuBullet">&raquo;</span> <a href="http://farcry.daemon.com.au/go/documentation/developers/tech-notes">#apapplication.rb.getResource("techNotes")#</a></p>
		</div>
	</cfoutput>	
</sec:CheckPermission>

<admin:footer>