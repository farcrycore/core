<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmProfile/display.cfm,v 1.2 2003/11/23 23:57:26 brendan Exp $
$Author: brendan $
$Date: 2003/11/23 23:57:26 $
$Name: milestone_2-1-2 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: dmProfile -- standard page $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@dameon.com.au) $
--->

<cfsetting enablecfoutputonly="yes">

<!--- try to use webskin display --->
<cftry>
	<cfinclude template="/farcry/#application.applicationName#/webskin/dmProfile/display.cfm">
	<cfcatch>
		<!--- use default --->
		<cfset request.stObj.title = "#stObj.firstName# #stObj.lastName#">
		
		<cfoutput>
			<table width="250" border="0" cellspacing="1" cellpadding="3" style="border: 1px solid ##000;">
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>Name&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.firstName# #stObj.lastName#</td>
	        </tr>
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>Email&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.emailAddress#</td>
	        </tr>
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>Position&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.position#</td>
	        </tr>
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>Department&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.department#</td>
	        </tr>
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>Phone&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.phone#</td>
	        </tr>
	        <tr>
	            <td class="dataOddRow" width="20%" nowrap><strong>Fax&nbsp;</strong></td>
	            <td class="dataEvenRow" width="80%" nowrap>#stObj.fax#</td>
	        </tr>
	        </table>
		</cfoutput>
	</cfcatch>
</cftry>

<cfsetting enablecfoutputonly="no">