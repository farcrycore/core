<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/edittabArchive.cfm,v 1.12 2005/08/17 06:50:52 pottery Exp $
$Author: pottery $
$Date: 2005/08/17 06:50:52 $
$Name: milestone_3-0-1 $
$Revision: 1.12 $

|| DESCRIPTION || 
$Description: shows archived objects $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iArchiveTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="ObjectArchiveTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iArchiveTab eq 1>

	<h3><cfoutput>#application.adminBundle[session.dmProfile.locale].archive#</cfoutput></h3>

	
	<!--- check if rollback is required --->
	<cfif isdefined("url.archiveid")>
		
		<!--- get type --->
		<cfset oFourq = createObject("component","farcry.fourq.fourq")>
		<cfset typename = oFourq.findType(url.objectid)>
		<cfset oType = createObject("component",application.types[typename].typepath)>
		
		<!--- rollback arvhice --->
		<cfset stRollback = oType.archiveRollback(objectID="#url.objectid#",archiveId="#url.archiveid#",typename=typename)>
	</cfif>
	
	<!--- get archives --->
	<cfinvoke 
	 component="#application.packagepath#.farcry.versioning"
	 method="getArchives"
	 returnvariable="getArchivesRet">
		<cfinvokeargument name="objectID" value="#url.objectid#"/>
	</cfinvoke>
	
	<table cellspacing="0">
	<cfif getArchivesRet.recordcount gt 0>
		<!--- setup table --->
		<cfoutput>
		<tr>
			<th>#application.adminBundle[session.dmProfile.locale].Date#</th>
			<th>#application.adminBundle[session.dmProfile.locale].Label#</th>
			<th>#application.adminBundle[session.dmProfile.locale].User#</th>
			<th>&nbsp;</th>
			<th>&nbsp;</th>
			<th>&nbsp;</th>
		</tr>
		</cfoutput>
		<!--- loop over archives --->
		<cfoutput query="getArchivesRet">
		<tr>
			<td>
			#application.thisCalendar.i18nDateFormat(DATETIMELASTUPDATED,session.dmProfile.locale,application.longF)# 
			#application.thisCalendar.i18nTimeFormat(DATETIMELASTUPDATED,session.dmProfile.locale,application.shortF)#
			</td>
			<td>#label#</td>
			<td>#lastupdatedby#</td>
			<td><a href="edittabArchiveDetail.cfm?archiveid=#objectid#">#application.adminBundle[session.dmProfile.locale].moreDetail#</a></td>
			<td><a href="#application.url.conjurer#?archiveid=#objectid#" target="_blank">#application.adminBundle[session.dmProfile.locale].archivePreview#</a></td>
			<td>
				<a href="edittabArchive.cfm?objectid=#url.objectid#&archiveid=#objectid#">Rollback</a>
				<!--- check if archive has been rolled back successfully --->
				<cfif isdefined("url.archiveid") and stRollback.result and url.archiveId eq objectid>
					<span style="color:Red">#application.adminBundle[session.dmProfile.locale].rolledBackOK#</span>
				</cfif>
			</td>
		</tr>
		</cfoutput>
	<cfelse>
		<tr>
			<td colspan="6"><cfoutput>#application.adminBundle[session.dmProfile.locale].noArchiveRecorded#</cfoutput></td>
		</tr>
	</cfif>
	</table>

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>