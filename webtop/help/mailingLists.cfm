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
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
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
		<div class="formtitle">#application.rb.getResource("mailingLists")#</div>
		
		<div style="padding-left:30px;padding-bottom:30px;padding-right:30px;">
		<p>#application.rb.getResource("farcryListBlurb")#</p>
		<p>&nbsp;</p>
		
		<div class="formtitle">farcry-dev (public)</div>
		
		<span class="frameMenuBullet">&raquo;</span> <a href="mailto:farcry-dev@lists.daemon.com.au">farcry-dev@lists.daemon.com.au</a>
		<p>#application.rb.getResource("farcryDevListBlurb")#</p>
		<ul>
		    <li>#application.rb.getResource("joinDevList")#</li>
		    <li>#application.rb.getResource("webBasedDevList")#</li>
		    <li>#application.rb.getResource("nntpDevList")#</li>
		</ul>
		
		<p>&nbsp;</p>
		<div class="formtitle">farcry-user (public)</div>
		
		<span class="frameMenuBullet">&raquo;</span> <a href="mailto:farcry-user@lists.daemon.com.au">farcry-user@lists.daemon.com.au</a>
		<p>#application.rb.getResource("farcryUserListBlurb")#</p>
		<ul>
		    <li>#application.rb.getResource("joinUserList")#</li>
		    <li>#application.rb.getResource("webBasedUserList")#</li>
		    <li>#application.rb.getResource("nntpUserList")#</li>
		</ul>
		
		</div>
	</cfoutput>
</sec:CheckPermission>

<admin:footer>