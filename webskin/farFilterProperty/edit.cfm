<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<ft:object typename="#stobj.typename#" objectID="#stobj.objectid#" lfields="property,type,wddxDefinition,aRelated" r_stFields="stFields" />

<cfoutput>
<tr>
	<td>
		#stFields.property.html#<br>
		#stFields.type.html#
	</td>
	<td>
		#stFields.wddxDefinition.html#
		#stFields.aRelated.html#
	</td>
	<td style="white-space:nowrap;">
		<ft:button value="Delete Filter Property" text="" icon="ui-icon-minusthick" selectedObjectID="#stobj.objectid#" />
		<ft:button value="Add Filter Property" text="" icon="ui-icon-plusthick" selectedObjectID="#stobj.filterID#" />
	</td>
</tr>
</cfoutput>

