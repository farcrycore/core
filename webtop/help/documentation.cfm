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
		<div class="formtitle">#application.rb.getResource("documentation")#</div>
		
		<div style="padding-left:30px;padding-bottom:30px;">
		<!--- contributor guide --->
		<strong>#application.rb.getResource("contributorsGuide")#</strong><br />
		<p>#application.rb.getResource("farcryIsEasyBlurb")#</p>
		<p><span class="frameMenuBullet">&raquo;</span> <a href="http://farcry.daemon.com.au/go/documentation/users">#application.rb.getResource("downloadContributorGuide")#</a></p>
		</div>
	
		<div style="padding-left:30px;padding-bottom:30px;">
		<!--- admin guide --->
		<strong>#application.rb.getResource("adminGuide")#</strong><br />
		<p>#application.rb.getResource("farcryAdminIsEasyBlurb")#</p>
		<p><span class="frameMenuBullet">&raquo;</span> <a href="http://farcry.daemon.com.au/go/documentation/developers/admin-guide">#application.rb.getResource("downloadAdminGuide")#</a></p>
		</div>
		
		<div style="padding-left:30px;padding-bottom:30px;">
		<!--- developer guide --->
		<strong>#application.rb.getResource("developerGuides")#</strong><br />
		
		<p><span class="frameMenuBullet">&raquo;</span> <a href="http://farcry.daemon.com.au/go/documentation/developers/how-to">#application.rb.getResource("howTo")#</a></p>
		<p><span class="frameMenuBullet">&raquo;</span> <a href="http://farcry.daemon.com.au/go/documentation/developers/tech-notes">#application.rb.getResource("techNotes")#</a></p>
		</div>
	</cfoutput>	
</sec:CheckPermission>

<admin:footer>