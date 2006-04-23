<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmProfile/display.cfm,v 1.3 2004/07/15 02:00:50 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 02:00:50 $
$Name: milestone_2-3-2 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: dmProfile -- standard page $
$TODO: $

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
			<table width="250" border="0" cellspacing="1" cellpadding="3" style="border: 1px solid ##000;">
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>#application.adminBundle[session.dmProfile.locale].name#&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.firstName# #stObj.lastName#</td>
	        </tr>
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>#application.adminBundle[session.dmProfile.locale].email#&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.emailAddress#</td>
	        </tr>
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>#application.adminBundle[session.dmProfile.locale].position#&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.position#</td>
	        </tr>
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>#application.adminBundle[session.dmProfile.locale].department#&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.department#</td>
	        </tr>
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>#application.adminBundle[session.dmProfile.locale].phone#&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.phone#</td>
	        </tr>
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>#application.adminBundle[session.dmProfile.locale].Fax#&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.fax#</td>
	        </tr>
	        </table>
		</cfoutput>
	</cfcatch>
</cftry>

<cfsetting enablecfoutputonly="no">