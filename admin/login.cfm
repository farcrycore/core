<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/login.cfm,v 1.6 2003/09/11 02:13:50 brendan Exp $
$Author: brendan $
$Date: 2003/09/11 02:13:50 $
$Name: b201 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: FarCry login screen. Tries to include a custom login screen, otherwise use the default.$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
$Developer: Gary Menzel (gmenzel@abnamromorgans.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">

<cftry> 
	<!--- try and see if the file can be loaded --->
    <cfinclude template="/farcry/#application.applicationName#/customadmin/login/login.cfm">
    
	<cfcatch> <!--- nope - so use the default one --->
		<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">
   		<nj:Login>
    </cfcatch>
</cftry>

<cfsetting enablecfoutputonly="No">