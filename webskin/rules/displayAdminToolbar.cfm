<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Rule Management Toolbar --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!--- Environment Variables --->
<cfparam name="stParam.originalID" default="#getRuleContainerID(stobj.objectid)#" />

<cfset ruleContainerID = getRuleContainerID(stobj.objectid) />

<cfset containerURL = application.fapi.getLink(type="container", objectid="#stParam.originalID#", view="displayContainer", urlParameters="ajaxmode=1&designmode=1") />
<cfset containerID = replace(stParam.originalID,'-','','ALL') />

<cfset ruleDisplayName = application.fapi.getContentTypeMetadata(stobj.typename, "displayName", stobj.typename) />


<cfoutput>
	<div class="ruleadmin clearfix">
		
		<!--- Rule Label --->
		<div style="float:left;padding:2px;">
			<span style="display:inline-block;margin-right:0" class="ui-icon ui-icon-wrench"></span> #ruleDisplayName#
		</div>	
	
		<div style="float:right;">
			<!--- EDIT RULE --->
			<a title="Configure Rule" 
				class="con-admin con-edit-rule" 
				href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&typename=#stObj.typename#&method=editInPlace&originalID=#stParam.originalID#&iframe" 
				rule:title="#ruleDisplayName#"
				con:id="#containerID#"
				con:url="#containerURL#">
				
				<span class="ui-icon ui-icon-pencil" style="float:left;">&nbsp;</span>
			</a>
			<skin:toolTip selector=".con-edit-rule">Edit the settings applicable to this rule.</skin:toolTip>
			
			
			<!--- MOVE UP --->
			<cfif arguments.stParam.index gt 1>
				<cfset actionURL = application.fapi.getLink(type="container", objectid="#ruleContainerID#", view="displayContainer", urlParameters="ajaxmode=1&rule_id=#stobj.objectid#&rule_index=#arguments.stParam.index#&rule_action=moveup&originalID=#stParam.originalID#") />
				
				<a title="Move up"
					class="con-refresh con-move-up-rule" 
					href="#actionURL#" 
					con:id="#containerID#">
					<span class="ui-icon ui-icon-circle-triangle-n" style="float:left;">&nbsp;</span>
				</a>
				<skin:toolTip selector=".con-move-up-rule">Move this rule UP in the container.</skin:toolTip>
			</cfif>
			
			<!--- MOVE DOWN --->
			<cfif arguments.stParam.index lt arguments.stParam.arraylen>
				<cfset actionURL = application.fapi.getLink(type="container", objectid="#ruleContainerID#", view="displayContainer", urlParameters="ajaxmode=1&rule_id=#stobj.objectid#&rule_index=#arguments.stParam.index#&rule_action=movedown&originalID=#stParam.originalID#") />
				
				<a title="Move down"
					class="con-refresh con-move-down-rule" 
					href="#actionURL#" 
					con:id="#containerID#">
					<span class="ui-icon ui-icon-circle-triangle-s" style="float:left;">&nbsp;</span>
				</a>
				<skin:toolTip selector=".con-move-down-rule">Move this rule DOWN in the container.</skin:toolTip>
			
			</cfif>
			
			<!--- DELETE --->
			<cfset actionURL = application.fapi.getLink(type="container", objectid="#ruleContainerID#", view="displayContainer", urlParameters="ajaxmode=1&rule_id=#stobj.objectid#&rule_index=#arguments.stParam.index#&rule_action=delete&originalID=#stParam.originalID#") />
			
			<a title="Delete"
				class="con-delete con-delete-rule" 
				href="#actionURL#" 
				con:id="#containerID#">
				<span class="ui-icon ui-icon-circle-close" style="float:left;">&nbsp;</span>
			</a>
			<skin:toolTip selector=".con-delete-rule">Delete this rule from the container.</skin:toolTip>
		</div>

		<br style="clear:both;" />
	</div>
</cfoutput>

<cfsetting enablecfoutputonly="false" />