<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/admin/verityManage.cfm,v 1.10 2005/08/16 02:41:08 pottery Exp $
$Author: pottery $
$Date: 2005/08/16 02:41:08 $
$Name: milestone_3-0-1 $
$Revision: 1.10 $

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

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<admin:header title="#application.adminBundle[session.dmProfile.locale].manageVerityCollections#" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iSearchTab eq 1>
	<cfparam name="url.action" default="">
	
	<cfoutput><h3>#application.adminBundle[session.dmProfile.locale].manageCollections#</h3></cfoutput>
	
	<cfswitch expression="#url.action#">
	
		<!--- delete collection --->
		<cfcase value="delete">
			<cfset stSuccess = application.factory.oVerity.deleteCollection(url.collection)>
			<cfif stSuccess.bSuccess>
				<cfoutput>
				<ul>
				<li>#stSuccess.message#</li>
				</ul>
				</cfoutput>
			<cfelse>
				<cfoutput>
				<ul>
				<li><span class="error">#stSuccess.message#</span></li>
				</ul>
				</cfoutput>
			</cfif>
			<cfoutput><p class="success fade" id="fader1"><strong><a href="#application.url.farcry#/admin/verityManage.cfm">#application.adminBundle[session.dmProfile.locale].manageCollections#</a></strong></p></cfoutput>
		</cfcase>	
		
		<!--- optimise collection --->
		<cfcase value="optimise">
			<cfoutput>
			<ul>
			<li>Optimising...</li>
			</ul>
			</cfoutput><cfflush>
			<cfset stSuccess = application.factory.oVerity.optimiseCollection(url.collection)>
			<cfif stSuccess.bSuccess>
				<cfoutput>
				<p><strong class="success fade" id="fader2">#stSuccess.message#</strong></p>
				</cfoutput>
			<cfelse>
				<cfoutput>
				<p><strong class="error fade" id="fader3">#stSuccess.message#</strong></p>
				</cfoutput>
			</cfif>
			<cfoutput>
			<p><strong class="success fade" id="fader4">
			<a href="#application.url.farcry#/admin/verityManage.cfm">#application.adminBundle[session.dmProfile.locale].manageCollections#</a>
			</strong></p>
			</cfoutput>
		</cfcase>
		
		<!--- update collection --->
		<cfcase value="update">
			<cfoutput>
			<p><strong class="success fade" id="fader5">
			#application.adminBundle[session.dmProfile.locale].updating#</strong></p>
			</cfoutput><cfflush>
			<cfset application.factory.oVerity.updateCollection(url.collection)>
			<cfoutput>
			<p><strong class="success fade" id="fader6">
			<a href="#application.url.farcry#/admin/verityManage.cfm">#application.adminBundle[session.dmProfile.locale].manageCollections#</a>
			</strong></p>
			</cfoutput>
		</cfcase>
		
		<!--- list collections --->
		<cfdefaultcase>
			<cfset qCollections = application.factory.oVerity.listCollections()>
			
			<!--- check a collection exists --->
			<cfif qCollections.recordcount>
				<cfoutput>
				<table class="table-2">
				<tr>
					<th>#application.adminBundle[session.dmProfile.locale].collection#</th>
					<th>#application.adminBundle[session.dmProfile.locale].lastUpdatedLC#</th>
					<th>#application.adminBundle[session.dmProfile.locale].update#</th>					
					<th>#application.adminBundle[session.dmProfile.locale].optimize#</th>
					<th>#application.adminBundle[session.dmProfile.locale].delete#</th>
				</tr>
				
				<!--- loop over collections --->
				<cfloop query="qCollections">
					<tr class="#IIF(qCollections.currentRow MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
						<td>#name#</td>
						<td>#lastUpdated#</td>
						<td><cfif lastupdated neq "n/a"><a href="#application.url.farcry#/admin/verityManage.cfm?action=update&collection=#name#">#application.adminBundle[session.dmProfile.locale].update#</a><cfelse>#application.adminBundle[session.dmProfile.locale].notAvailable#</cfif></td>
						<td><cfif lastupdated neq "n/a"><a href="#application.url.farcry#/admin/verityManage.cfm?action=optimise&collection=#name#">#application.adminBundle[session.dmProfile.locale].optimize#</a><cfelse>#application.adminBundle[session.dmProfile.locale].notAvailable#</cfif></td>
						<td><a href="#application.url.farcry#/admin/verityManage.cfm?action=delete&collection=#name#" onClick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmDeleteCollection#');">#application.adminBundle[session.dmProfile.locale].delete#</a></td>
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