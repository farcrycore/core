<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />

<cfoutput>
	<p>Generates two basic rules that allow a publisher to add a list of the latest items, or a list of selected items</p>
	<br/>
	<table>
		<tr>
			<td align="right"><input type="checkbox" value="true" name="generateRuleLatest" id="generateRuleLatest" /></td>
			<td>
				<label for="generateRuleLatest" style="width:auto;">Create "List latest" rule</label>
				<cfif fileexists("#application.path.project#/packages/rules/ruleLatest#url.scaffoldtypename#.cfc") or fileexists("#application.path.project#/webskin/ruleLatest#url.scaffoldtypename#/execute.cfm")>
					<span style="color:red;">(file/s exist and would be overwritten)</span>
				</cfif>
			</td>
		</tr>
		<tr>
			<td align="right"><input type="checkbox" value="true" name="generateRuleSelected" id="generateRuleSelected" /></td>
			<td>
				<label for="generateRuleSelected" style="width:auto;">Create "List selected" rule</label>
				<cfif fileexists("#application.path.project#/packages/rules/ruleSelected#url.scaffoldtypename#.cfc") or fileexists("#application.path.project#/webskin/ruleSelected#url.scaffoldtypename#/execute.cfm")>
					<span style="color:red;">(file/s exist and would be overwritten)</span>
				</cfif>
			</td>
		</tr>
	</table>
</cfoutput>

<cfsetting enablecfoutputonly="false" />