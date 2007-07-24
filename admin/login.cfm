<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/login.cfm,v 1.10 2005/08/09 03:54:40 geoff Exp $

$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.10 $

|| DESCRIPTION || 
$Description: FarCry login screen. Tries to include a custom login screen, otherwise use the default.$


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
	    <cfinclude template="/farcry/projects/#application.projectDirectoryName#/customadmin/login/login.cfm">
 	<cfelse>
		<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">
   		<nj:Login>
	</cfif>

<cfsetting enablecfoutputonly="No">