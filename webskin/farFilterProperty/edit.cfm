<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<skin:loadCSS id="fc-fontawesome" />

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
		<ft:button value="Delete Filter Property" text="" icon="fa-minus-square-o" selectedObjectID="#stobj.objectid#" />
		<ft:button value="Add Filter Property" text="" icon="fa-plus" selectedObjectID="#stobj.filterID#" />
	</td>
</tr>
</cfoutput>

