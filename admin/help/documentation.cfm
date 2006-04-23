<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/help/documentation.cfm,v 1.2 2003/10/01 07:04:48 brendan Exp $
$Author: brendan $
$Date: 2003/10/01 07:04:48 $
$Name: b201 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: documentation page for help tab. $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- check permissions --->
<cfscript>
	iHelpTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="MainNavHelpTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iHelpTab eq 1>
	<div class="formtitle">Documentation</div>
	
	<div style="padding-left:30px;padding-bottom:30px;">
	<!--- contributor guide --->
	<strong>Contributors Guide</strong><br/>
	<p>FarCry is designed with non-technical users in mind. The Contributor and Editor Guide is your one stop shop for making the most of your FarCry installation. Download this baby for some light bed time reading.</p>
	<p><span class="frameMenuBullet">&raquo;</span> <a href="http://farcry.daemon.com.au/go/documentation/users">Download Contributor Guide</a></p>
	</div>
	
	<div style="padding-left:30px;padding-bottom:30px;">
	<!--- admin guide --->
	<strong>Admin Guide</strong><br/>
	<p>Looking after content contributors is like herding cats. This guide is aimed at Administrators who want to maintain the smooth and efficient running of their FarCry deployment. Look to this guide for a riveting read on Farcry admin options.</p>
	<p><span class="frameMenuBullet">&raquo;</span> <a href="http://farcry.daemon.com.au/go/documentation/developers/admin-guide">Download Administrator Guide</a></p>
	</div>
	
	<div style="padding-left:30px;padding-bottom:30px;">
	<!--- developer guide --->
	<strong>Developer Guides</strong><br/>
	
	<p><span class="frameMenuBullet">&raquo;</span> <a href="http://farcry.daemon.com.au/go/documentation/developers/how-to">How To's</a></p>
	<p><span class="frameMenuBullet">&raquo;</span> <a href="http://farcry.daemon.com.au/go/documentation/developers/tech-notes">Tech Notes</a></p>
	</div>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>