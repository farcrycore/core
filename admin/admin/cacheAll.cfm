<!--- 
|| BEGIN DAEMONDOC||

|| Copyright ||
Daemon Pty Limited 1995-2003
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/cacheAll.cfm,v 1.6 2005/08/16 05:53:23 pottery Exp $
$Author: pottery $
$Date: 2005/08/16 05:53:23 $
$Name: milestone_3-0-0 $
$Revision: 1.6 $

|| DESCRIPTION || 
Loops over all pages in website to enable caches to be set

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in:
out:

|| END DAEMONDOC||
--->

<cfsetting enablecfoutputonly="yes" requestTimeOut="2000">

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iGeneralTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iGeneralTab eq 1>
	<cfoutput><h3>#application.adminBundle[session.dmProfile.locale].autoCache#</h3>
	
	<p>#application.adminBundle[session.dmProfile.locale].generatingCaches#</p></cfoutput><cfflush>
	
	<cfinvoke component="#application.packagepath#.farcry.cache" method="cacheAll" />
	
	<cfoutput><h4 class="fade success" id="fader1">#application.adminBundle[session.dmProfile.locale].allDone#</h4></cfoutput>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="no">