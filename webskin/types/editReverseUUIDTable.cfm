
<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />


<!--- STPARAMS --->
<cfparam name="stParam.q" type="query" />
<cfparam name="stParam.stMetadata" type="struct" />


<cfoutput>
<div class="multiField">
	<table class="table table-striped reverseuuid-sortable" style="margin:0px;">
		<cfif listFindNoCase(stParam.q.columnList, "seq")>
			<col style="width:24px;" >
		</cfif>
		<col style="" >
		<col style="width:100px;" >
		<thead>
			<tr>
				<cfif listFindNoCase(stParam.q.columnList, "seq")>
					<th>&nbsp;</th>
				</cfif>
				<th>Label</th>
				<th>Manage</th>
			</tr>
		</thead>
		
		<tbody>
			<cfloop query="stParam.q">
				<tr objectid="#stParam.q.objectid#">
					<cfif listFindNoCase(stParam.q.columnList, "seq")>
						<td class="reverseuuid-gripper" style="cursor:move"><i class="fa fa-sort"></i></td>
					</cfif>
					<td>
						<skin:view objectid="#stParam.q.objectid#" webskin="librarySelected" />
					</td>
					<td>
						<ft:button type="button" value="edit" class="reverseuuid-edit btn-small" icon="fa-pencil" text="" />
						<ft:button type="button" value="delete" class="reverseuuid-delete btn-small" icon="fa-trash-o" text="" />
					</td>
				</tr>
			</cfloop>
		</tbody>
	</table>
	<ft:buttonPanel style="text-align:left;">
		<ft:button type="button" value="Add" class="reverseuuid-add btn-small" icon="fa-plus" text="Add New" priority="default" />
	</ft:buttonPanel>
</div>
</cfoutput>


