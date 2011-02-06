<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
	
<cfparam name="url.linkuser" default="true">
	
<cfquery name="qAudit" datasource="#application.dsn#" >
	SELECT * FROM farLog
	WHERE createdby=<cfqueryparam value="#url.username#" cfsqltype="cf_sql_varchar"  />
	ORDER BY datetimecreated DESC
</cfquery>

<admin:header title="Audit" />

<skin:onReady id="object-admin-popup">
	<cfoutput>
	$j(document).ready(function(){
		$j(".object-stats").click(function(e){
	
			e.preventDefault();
			$j( "##fc-dialog-iframe-object").attr("src", "/webtop//edittabAudit.cfm?objectid=" + $j(this).attr('href') + "&linkuser=false")
			$j( "##fc-dialog-div-object" ).dialog({
				height: 600,
				width: 700,
				modal: true
			});
		});
	});
	</cfoutput>
</skin:onReady>

<cfset quser=application.fapi.getContentObjects(typename='dmProfile', username_eq="#url.username#", lProperties="label") />

<cfoutput>
	<h3>#application.rb.getResource("workflow.headings.auditTrace@text","Audit Trace")# for #quser.label#</h3>
</cfoutput>

<skin:pagination query="#qAudit#" typename="farLog" r_stObject="stLog" paginationID="farLog" recordsPerPage="10" pageLinks="10">
	<cfoutput>
		<cfif stLog.recordsetrow mod 10 eq 1 or stLog.recordsetrow eq 1>
			<table width="100%" class="objectAdmin">
			<tr>
				<th>#application.rb.getResource("workflow.labels.date@label","Date")#</th>
				<th>#application.rb.getResource("workflow.labels.changeType@label","Change Type")#</th>
				<th>Object</th>
				<th>#application.rb.getResource("workflow.labels.user@label","Notes")#</th>
			</tr>
		</cfif>
		<tr <cfif stLog.CURRENTROWCLASS eq 'oddrow'>class='alt'</cfif>>
			<td>
				<span id="oa-date-#stLog.objectid#">#application.fapi.prettyDate(stLog.datetimecreated)#</span>
				<skin:toolTip id="oa-date-#stLog.objectid#" selector="##oa-date-#stLog.objectid#">#dateformat(stLog.datetimecreated, "dd/mm/yyyy hh:mm:ss")#</skin:toolTip>
			</td>
			<td>
				#stLog.event#
			</td>
			<td>
				<cfif len(stLog.object)>
					<cfset stObj=structNew()>
					<cfset stObj=application.fapi.getContentObject(objectid=stLog.object) />
					<cfif not structIsEmpty(stObj)>
						<cfif url.linkuser>
							<a class="object-stats" href="#stobj.objectid#">#stObj.label# (#stobj.typename#)</a>
						<cfelse>
							#stObj.label# (#stobj.typename#)
						</cfif>
						
					</cfif>
				</cfif>
			</td>
			<td>
				#stLog.notes#
			</td>
		</tr>

		<cfif stLog.recordsetrow mod 10 eq 0 or stLog.recordsetrow eq stLog.recordsetcount>
			</table>
		</cfif>

	</cfoutput>
</skin:pagination>

<cfoutput>
	<div id='fc-dialog-div-object' style="padding:10px;"><iframe style='width:99%;height:99%;border-width:0px;' frameborder='0' id="fc-dialog-iframe-object"></iframe></div>
</cfoutput>

<skin:loadJS id="jquery-ui"/>
<skin:loadCSS id="jquery-ui"/>

<admin:footer>