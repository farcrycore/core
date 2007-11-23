<!--- 
|| BEGIN DAEMONDOC||

|| Copyright ||
Daemon Pty Limited 1995-2003
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/admin/cacheView.cfm,v 1.5 2004/07/15 01:10:24 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:10:24 $
$Name: milestone_3-0-1 $
$Revision: 1.5 $

|| DESCRIPTION || 
Displays the details of cache

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in:
out:

|| END DAEMONDOC||
--->

<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="AdminGeneralTab">

	<!--- get cache details --->
	<cfset contentcache = structget("server.dm_generatedcontentcache.#application.applicationname#")>
	<!--- show contents of cache --->
	<cfoutput>#contentcache[url.cache].cache#</cfoutput>
</sec:CheckPermission>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="no">
