<cfsetting enablecfoutputonly="true" />
<cfprocessingDirective pageencoding="utf-8">
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
<!--- @@DESCRIPTION: Displays an audit log for a content item in the webtop overview --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="url.linkuser" default="true"  />
<!--- 
 // VIEW
--------------------------------------------------------------------------------------------------->
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
<skin:onReady id="object-admin-popup">
	<cfoutput>
	$j(document).ready(function(){
		$j(".user-stats").click(function(e){
			e.preventDefault();
			$j( "##fc-dialog-iframe-user").attr("src", "#application.url.webtop#/edittabUserStats.cfm?username=" + $j(this).attr('href') + "&linkuser=false")
			$j( "##fc-dialog-div-user" ).dialog({
				height: 600,
				width: 700,
				modal: true
			});
		});
	});
	</cfoutput>
</skin:onReady>
<sec:CheckPermission error="true" permission="ObjectAuditTab">
	<cfset oAudit = createObject("component", "#application.packagepath#.farcry.audit") />
	<cfset qLog = oAudit.getAuditLog(objectid=url.objectid) />
	
	<cfoutput>	
		<h3>#application.rb.getResource("workflow.headings.auditTrace@text","Audit Trace")# for #application.fapi.getContentObject(objectid=url.objectid).label#</h3>
	</cfoutput>
	
	<skin:pagination query="#qLog#" typename="farLog" r_stObject="stLog" paginationID="farLog" recordsPerPage="10" pageLinks="10">
		<cfoutput>
			<cfif stLog.recordsetrow mod 10 eq 1 or stLog.recordsetrow eq 1>
				<table width="100%" class="objectAdmin">
					<tr>
						<th>#application.rb.getResource("workflow.labels.date@label","Date")#</th>
						<th>#application.rb.getResource("workflow.labels.changeType@label","Change Type")#</th>
						<th>#application.rb.getResource("workflow.labels.notes@label","Notes")#</th>
						<th>#application.rb.getResource("workflow.labels.user@label","User")#</th>
					</tr>
			</cfif>
			<tr <cfif stLog.CURRENTROWCLASS eq 'oddrow'>class='alt'</cfif>
				<td>
					<span id="oa-date-#stLog.objectid#">#application.fapi.prettyDate(stLog.datetimestamp)#</span>
					<skin:toolTip id="oa-date-#stLog.objectid#" selector="##oa-date-#stLog.objectid#">#dateformat(stLog.datetimestamp, "dd/mm/yyyy hh:mm:ss")#</skin:toolTip>
				</td>
				<td>#stLog.audittype#</td>
				<td>
					#stLog.notes#
				</td>
				<td>
					<cfset quser=application.fapi.getContentObjects(typename='dmProfile', username_eq="#stLog.username#", lProperties="label") />
	
					<cfif url.linkuser>
						<a href="#stLog.username#" class="user-stats">#quser.label#</a>
					<cfelse>
						#quser.label#
					</cfif>
				</td>
			</tr>
			<cfif stLog.recordsetrow mod 10 eq 0 or stLog.recordsetrow eq stLog.recordsetcount>
				</table>
			</cfif>
		</cfoutput>
	</skin:pagination>
	
	<cfif qLog.recordcount eq 0>
		<cfoutput>
			#application.rb.getResource("workflow.messages.noTraceRecorded@text","No trace recorded.")#
		</cfoutput>
	</cfif>
</sec:CheckPermission>

<!--- setup footer --->
<admin:footer>

<cfoutput>
	<div id='fc-dialog-div-user' style="padding:10px;"><iframe style='width:99%;height:99%;border-width:0px;' frameborder='0' id="fc-dialog-iframe-user"></iframe></div>
</cfoutput>

<skin:loadJS id="jquery-ui"/>
<skin:loadCSS id="jquery-ui"/>

<cfsetting enablecfoutputonly="false" />