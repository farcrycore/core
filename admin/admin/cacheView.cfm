<!--- 
|| BEGIN DAEMONDOC||

|| Copyright ||
Daemon Pty Limited 1995-2003
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/cacheView.cfm,v 1.4 2003/09/03 01:50:31 brendan Exp $
$Author: brendan $
$Date: 2003/09/03 01:50:31 $
$Name: b201 $
$Revision: 1.4 $

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

<!--- check permissions --->
<cfscript>
	iGeneralTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iGeneralTab eq 1>

	<!--- get cache details --->
	<cfset contentcache = structget("server.dm_generatedcontentcache.#application.applicationname#")>
	<!--- show contents of cache --->
	<cfoutput>#contentcache[url.cache].cache#</cfoutput>

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="no">