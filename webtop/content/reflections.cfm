<cfsetting enablecfoutputonly="true" />

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/widgets/" prefix="widgets">

<!--- environment variables --->
<cfparam name="bFormSubmitted" default="false" type="boolean" />
<cfparam name="message_error" default="" type="string" />
<cfparam name="ObjectAction" default="" type="string" />

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

<!---------------------------------------------------------- 
VIEW:
	- build shared container administration
----------------------------------------------------------->
<admin:header title="Reflection Admin" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#" onload="setupPanes('container1');">

<cfoutput>
<div id="genadmin-wrap">
<h1>Shared Container Management</h1>
</cfoutput>

<cfif message_error NEQ "">
	<cfoutput>
	<p id="fading1" class="fade"><span class="error">#message_error#</span></p>
	</cfoutput>
</cfif>

<cfoutput>
<form name="frm" action="#cgi.script_name#" method="post">
<div class="utilBar f-subdued">
<input type="button" name="add" value="Add" class="f-submit" onClick="window.location='#application.url.farcry#/navajo/container_edit.cfm';"><cfif qList.recordCount GT 0>
<input type="button" name="deleteAction" value="Delete" class="f-submit" onClick="if(confirm('Are you sure you wish to delete these objects?')){this.form.ObjectAction.value='delete';this.form.submit();}"></cfif>
</div>
<br class="clear" />
</cfoutput>

<cfif qList.recordCount>
	<cfoutput>
	<table class="table-2" cellspacing="0">
	<tr>
		<th scope="col">Select</th>
		<th scope="col">Edit</th>
		<th scope="col"><a href="#application.url.farcry#/content/dmnews.cfm?orderby=label&order=asc">Label</a></th>
	</tr>
	</cfoutput>
	<cfoutput query="qList">
	<tr<cfif qList.currentRow MOD 2> class="alt"</cfif>>
		<td style="text-align:center"><input type="checkbox" class="f-checkbox" name="objectid" value="#qList.objectid#" onclick="setRowBackground(this);" /></td>
		<td style="text-align:center"><a href="#application.url.farcry#/navajo/container_edit.cfm?containerid=#qList.objectid#"><img src="#application.url.farcry#/images/treeImages/edit.gif" alt="Edit" title="Edit" /></a></td>
		<td style="text-align:left"><a href="#application.url.farcry#/navajo/container_edit.cfm?containerid=#qList.objectid#">#qList.label#</a></td>
	</tr>
	</cfoutput>
	
	<cfoutput>
	</table>
	<div class="utilBar f-subdued">
	<input type="button" name="add" value="Add" class="f-submit" onClick="window.location='#application.url.farcry#/navajo/container_edit.cfm';">
	<input type="button" name="deleteAction" value="Delete" class="f-submit" onClick="if(confirm('Are you sure you wish to delete these objects?')){this.form.ObjectAction.value='delete';this.form.submit();}">
	</div>
	</cfoutput>
</cfif>

<cfoutput>
<br class="clear" />
<input type="hidden" name="ObjectAction" value="">
<input type="hidden" name="bFormSubmitted" value="yes">
</form>
</div>
</cfoutput>

<!--- build webtop footer --->
<admin:footer>

<cfsetting enablecfoutputonly="false" />