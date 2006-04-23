<cfsetting enablecfoutputonly="true">
<cfparam name="bFormSubmitted" default="No">
<cfparam name="message_error" default="">
<cfparam name="ObjectAction" default="">

<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/farcry_core/tags/widgets/" prefix="widgets">

<cfset oType = CreateObject("component","#application.packagepath#.rules.container")>

<cfif bFormSubmitted EQ "yes" AND isDefined("objectid")>
	<cfswitch expression="#ObjectAction#">
		<cfcase value="delete">
			<cfloop index="iObjectID" list="#objectid#">
				<cfset returnstruct = oType.delete(iObjectID)>
				<cfif NOT returnstruct.bSuccess>
					<cfset message_error = returnstruct.message>
				</cfif>
			</cfloop>		
		</cfcase>

		<cfdefaultcase>
			<!--- do nothing --->
		</cfdefaultcase>
	</cfswitch>
</cfif>

<cfset qList = oType.getSharedContainers()>

<cfsetting enablecfoutputonly="false">
<!--- set up page header --->
<admin:header title="Reflection Admin" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#" onload="setupPanes('container1');">
<div id="genadmin-wrap">
<h1>Shared Container Management</h1>
<cfif message_error NEQ "">
<p id="fading1" class="fade"><span class="error">#message_error#</span></p></cfif>

<form name="frm" action="<cfoutput>#cgi.script_name#</cfoutput>" method="post">
<div class="utilBar f-subdued">
<input type="button" name="add" value="Add" class="f-submit" onClick="window.location='/farcry/navajo/container_edit.cfm';"><cfif qList.recordCount GT 0>
<input type="button" name="deleteAction" value="Delete" class="f-submit" onClick="if(confirm('Are you sure you wish to delete these objects?')){this.form.ObjectAction.value='delete';this.form.submit();}"></cfif>
</div>
<br class="clear" /><cfif qList.recordCount GT 0>
<table class="table-2" cellspacing="0">
<tr>
	<th scope="col">Select</th>
	<th scope="col">Edit</th>
	<th scope="col"><a href="/farcry/content/dmnews.cfm?orderby=label&order=asc">Label</a></th>
</tr><cfoutput query="qList">
<tr<cfif qList.currentRow MOD 2> class="alt"</cfif>>
	<td style="text-align:center"><input type="checkbox" class="f-checkbox" name="objectid" value="#qList.objectid#" onclick="setRowBackground(this);" /></td>
	<td style="text-align:center"><a href="/farcry/navajo/container_edit.cfm?containerid=#qList.objectid#"><img src="/farcry/images/treeImages/edit.gif" alt="Edit" title="Edit" /></a></td>
	<td style="text-align:left"><a href="/farcry/navajo/container_edit.cfm?containerid=#qList.objectid#">#qList.label#</a></td>
</tr></cfoutput>
</table>
<div class="utilBar f-subdued">
<input type="button" name="add" value="Add" class="f-submit" onClick="window.location='/farcry/navajo/container_edit.cfm';">
<input type="button" name="deleteAction" value="Delete" class="f-submit" onClick="if(confirm('Are you sure you wish to delete these objects?')){this.form.ObjectAction.value='delete';this.form.submit();}">
</div></cfif>
<br class="clear" />
<input type="hidden" name="ObjectAction" value="">
<input type="hidden" name="bFormSubmitted" value="yes">
</form>
</div>
<admin:footer>
