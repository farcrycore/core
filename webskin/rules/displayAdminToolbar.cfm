<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Rule management toolbar --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />

<ft:object stObject="#stObj#" format="display" r_stFields="stProps" />


<cfset containerURL = application.fapi.getLink(objectid="#arguments.stParam.container#", view="displayContainer", urlParameters="ajaxmode=1&designmode=1") />
<cfset containerID = replace(arguments.stParam.container,'-','','ALL') />

<cfset ruleDisplayName = application.fapi.getContentTypeMetadata(stobj.typename, "displayName", stobj.typename) />

<cfoutput>
	<div class="ruleadmin">
	
		<!--- EDIT RULE --->
		<a id="con-edit-rule-#stobj.objectid#" href="##" title="Configure rule">
			<img src="#application.url.webtop#/facade/icon.cfm?icon=editrule&size=16" border="0" alt="Edit rule" />
		</a>
		<skin:onReady>
			<cfoutput>
            	$j('##con-edit-rule-#stobj.objectid#').click(function() {
					$fc.containerAdmin('#jsStringFormat(ruleDisplayName)#', '#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&method=editInPlace&container=#arguments.stParam.container#&iframe', '#containerID#', '#containerURL#');
					return false;
				});								
            </cfoutput>
		</skin:onReady>	
		
		<!--- MOVE UP --->
		<cfif arguments.stParam.index gt 1>
			<a id="con-move-up-rule-#stobj.objectid#" href="##" title="Move up">
				<img src="#application.url.webtop#/facade/icon.cfm?icon=uparrow&size=16" border="0" alt="Move up" />
			</a>
		</cfif>
		<cfset actionURL = application.fapi.getLink(objectid="#arguments.stParam.container#", view="displayContainer", urlParameters="ajaxmode=1&rule_id=#stobj.objectid#&rule_index=#arguments.stParam.index#&rule_action=moveup") />
		<skin:onReady>
			<cfoutput>
            	$j('##con-move-up-rule-#stobj.objectid#').click(function() {
					$fc.reloadContainer('#containerID#','#actionURL#');	
					return false;
				});								
            </cfoutput>
		</skin:onReady>	
		
		<!--- MOVE DOWN --->
		<cfif arguments.stParam.index lt arguments.stParam.arraylen>
			<a id="con-move-down-rule-#stobj.objectid#" href="##" title="Move down">
				<img src="#application.url.webtop#/facade/icon.cfm?icon=downarrow&size=16" border="0" alt="Move down" style="" />
			</a>
		</cfif>
		<cfset actionURL = application.fapi.getLink(objectid="#arguments.stParam.container#", view="displayContainer", urlParameters="ajaxmode=1&rule_id=#stobj.objectid#&rule_index=#arguments.stParam.index#&rule_action=movedown") />
		<skin:onReady>
			<cfoutput>
            	$j('##con-move-down-rule-#stobj.objectid#').click(function() {
					$fc.reloadContainer('#containerID#','#actionURL#');	
					return false;
				});								
            </cfoutput>
		</skin:onReady>
		
		<!--- DELETE --->
		<a id="con-delete-rule-#stobj.objectid#" href="##" title="Delete">
			<img src="#application.url.webtop#/facade/icon.cfm?icon=deleterule&size=16" border="0" alt="Delete" />
		</a>
		<cfset actionURL = application.fapi.getLink(objectid="#arguments.stParam.container#", view="displayContainer", urlParameters="ajaxmode=1&rule_id=#stobj.objectid#&rule_index=#arguments.stParam.index#&rule_action=delete") />
		<skin:onReady>
			<cfoutput>
            	$j('##con-delete-rule-#stobj.objectid#').click(function() {					
					if(!confirm('Are you sure you wish to delete this rule (#jsStringFormat(ruleDisplayName)#)?')){return false}
					$fc.reloadContainer('#containerID#','#actionURL#');	
				});							
            </cfoutput>
		</skin:onReady>
		
		<!--- EDIT RULE --->
		<div class="title">
			<a id="con-edit-title-rule-#stobj.objectid#" href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&method=editInPlace&container=#arguments.stParam.container#" target="_blank" onclick="openScaffoldDialog(this.href+'&iframe','EDIT: #application.stCOAPI[stObj.typename].displayname#',800,600,true,function(){ reloadContainer('#request.thiscontainer#'); });return false;">#application.stCOAPI[stObj.typename].displayname#</a>
		</div>
		<skin:onReady>
			<cfoutput>
            	$j('##con-edit-title-rule-#stobj.objectid#').click(function() {
					$fc.containerAdmin('#jsStringFormat(ruleDisplayName)#', '#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&method=editInPlace&container=#arguments.stParam.container#&iframe', '#containerID#', '#containerURL#');
					return false;
				});								
            </cfoutput>
		</skin:onReady>	
	</div>
</cfoutput>

<cfsetting enablecfoutputonly="false" />