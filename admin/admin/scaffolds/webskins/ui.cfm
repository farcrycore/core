<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />

<cfoutput>
	<p>Generates the two basic webskins a public facing type needs</p>
	<br/>
	<table>
		<tr>
			<td align="right"><input type="checkbox" value="true" name="generateWebskinPage" id="generateWebskinPage" /></td>
			<td><label for="generateWebskinPage">Create standard page</label></td>
		</tr>
		<tr align="right">
			<td><input type="checkbox" value="true" name="generateWebskinTeaser" id="generateWebskinTeaser" /></td>
			<td><label for="generateWebskinTeaser">Create standard teaser</label></td>
		</tr>
	</table>
</cfoutput>

<cfsetting enablecfoutputonly="false" />