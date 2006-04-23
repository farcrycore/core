<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/verityManage.cfm,v 1.7 2003/09/23 08:05:17 brendan Exp $
$Author: brendan $
$Date: 2003/09/23 08:05:17 $
$Name: b201 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: Manages verity collections. Options to update/optimise/delete collections $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->

<cfsetting enablecfoutputonly="Yes" requestTimeout="600">

<!--- check permissions --->
<cfscript>
	iSearchTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminSearchTab");
</cfscript>

<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header title="Verity: Manage Collections">

<cfif iSearchTab eq 1>
	<cfparam name="url.action" default="">
	
	<cfoutput><span class="FormTitle">Manage Collections</span><p></p></cfoutput>
	
	<cfswitch expression="#url.action#">
	
		<!--- delete collection --->
		<cfcase value="delete">
			<cfset stSuccess = application.factory.oVerity.deleteCollection(url.collection)>
			<cfif stSuccess.bSuccess>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> #stSuccess.message#</cfoutput>
			<cfelse>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <span class="error">#stSuccess.message#</span></cfoutput>
			</cfif>
			<cfoutput><p></p><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/admin/verityManage.cfm">Manage Collections</a></cfoutput>
		</cfcase>	
		
		<!--- optimise collection --->
		<cfcase value="optimise">
			<cfoutput><span class="frameMenuBullet">&raquo;</span> Optimising...<p></p></cfoutput><cfflush>
			<cfset stSuccess = application.factory.oVerity.optimiseCollection(url.collection)>
			<cfif stSuccess.bSuccess>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> #stSuccess.message#</cfoutput>
			<cfelse>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <span class="error">#stSuccess.message#</span></cfoutput>
			</cfif>
			<cfoutput><p></p><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/admin/verityManage.cfm">Manage Collections</a></cfoutput>
		</cfcase>
		
		<!--- update collection --->
		<cfcase value="update">
			<cfoutput><span class="frameMenuBullet">&raquo;</span> Updating...<p></p></cfoutput><cfflush>
			<cfset application.factory.oVerity.updateCollection(url.collection)>
			<cfoutput><p></p><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/admin/verityManage.cfm">Manage Collections</a></cfoutput>
		</cfcase>
		
		<!--- list collections --->
		<cfdefaultcase>
			<cfset qCollections = application.factory.oVerity.listCollections()>
			
			<!--- check a collection exists --->
			<cfif qCollections.recordcount>
				<cfoutput>
				<table cellpadding="5" cellspacing="0" border="1"  style="margin-left:30px;">
				<tr>
					<th class="dataheader">Collection</td>
					<th class="dataheader">Last Updated</td>
					<th class="dataheader">Update</td>					
					<th class="dataheader">Optimise</td>
					<th class="dataheader">Delete</td>
				</tr>
				
				<!--- loop over collections --->
				<cfloop query="qCollections">
					<tr class="#IIF(qCollections.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
						<td>#name#</td>
						<td align="center">#lastUpdated#</td>
						<td align="center"><cfif lastupdated neq "n/a"><a href="#application.url.farcry#/admin/verityManage.cfm?action=update&collection=#name#">update</a><cfelse>n/a</cfif></td>
						<td align="center"><cfif lastupdated neq "n/a"><a href="#application.url.farcry#/admin/verityManage.cfm?action=optimise&collection=#name#">optimise</a><cfelse>n/a</cfif></td>
						<td align="center"><a href="#application.url.farcry#/admin/verityManage.cfm?action=delete&collection=#name#" onClick="return confirm('Are you sure you want to delete this collection?');">delete</a></td>
					</tr>
				</cfloop>
				
				</table>
				</cfoutput>
				
			<!--- no collections - display error message with option to build collections --->
			<cfelse>
				<cfoutput>There are no verity collections for this site. <a href="#application.url.farcry#/admin/verityBuild.cfm">Build collections now</a></cfoutput>
			</cfif>				
			
		</cfdefaultcase>
	</cfswitch>
	
	
<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">