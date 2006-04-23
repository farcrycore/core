<!--- 
|| BEGIN DAEMONDOC||

|| Copyright ||
Daemon Pty Limited 1995-2003
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/cacheAll.cfm,v 1.4 2004/07/15 01:10:24 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:10:24 $
$Name: milestone_2-3-2 $
$Revision: 1.4 $

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
	<cfoutput><span class="Formtitle">#application.adminBundle[session.dmProfile.locale].autoCache#</span><p></p>
	
	#application.adminBundle[session.dmProfile.locale].generatingCaches#<p></p></cfoutput><cfflush>
	
	<cfinvoke component="#application.packagepath#.farcry.cache" method="cacheAll" />
	
	<cfoutput><p></p><strong>#application.adminBundle[session.dmProfile.locale].allDone#</strong></cfoutput>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="no">