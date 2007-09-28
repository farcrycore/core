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
				Create "List latest" rule
				<cfif fileexists("#application.path.project#/packages/rules/ruleLatest#url.typename#.cfc") or fileexists("#application.path.project#/webskin/ruleLatest#url.typename#/execute.cfm")>
					<span style="color:red;">(file/s exist and would be overwritten)</span>
				</cfif>
			</td>
		</tr>
		<tr>
			<td align="right"><input type="checkbox" value="true" name="generateRuleSelected" id="generateRuleSelected" /></td>
			<td>
				Create "List selected" rule
				<cfif fileexists("#application.path.project#/packages/rules/ruleSelected#url.typename#.cfc") or fileexists("#application.path.project#/webskin/ruleSelected#url.typename#/execute.cfm")>
					<span style="color:red;">(file/s exist and would be overwritten)</span>
				</cfif>
			</td>
		</tr>
	</table>
</cfoutput>

<cfsetting enablecfoutputonly="false" />