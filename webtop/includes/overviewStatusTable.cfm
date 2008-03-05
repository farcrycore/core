<cfparam name="tableStatus_name" default="pending">
<cfoutput>
<cfif tableStatus_name EQ "pending">
<h3><!--- #application.rb.getResource("objPendingApproval")# --->Content Items Pending Approval</h3>
<cfelseif tableStatus_name EQ "draft">
<h3><!--- #application.rb.getResource("draftObjects")# --->Content Items In Draft</h3>
</cfif>

<form name="frm_#tableStatus_name#" action="#cgi.script_name#?#cgi.query_string#" method="post">
<div class="utilBar f-subdued">
	<label for="#tableStatus_name#_objectType"><b>Content Type:</b>
		<select name="#tableStatus_name#_objectType" id="#tableStatus_name#_objectType" onchange="doToggleContent(document.frm_#tableStatus_name#,'#tableStatus_name#');"><cfloop index="icount" from="1" to="#ArrayLen(aObjectTypes)#">
			<option value="#aObjectTypes[icount]#"<cfif icount EQ Evaluate("#tableStatus_name#_objectType")> selected="selected"</cfif>>#aObjectTypes[icount]#</option></cfloop>
		</select>
	</label>
	<label for="#tableStatus_name#_maxRecords"><b>Latest:</b>
		<select name="#tableStatus_name#_maxRecords" id="#tableStatus_name#_maxRecords" onchange="doToggleContent(document.frm_#tableStatus_name#,'#tableStatus_name#');"><cfloop list="#lMaxRecords#" index="imax">
			<option value="#imax#"<cfif imax EQ Evaluate("#tableStatus_name#_maxRecords")> selected="selected"</cfif>>#imax#</option></cfloop>
		</select>
	</label>
</div>
<br class="clear" />
<table class="table-2" cellspacing="0" id="table_#tableStatus_name#">
<tr>
	<th scope="col">#application.rb.getResource("object")#</th>
	<th scope="col">#application.rb.getResource("createdBy")#</th>
	<th scope="col">#application.rb.getResource("lastUpdated")#</th>
</tr>
<tbody id="tbody_#tableStatus_name#">
</tbody>
</table>
</form></cfoutput>