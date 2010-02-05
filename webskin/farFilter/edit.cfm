<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />


<cfquery datasource="#application.dsn#" name="qProperties">
SELECT objectid
FROM farFilterProperty
WHERE filterID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stobj.objectid#" />
ORDER BY datetimecreated
</cfquery>

<!--- Always need at least 1 filter property  --->
<cfif not qProperties.recordCount>
	<cfset stNew = application.fapi.getNewContentObject(typename="farFilterProperty", filterID="#stobj.objectid#") />
	<cfset stResult = application.fapi.setData(stProperties="#stNew#") />

	<!--- Rebuild the recordset --->
	<cfquery datasource="#application.dsn#" name="qProperties">
	SELECT objectid
	FROM farFilterProperty
	WHERE filterID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stobj.objectid#" />
	ORDER BY datetimecreated
	</cfquery>	
</cfif>


<ft:fieldset legend="Filter Name">

	<ft:object typename="#stobj.typename#" objectID="#stobj.objectid#" lFields="title" includeFieldset="false" />
	
</ft:fieldset>
	
<ft:fieldset legend="Filter Properties">


	<cfloop query="qProperties">
		<ft:object typename="farFilterProperty" objectID="#qProperties.objectid#" lfields="property,type,wddxDefinition,aRelated" r_stFields="stFields" />

		<ft:field label="#stFields.property.html#" labelAlignment="inline" bMultiField="true">
			
			<grid:div style="float:right;">
				<ft:button value="Delete Filter Property" text="" icon="ui-icon-minusthick" selectedObjectID="#qProperties.objectid#" />
				<ft:button value="Add Filter Property" text="" icon="ui-icon-plusthick" selectedObjectID="#stobj.objectid#" />
			</grid:div>
			<cfoutput>
				#stFields.type.html#
				#stFields.wddxDefinition.html#
				#stFields.aRelated.html#
			</cfoutput>
		</ft:field>
	</cfloop>
	<!---
	
	<cfif not qProperties.recordCount>
		<cfset stNew = application.fapi.getNewContentObject(typename="farFilterProperty", key="newFilterProperty", filterID="#stobj.objectid#") />

		<ft:object stobject="#stNew#" lfields="property,type,wddxDefinition,aRelated" r_stFields="stFields" />
	
		<ft:field label="#stFields.property.html#" labelAlignment="inline" bMultiField="true">
			<grid:div style="float:right;">
				<ft:button value="Add Filter Property" text="" icon="ui-icon-plusthick" selectedObjectID="#stobj.objectid#" />
			</grid:div>
			<cfoutput>
				#stFields.type.html#
				#stFields.wddxDefinition.html#
				#stFields.aRelated.html#
			</cfoutput>
		</ft:field>
	</cfif>--->
</ft:fieldset>
<!---<skin:onReady>
	<cfoutput>
		$('##predicatedFilter :input').attr('disabled', 'disabled');
	</cfoutput>
</skin:onReady>--->