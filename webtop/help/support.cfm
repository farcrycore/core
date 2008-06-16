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
$Header: /cvs/farcry/core/webtop/help/support.cfm,v 1.3 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: support page for help tab. $


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
		<div class="formtitle">#application.rb.getResource("commericalSupport")#</div>
		
		<div style="padding-left:30px;padding-bottom:30px;">
		<a href="http://www.daemon.com.au" target="_blank"><img src="../images/daemon_logo.gif" alt="Daemon Internet Consultants" border="0"></a>
		#application.rb.getResource("iLoveDaemonBlurb")#	
		<p><span class="frameMenuBullet">&raquo;</span> <a href="http://www.daemon.com.au/go/farcry-support">#application.rb.getResource("daemonCommercialFarcrySupport")#</a></p>
		</div>
	</cfoutput>
</sec:CheckPermission>

<admin:footer>
