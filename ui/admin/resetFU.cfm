<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/ui/admin/Attic/resetFU.cfm,v 1.1 2003/05/08 05:08:21 brendan Exp $
$Author: brendan $
$Date: 2003/05/08 05:08:21 $
$Name: b131 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: Deletes existing FU entries and recretes for entire tree$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfoutput><span class="FormTitle">Reset Friendly URLs</span><p></p></cfoutput>

<!--- Create an instance of the component --->
<cfobject component="#application.packagepath#.farcry.fu" name="fu">
<!--- call create method --->
<cfset fu.createALL()>

<!--- show success message --->
<cfoutput>
<p></p>
<span class="frameMenuBullet">&raquo;</span> Friendly url's created.<p></p></cfoutput>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">