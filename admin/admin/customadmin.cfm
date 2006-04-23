<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/customadmin.cfm,v 1.8 2004/08/23 07:00:18 geoff Exp $
$Author: geoff $
$Date: 2004/08/23 07:00:18 $
$Name: milestone_3-0-1 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: This template simply invokes the custom admin module 
with the relevant custom admin code.  Header and footer information 
should be provided by the invoked template. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->

<cfprocessingDirective pageencoding="utf-8">

<cftry>
	<cfmodule template="/farcry/#application.applicationname#/customadmin/#URL.module#">
	<cfcatch>
		<cfif isDefined("URL.debug")>
		<cfdump var="#cfcatch#">
		<cfelse>
		<cfoutput>
			<h3>#application.adminBundle[session.dmProfile.locale].customAdminError#</h3>
			<p>#cfcatch.Message#</p>
			<p>#cfcatch.Detail#</p>
		</cfoutput>
		</cfif>
	</cfcatch>
</cftry> 

<cfsetting enablecfoutputonly="No">
