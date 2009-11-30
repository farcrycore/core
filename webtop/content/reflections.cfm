<cfsetting enablecfoutputonly="true" />

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">

<!--- environment variables --->
<cfparam name="bFormSubmitted" default="false" type="boolean" />
<cfparam name="message_error" default="" type="string" />
<cfparam name="ObjectAction" default="" type="string" />

<cfset oType = CreateObject("component","#application.packagepath#.rules.container")>

<ft:processform action="Delete" >
	<cfif structKeyExists(form, "objectid")>
		<cfloop list="#objectid#" index="iObjectID">
			<cfset returnstruct = oType.delete(iObjectID)>
			<cfif NOT returnstruct.bSuccess>
				<cfset message_error = returnstruct.message>
			</cfif>
		</cfloop>	
	</cfif>
</ft:processForm>

<cfset qList = oType.getSharedContainers()>

<!---------------------------------------------------------- 
VIEW:
	- build shared container administration
----------------------------------------------------------->

<admin:header title="Reflected Containers" />

<ft:objectadmin 
	typename="container"
	title="Reflected Containers"
	qRecordSet="#qList#"
	columnList=""
	lcustomcolumns="cellActions"
	sortableColumns=""
	lFilterFields="label"
	sqlorderby="label" />
	
	<!--- 	module="/dmEvent.cfm" --->

<admin:footer />
<!---
<admin:header title="Reflection Admin" writingDir="#session.writingDir#" userLanguage="#session.userLanguage#" onload="setupPanes('container1');">


<ft:form name="frm" action="#cgi.script_name#" method="post">

<cfoutput>
<h1>Shared Container Management</h1>
</cfoutput>

<cfif message_error NEQ "">
	<cfoutput>
	<div id="errorMsg">#message_error#</div>
	</cfoutput>
</cfif>


	<ft:buttonPanel>
		<ft:button value="Add" url="#application.url.farcry#/navajo/container_edit.cfm" />
		
		<cfif qList.recordCount GT 0>
			<ft:button value="Delete" text="Delete Selected" style="margin-left:5px;" confirmText="Are you sure you wish to delete these objects?" />
		</cfif>
	</ft:buttonPanel>


<cfif qList.recordCount>
	<cfoutput>
	<table width="100%" class="objectAdmin">
	<tr>
		<th scope="col" style="width:60px;">Select</th>
		<th scope="col" style="width:60px;">Edit</th>
		<th scope="col"><a href="#application.url.farcry#/content/dmnews.cfm?orderby=label&order=asc">Label</a></th>
	</tr>
	</cfoutput>
	
	<cfoutput query="qList">
	<tr<cfif qList.currentRow MOD 2> class="alt"</cfif>>
		<td style="text-align:center"><input type="checkbox" class="f-checkbox" name="objectid" value="#qList.objectid#" onclick="setRowBackground(this);" /></td>
		<td style="text-align:center"><skin:buildLink objectid="#qList.objectid#"><img src="#application.url.farcry#/images/treeImages/edit.gif" alt="Edit" title="Edit" /></a></td>
		<td style="text-align:left"><a href="#application.url.farcry#/navajo/container_edit.cfm?containerid=#qList.objectid#">#qList.label#</a></td>
	</tr>
	</cfoutput>
	
	<cfoutput>
	</cfoutput>
</cfif>

</ft:form>

<!--- build webtop footer --->
<admin:footer>--->

<cfsetting enablecfoutputonly="false" />