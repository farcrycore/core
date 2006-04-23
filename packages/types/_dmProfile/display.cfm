<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmProfile/display.cfm,v 1.1 2003/06/23 01:54:53 brendan Exp $
$Author: brendan $
$Date: 2003/06/23 01:54:53 $
$Name: b201 $
$Revision: 1.1 $

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
		<cfdump var="#cfcatch#">
		<!--- use default --->
		<cfset request.stObj.title = "#stObj.firstName# #stObj.lastName#">
		
		<cfoutput>
			<!--id=content-->
			<div id="content">
				<h1>#stObj.firstName# #stObj.lastName#</h1>
				<p></p>
				<table>
				<tr>
					<td><strong>Department:</strong></td>
					<td>#stObj.department#</td>
				</tr>
				<tr>
					<td><strong>Position:</strong></td>
					<td>#stObj.position#</td>
				</tr>
				<tr>
					<td><strong>Email:</strong></td>
					<td>#stObj.emailAddress#</td>
				</tr>
				<tr>
					<td><strong>Phone:</strong></td>
					<td>#stObj.phone#</td>
				</tr>
				<tr>
					<td><strong>Fax:</strong></td>
					<td>#stObj.fax#</td>
				</tr>
				</table>
			</div>
			<!--/id=content-->
		</cfoutput>
	</cfcatch>
</cftry>

<cfsetting enablecfoutputonly="no">