
<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />


<!--- STPARAMS --->
<cfparam name="stParam.q" type="query" />


<cfoutput>
<table class="reverseuuid-sortable">
	<thead>
		<tr>
			<cfif listFindNoCase(stParam.q.columnList, "seq")>
				<th>grip</th>
			</cfif>
			<th>label</th>
			<th>manage</th>
		</tr>
	</thead>
	
	<tbody>
		<cfloop query="stParam.q">
			<tr objectid="#stParam.q.objectid#">
				<cfif listFindNoCase(stParam.q.columnList, "seq")>
					<td class="reverseuuid-gripper" style="cursor:move"><i class="fa fa-sort"></i></td>
				</cfif>
				<td>#stParam.q.label#</td>
				<td>
					<ft:button type="button" value="edit" renderType="link" class="reverseuuid-edit" />
					<ft:button type="button" value="delete" renderType="link" class="reverseuuid-delete" />
				</td>
			</tr>
		</cfloop>
	</tbody>
</table>
</cfoutput>

<ft:buttonPanel>
	<ft:button type="button" value="add" renderType="link" class="reverseuuid-add" />
</ft:buttonPanel>

