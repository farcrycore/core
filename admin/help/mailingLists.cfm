<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/help/mailingLists.cfm,v 1.1 2003/09/17 04:53:30 brendan Exp $
$Author: brendan $
$Date: 2003/09/17 04:53:30 $
$Name: b201 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: mailing list page for help tab. $
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
	<div class="formtitle">Mailing Lists</div>
	
	<div style="padding-left:30px;padding-bottom:30px;padding-right:30px;">
	<p>Each mailing list is available via email (obviously), a web based interface and NNTP (a newsgroup or USENET interface). Instructions for leaving every list are clearly given in the footer of every post.  DIGEST and other options are available.  Please refer to the web based interface for a full list of configuration options.  Visitors are allowed, but you must join the list to post.</p>
	<p>&nbsp;</p>
	
	<div class="formtitle">farcry-dev (public)</div>
	
	<span class="frameMenuBullet">&raquo;</span> <a href="mailto:farcry-dev@lists.daemon.com.au">farcry-dev@lists.daemon.com.au</a>
	<p>Aimed at managing support for FarCry open source developers.  Anyone making enquiries about modifying or extending or deploying the code base should be referred to this list.</p>
	<ul>
	    <li>To join the mailing list, email: <a href="mailto:join-farcry-dev@lists.daemon.com.au">join-farcry-dev@lists.daemon.com.au</a></li>
	    <li>Web based interface: <a href="http://lists.daemon.com.au/cgi-bin/lyris.pl?enter=farcry-dev">http://lists.daemon.com.au/cgi-bin/lyris.pl?enter=farcry-dev</a></li>
	    <li>NNTP interface: <a href="news://lists.daemon.com.au/farcry-dev">news://lists.daemon.com.au/farcry-dev</a></li>
	</ul>
	
	<p>&nbsp;</p>
	<div class="formtitle">farcry-user (public)</div>
	
	<span class="frameMenuBullet">&raquo;</span> <a href="mailto:farcry-user@lists.daemon.com.au">farcry-user@lists.daemon.com.au</a>
	<p>Aimed at managing support for FarCry open source users.  Anyone making enquiries about adding, editing or managing content should be referred to this list.</p>
	<ul>
	    <li>To join the mailing list, email: <a href="mailto:join-farcry-user@lists.daemon.com.au">join-farcry-user@lists.daemon.com.au</a></li>
	    <li>Web based interface: <a href="http://lists.daemon.com.au/cgi-bin/lyris.pl?enter=farcry-user">http://lists.daemon.com.au/cgi-bin/lyris.pl?enter=farcry-user</a></li>
	    <li>NNTP interface: <a href="news://lists.daemon.com.au/farcry-user">news://lists.daemon.com.au/farcry-user</a></li>
	</ul>
	
	</div>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>