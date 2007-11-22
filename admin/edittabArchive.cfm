<cfsetting enablecfoutputonly="true" />
<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2006, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: $
$Author: $
$Date: $
$Name: $
$Revision: $

|| DESCRIPTION || 
$Description: shows archived objects $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<!--- environment variables --->
<cfparam name="url.archiveid" type="uuid" />
<cfparam name="url.objectid" type="uuid" />

<!--- set up page header --->
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="ObjectArchiveTab">
	<cfoutput>
	<h3>#application.adminBundle[session.dmProfile.locale].archive#</h3>
	</cfoutput>
	
	<!--- check if rollback is required --->
	<cfif isdefined("url.archiveid")>
		
		<!--- get type --->
		<cfset oFourq = createObject("component","farcry.core.packages.fourq.fourq")>
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
	
	<cfoutput><table cellspacing="0"></cfoutput>
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
	<cfoutput>
		<tr>
			<td colspan="6">#application.adminBundle[session.dmProfile.locale].noArchiveRecorded#</td>
		</tr>
	</cfoutput>
	</cfif>
	<cfoutput></table></cfoutput>
</sec:CheckPermission error="true">

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="false" />