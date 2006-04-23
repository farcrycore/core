<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/help/support.cfm,v 1.1 2003/09/17 04:53:30 brendan Exp $
$Author: brendan $
$Date: 2003/09/17 04:53:30 $
$Name: b201 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: support page for help tab. $
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
	<div class="formtitle">Commerical Support</div>
	
	<div style="padding-left:30px;padding-bottom:30px;">
	<a href="http://www.daemon.com.au" target="_blank"><img src="../images/daemon_logo.gif" alt="Daemon Internet Consultants" border="0"></a>
	<p>Daemon Pty Ltd, the creators of the FarCry Content Management System, offers a wide range of support offerings to assist organisations with their FarCry implementation.</p>
	<p>Our support offerings deliver real business benefits by providing organisations with specialised technical support and guaranteed fast turn-around time on incidents.  </p>
	<p>Our technical staff are Macromedia Certified Developers and are especially qualified to quickly and accurately answer technical inquiries.  Over 8 years experience as a Macromedia Solutions Partner and Macromedia Authorised Training Centre has produced a base of knowledgeable and professional expertise that is second-to-none.</p>
	<p>A number of different support plans are available and vary with the nature of the supported FarCry server platform. There are economical, low-volume packages for smaller installations and 24/7/365 offerings with bundled site analysis for larger ones.</p>
	<p>Support packages bundle hours of technical support with several value-added components such as technical conference calls and Internet-based seminars. To discuss your requirements call (612) 9380-4162 or email sales@daemon.com.au. </p>
	
	<p><span class="frameMenuBullet">&raquo;</span> <a href="http://www.daemon.com.au/go/farcry-support">Daemon Commercial Farcry Support</a></p>
	</div>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>
