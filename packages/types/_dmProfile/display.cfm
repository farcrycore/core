<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmProfile/display.cfm,v 1.5 2005/05/26 03:34:17 pottery Exp $
$Author: pottery $
$Date: 2005/05/26 03:34:17 $
$Name: milestone_3-0-0 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: dmProfile -- standard page $
$TODO: Potentially remove this method entirely.  
Should be picked up from types.cfc or overridden by 
extending dmProfile in farcry project. Have removed
reference to method in component for now to see if anyone
complains. 20050523GB $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@dameon.com.au) $
--->

<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- try to use webskin display --->
<cftry>
	<cfinclude template="/farcry/#application.applicationName#/webskin/dmProfile/display.cfm">
	<cfcatch>
		<!--- use default --->
		<cfset request.stObj.title = "#stObj.firstName# #stObj.lastName#">
		
		<cfoutput>
		<dl class="dl-style2">
		<dt>#application.adminBundle[session.dmProfile.locale].name#</dt>
		<dd><cfif len(trim(request.stObj.title))>#stObj.firstName# #stObj.lastName#<cfelse>-</cfif></dd>
		<dt>#application.adminBundle[session.dmProfile.locale].email#</dt>
		<dd><cfif len(stObj.emailAddress)>#stObj.emailAddress#<cfelse>-</cfif></dd>
		<dt>#application.adminBundle[session.dmProfile.locale].position#</dt>
		<dd><cfif len(stObj.position)>#stObj.position#<cfelse>-</cfif></dd>
		<dt>#application.adminBundle[session.dmProfile.locale].department#</dt>
		<dd><cfif len(stObj.department)>#stObj.department#<cfelse>-</cfif></dd>
		<dt>#application.adminBundle[session.dmProfile.locale].phone#</dt>
		<dd><cfif len(stObj.phone)>#stObj.phone#<cfelse>-</cfif></dd>
		<dt>#application.adminBundle[session.dmProfile.locale].Fax#</dt>
		<dd><cfif len(stObj.fax)>#stObj.fax#<cfelse>-</cfif></dd>
		</dl>
		</cfoutput>
	</cfcatch>
</cftry>

<cfsetting enablecfoutputonly="no">