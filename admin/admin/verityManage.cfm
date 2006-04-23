<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/verityManage.cfm,v 1.9 2005/02/02 01:18:19 brendan Exp $
$Author: brendan $
$Date: 2005/02/02 01:18:19 $
$Name: milestone_2-3-2 $
$Revision: 1.9 $

|| DESCRIPTION || 
$Description: Manages verity collections. Options to update/optimise/delete collections $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->

<cfsetting enablecfoutputonly="Yes" requestTimeout="600">

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iSearchTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminSearchTab");
</cfscript>

<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header title="#application.adminBundle[session.dmProfile.locale].manageVerityCollections#" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iSearchTab eq 1>
	<cfparam name="url.action" default="">
	
	<cfoutput><span class="FormTitle">#application.adminBundle[session.dmProfile.locale].manageCollections#</span><p></p></cfoutput>
	
	<cfswitch expression="#url.action#">
	
		<!--- delete collection --->
		<cfcase value="delete">
			<cfset stSuccess = application.factory.oVerity.deleteCollection(url.collection)>
			<cfif stSuccess.bSuccess>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> #stSuccess.message#</cfoutput>
			<cfelse>
				<cfoutput><span class="frameMenuBullet">&raquo;</span> <span class="error">#stSuccess.message#</span></cfoutput>
			</cfif>
			<cfoutput><p></p><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/admin/verityManage.cfm">#application.adminBundle[session.dmProfile.locale].manageCollections#</a></cfoutput>
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
			<cfoutput><p></p><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/admin/verityManage.cfm">#application.adminBundle[session.dmProfile.locale].manageCollections#</a></cfoutput>
		</cfcase>
		
		<!--- update collection --->
		<cfcase value="update">
			<cfoutput><span class="frameMenuBullet">&raquo;</span> #application.adminBundle[session.dmProfile.locale].updating#<p></p></cfoutput><cfflush>
			<cfset application.factory.oVerity.updateCollection(url.collection)>
			<cfoutput><p></p><span class="frameMenuBullet">&raquo;</span> <a href="#application.url.farcry#/admin/verityManage.cfm">#application.adminBundle[session.dmProfile.locale].manageCollections#</a></cfoutput>
		</cfcase>
		
		<!--- list collections --->
		<cfdefaultcase>
			<cfset qCollections = application.factory.oVerity.listCollections()>
			
			<!--- check a collection exists --->
			<cfif qCollections.recordcount>
				<cfoutput>
				<table cellpadding="5" cellspacing="0" border="1"  style="margin-left:30px;">
				<tr>
					<th class="dataheader">#application.adminBundle[session.dmProfile.locale].collection#</td>
					<th class="dataheader">#application.adminBundle[session.dmProfile.locale].lastUpdatedLC#</td>
					<th class="dataheader">#application.adminBundle[session.dmProfile.locale].update#</td>					
					<th class="dataheader">#application.adminBundle[session.dmProfile.locale].optimize#</td>
					<th class="dataheader">#application.adminBundle[session.dmProfile.locale].delete#</td>
				</tr>
				
				<!--- loop over collections --->
				<cfloop query="qCollections">
					<tr class="#IIF(qCollections.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
						<td>#name#</td>
						<td align="center">#lastUpdated#</td>
						<td align="center"><cfif lastupdated neq "n/a"><a href="#application.url.farcry#/admin/verityManage.cfm?action=update&collection=#name#">#application.adminBundle[session.dmProfile.locale].update#</a><cfelse>#application.adminBundle[session.dmProfile.locale].notAvailable#</cfif></td>
						<td align="center"><cfif lastupdated neq "n/a"><a href="#application.url.farcry#/admin/verityManage.cfm?action=optimise&collection=#name#">#application.adminBundle[session.dmProfile.locale].optimize#</a><cfelse>#application.adminBundle[session.dmProfile.locale].notAvailable#</cfif></td>
						<td align="center"><a href="#application.url.farcry#/admin/verityManage.cfm?action=delete&collection=#name#" onClick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmDeleteCollection#');">#application.adminBundle[session.dmProfile.locale].delete#</a></td>
					</tr>
				</cfloop>
				
				</table>
				</cfoutput>
				
			<!--- no collections - display error message with option to build collections --->
			<cfelse>
				<cfoutput>#application.adminBundle[session.dmProfile.locale].noVerityCollections# <a href="#application.url.farcry#/admin/verityBuild.cfm">#application.adminBundle[session.dmProfile.locale].buildCollectionsNow#</a></cfoutput>
			</cfif>				
			
		</cfdefaultcase>
	</cfswitch>
	
	
<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">