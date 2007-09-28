<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />

<cfoutput>
	<p>Generates a page where FarCry users can review and manage instances of this type from within the FarCry Admin.</p>
	<br/>
	<table>
		<tr>
			<td align="right"><input type="checkbox" value="true" name="generateTypeAdmin" id="generateTypeAdmin" /></td>
			<td><label for="generateTypeAdmin">Create type admin interface</label></td>
		</tr>
		<tr>
			<td align="right"><label for="typeadminTitle">Title</label></td>
			<td><input type="text" name="typeadminTitle" id="typeadminTitle" /></td>
		</tr>
		<tr>
			<td align="right"><label for="typeadminColumns">Columns</label></td>
			<td valign="top">
				<select multiple="multiple" name="typeadminColumns" id="typeadminColumns" size="8">
					<cfloop query="application.stCOAPI.#url.typename#.qMetaData">
						<cfif not listcontains("commentlog,ObjectID,lockedBy,locked,ownedby,status",propertyname)>
							<option value="#propertyname#">#propertyname#</option>
						</cfif>
					</cfloop>
				</select>
			</td>
		</tr>
	</table>
</cfoutput>

<cfsetting enablecfoutputonly="false" />