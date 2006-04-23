<!--- set up page header --->
<cfimport taglib="/farcry/tags/admin/" prefix="admin">
<admin:header>

<cfimport taglib="/fourq/tags" prefix="q4">
<cfparam name="url.type" type="string" default="dmHTML">

<!--- Get all objects of the type defined in application.cfm --->
<cfquery datasource="#application.fourq.dsn#" name="qObjects">
SELECT * FROM #url.type#
</cfquery>

<cfoutput>
<h3>Object Browser (#url.type#)</h3>

<a href="editobject.cfm?type=#url.type#">[CREATE]</a>
</cfoutput>

<table width="100%" border="0" cellspacing="3" cellpadding="3" bgcolor="cccccc">
<tr bgcolor="cccccc">
	<td>&nbsp;</td>
	<td><b>ObjectID</b></td>
	<td><b>Label</b></td>
	<td><b>Created</b></td>
	<td><b>LastUpdated</b></td>
</tr>
<cfoutput query="qObjects">
<tr bgcolor="ededed">
	<td><a href="editObject.cfm?oid=#objectid#&type=#url.type#">[edit]</a> <a href="deleteObject.cfm?oid=#objectid#&type=#url.type#">[delete]</a>
<a href="editTree.cfm?oid=#objectID#&type=#url.type#">[tree]</a>
</td>
	<td><a href="displayobject.cfm?oid=#objectid#&type=#url.type#">#objectid#</a></td>
	<td>#label#</td>
	<td>#createdby#(#timeformat(datetimecreated)#)</td>
	<td>#lastupdatedby#(#timeformat(datetimelastupdated)#)</td>
</tr>
</cfoutput>
</table>

<!--- setup footer --->
<admin:footer>
