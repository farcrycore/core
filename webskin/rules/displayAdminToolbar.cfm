<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Rule management toolbar --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset ruleContainerID = getRuleContainerID(stobj.objectid) />
<cfset containerURL = application.fapi.getLink(objectid="#ruleContainerID#", view="displayContainer", urlParameters="ajaxmode=1&designmode=1") />
<cfset containerID = replace(ruleContainerID,'-','','ALL') />

<cfset ruleDisplayName = application.fapi.getContentTypeMetadata(stobj.typename, "displayName", stobj.typename) />

<cfoutput>
	<div class="ruleadmin">
		
		<!--- Rule Label --->
		<div style="float:left;padding:2px;">
			<span style="font-size:10px;">RULE:</span> #application.stCOAPI[stObj.typename].displayname#
		</div>	
	
		<div style="float:right;">
			<!--- EDIT RULE --->
			<a id="con-edit-rule-#stobj.objectid#" href="##" title="Configure rule">
				<span class="ui-icon ui-icon-pencil" style="float:left;">&nbsp;</span>
			</a>
			<skin:onReady>
				<cfoutput>
	            	$j('##con-edit-rule-#stobj.objectid#').click(function() {
						$fc.containerAdmin('#jsStringFormat(ruleDisplayName)#', '#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&method=editInPlace&iframe', '#containerID#', '#containerURL#');
						return false;
					});								
	            </cfoutput>
			</skin:onReady>	
			<skin:toolTip id="con-edit-rule-#stobj.objectid#">Edit the settings applicable to this rule.</skin:toolTip>
			
			
			<!--- MOVE UP --->
			<cfif arguments.stParam.index gt 1>
				<a id="con-move-up-rule-#stobj.objectid#" href="##" title="Move up">
					<span class="ui-icon ui-icon-circle-triangle-n" style="float:left;">&nbsp;</span>
				</a>
			
				<cfset actionURL = application.fapi.getLink(objectid="#ruleContainerID#", view="displayContainer", urlParameters="ajaxmode=1&rule_id=#stobj.objectid#&rule_index=#arguments.stParam.index#&rule_action=moveup") />
				<skin:onReady>
					<cfoutput>
		            	$j('##con-move-up-rule-#stobj.objectid#').click(function() {
							$fc.reloadContainer('#containerID#','#actionURL#');	
							return false;
						});								
		            </cfoutput>
				</skin:onReady>	
				<skin:toolTip id="con-move-up-rule-#stobj.objectid#">Move this rule UP in the container.</skin:toolTip>
			</cfif>
			
			<!--- MOVE DOWN --->
			<cfif arguments.stParam.index lt arguments.stParam.arraylen>
				<a id="con-move-down-rule-#stobj.objectid#" href="##" title="Move down">
					<span class="ui-icon ui-icon-circle-triangle-s" style="float:left;">&nbsp;</span>
				</a>
				<cfset actionURL = application.fapi.getLink(objectid="#ruleContainerID#", view="displayContainer", urlParameters="ajaxmode=1&rule_id=#stobj.objectid#&rule_index=#arguments.stParam.index#&rule_action=movedown") />
				<skin:onReady>
					<cfoutput>
		            	$j('##con-move-down-rule-#stobj.objectid#').click(function() {
							$fc.reloadContainer('#containerID#','#actionURL#');	
							return false;
						});								
		            </cfoutput>
				</skin:onReady>
				<skin:toolTip id="con-move-down-rule-#stobj.objectid#">Move this rule DOWN in the container.</skin:toolTip>
			
			</cfif>
			
			<!--- DELETE --->
			<a id="con-delete-rule-#stobj.objectid#" href="##" title="Delete">
				<span class="ui-icon ui-icon-circle-close" style="float:left;">&nbsp;</span>
			</a>
			<cfset actionURL = application.fapi.getLink(objectid="#ruleContainerID#", view="displayContainer", urlParameters="ajaxmode=1&rule_id=#stobj.objectid#&rule_index=#arguments.stParam.index#&rule_action=delete") />
			<skin:onReady>
				<cfoutput>
	            	$j('##con-delete-rule-#stobj.objectid#').click(function() {					
						if(!confirm('Are you sure you wish to delete this rule (#jsStringFormat(ruleDisplayName)#)?')){return false}
						$fc.reloadContainer('#containerID#','#actionURL#');	
						return false;
					});							
	            </cfoutput>
			</skin:onReady>
			<skin:toolTip id="con-delete-rule-#stobj.objectid#">Delete this rule from the container.</skin:toolTip>
		</div>

		<br style="clear:both;" />
	</div>
</cfoutput>

<cfsetting enablecfoutputonly="false" />