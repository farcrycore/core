<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />

<cfoutput>
	<p>Generates two basic rules that allow a publisher to add a list of the latest items, or a list of selected items</p>
	<br/>
	<table>
		<tr>
			<td align="right"><input type="checkbox" value="true" name="generateRuleLatest" id="generateRuleLatest" /></td>
			<td><label for="generateRuleLatest">Create "List latest" rule</label></td>
		</tr>
		<tr align="right">
			<td><input type="checkbox" value="true" name="generateRuleSelected" id="generateRuleSelected" /></td>
			<td><label for="generateRuleSelected">Create "List selected" rule</label></td>
		</tr>
	</table>
</cfoutput>

<cfsetting enablecfoutputonly="false" />