<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/login.cfm,v 1.9 2004/08/31 06:32:48 paul Exp $

$Author: paul $
$Date: 2004/08/31 06:32:48 $
$Name: milestone_2-3-2 $
$Revision: 1.9 $

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

<cfprocessingDirective pageencoding="utf-8">

	<cfif fileExists("#application.path.project#/customadmin/login/login.cfm")>
	    <cfinclude template="/farcry/#application.applicationName#/customadmin/login/login.cfm">
 	<cfelse>
		<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">
   		<nj:Login>
	</cfif>

<cfsetting enablecfoutputonly="No">