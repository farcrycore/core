<cfsetting enablecfoutputonly="true" />
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!--- @@description: shows archived versions for a specific content item --->
<cfprocessingDirective pageencoding="utf-8">

<cfparam name="finish_url" default="#cgi.http_referer#" />

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />


<!--- 
 // VIEW
--------------------------------------------------------------------------------------------------->
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="ObjectArchiveTab">
	<cfoutput>	<h3>#application.rb.getResource("workflow.headings.archive@text","Archive")#</h3></cfoutput>

	<!--- check if rollback is required --->
	<cfif structKeyExists(url, "archiveid")>
		
		<!--- get type --->
		<cfset oFourq = createObject("component","farcry.core.packages.fourq.fourq") />
		<cfset typename = oFourq.findType(url.objectid) />
		<cfset oType = createObject("component",application.types[typename].typepath) />
		
		<!--- rollback arvhice --->
		<cfset stRollback = oType.archiveRollback(objectID="#url.objectid#",archiveId="#url.archiveid#",typename=typename) />
		<cfoutput>
		<script type="text/javascript">
			if(parent['sidebar'].frames['sideTree']){
				parent['sidebar'].frames['sideTree'].location= parent['sidebar'].frames['sideTree'].location;
			}
			location.href = "#finish_url#";
		</script></cfoutput>
		<cfabort>
	</cfif>
	
	<!--- get archives --->
	<cfinvoke component="#application.packagepath#.farcry.versioning" method="getArchives" returnvariable="getArchivesRet">
		<cfinvokeargument name="objectID" value="#url.objectid#" />
	</cfinvoke>

	<cfoutput>
		<table width="100%" class="objectAdmin">
	</cfoutput>
	<cfif getArchivesRet.recordcount gt 0>
		<!--- setup table --->
		<cfoutput>
		<tr class="#IIF(getArchivesRet.currentrow MOD 2, de("alt"), de(""))#">
			<th>#application.rb.getResource("workflow.labels.date@label","Date")#</th>
			<th>#application.rb.getResource("workflow.labels.label@label","")#</th>
			<th>#application.rb.getResource("workflow.labels.user@label","User")#</th>
			<!--- <th>&nbsp;</th> --->
			<th>&nbsp;</th>
			<th>&nbsp;</th>
		</tr>
		</cfoutput>
		<!--- loop over archives --->
		<cfloop query="getArchivesRet">
		<cfoutput>
		<tr>
			<td>
			#application.thisCalendar.i18nDateFormat(DATETIMELASTUPDATED,session.dmProfile.locale,application.longF)# 
			#application.thisCalendar.i18nTimeFormat(DATETIMELASTUPDATED,session.dmProfile.locale,application.shortF)#
			</td>
			<td>#label#</td>
			<td>#lastupdatedby#</td>
			<!--- <td><a href="edittabArchiveDetail.cfm?archiveid=#objectid#">#application.rb.getResource("moreDetail")#</a></td> --->
			<td><a href="#application.url.conjurer#?objectid=#objectid#" target="_blank">#application.rb.getResource("workflow.buttons.archivePreview@label","Preview")#</a></td>
			<td>
				<a href="archive.cfm?objectid=#url.objectid#&amp;archiveid=#objectid#&amp;finish_url=#cgi.http_referer#" onclick="return confirm('#application.rb.getResource("workflow.buttons.rollback@confirmtext","Are you sure you want to rollback to this version?")#')">#application.rb.getResource("workflow.buttons.rollback@label","Rollback")#</a></cfoutput>
				<!--- check if archive has been rolled back successfully --->
				<cfif isdefined("url.archiveid") and stRollback.result and url.archiveId eq objectid>
					<cfoutput>
					<span style="color:Red">#application.rb.getResource("workflow.messages.rolledBackOK@text","Successfully Rolled Back")#</span></cfoutput>
				</cfif>
				<cfoutput>
			</td>
		</tr></cfoutput>
		</cfloop>
	<cfelse>
		<cfoutput>
		<tr>
			<td colspan="6">#application.rb.getResource("workflow.messages.noArchiveRecorded@text","No archive recorded.")#</td>
		</tr></cfoutput>
	</cfif>
	<cfoutput>
	</table>
	<a href="#finish_url#">[#application.rb.getResource("workflow.buttons.cancel@label","Cancel")#]</a></cfoutput>
</sec:CheckPermission>

<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="false" />