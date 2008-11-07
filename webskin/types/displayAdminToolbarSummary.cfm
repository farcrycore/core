<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Low profile admin toolbar --->

<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />

<extjs:iframeDialog />

<cfif stObj.typename eq "farCOAPI">
	<cfset currenttype = stObj.name />
<cfelse>
	<cfset currenttype = stObj.typename />
</cfif>

<!--- DATA --->
<cfset aItems = arraynew(1) />

<!--- Status --->
<cfif structkeyexists(stObj,"status")>
	<cfset arrayappend(aItems,"Status: <span class='status #stObj.status#'>#application.rb.getResource('workflow.constants.#stObj.status#@label',stObj.status)#</span>") />
</cfif>

<!--- Current template --->
<cfif stObj.typename eq "farCOAPI">
	<cfif structkeyexists(url,"webskinused")>
		<cfquery dbtype="query" name="qWebskin">
			select		displayname
			from		application.stCOAPI.#currenttype#.qWebskins
			where		name='#url.webskinused#.cfm'
		</cfquery>
		
		<cfset arrayappend(aItems,"Type webskin: #qWebskin.displayname#") />
	</cfif>
<cfelse>
	<cfif structkeyexists(stObj,"displayMethod")>
		<cfquery dbtype="query" name="qWebskin">
			select		displayname
			from		application.stCOAPI.#stObj.typename#.qWebskins
			where		name='#stObj.displaymethod#.cfm'
		</cfquery>
		
		<cfset arrayappend(aItems,"Template: #qWebskin.displayname#") />
	</cfif>
</cfif>

<!--- ACTIONS --->
<cfset aActions = arraynew(1) />

<!--- Caching --->
<cfsavecontent variable="html">
	<cfoutput>
		{
			xtype:"tbbutton",
			iconCls:<cfif request.mode.flushcache>"cacheoff_icon"<cfelse>"cacheon_icon"</cfif>,
			text:<cfif request.mode.flushcache>"Cache Off"<cfelse>"Cache On"</cfif>,
			listeners:{
				"click":{
					fn:function(){
						<cfif request.mode.flushcache>
							parent.updateContent("#url.url#&flushcache=0");
						<cfelse>
							parent.updateContent("#url.url#&flushcache=1");
						</cfif>
						Ext.getBody().mask("Working...");
					}
				}
			}
		}
	</cfoutput>
</cfsavecontent>
<cfset arrayappend(aActions,html) />

<!--- View drafts --->
<cfsavecontent variable="html">
	<cfoutput>
		{
			xtype:"tbbutton",
			iconCls:<cfif request.mode.showdraft>"previewmode_icon"<cfelse>"previewmodedisabled_icon"</cfif>,
			text:<cfif request.mode.showdraft>"Showing Drafts"<cfelse>"Hiding Drafts"</cfif>,
			listeners:{
				"click":{
					fn:function(){
						<cfif request.mode.showdraft and structkeyexists(stObj,"versionid")>
							parent.updateContent("#url.url#&flushcache=1&showdraft=0");
						<cfelseif request.mode.showdraft>
							parent.updateContent("#url.url#&flushcache=1&showdraft=0");
						<cfelse>
							parent.updateContent("#url.url#&flushcache=0&showdraft=1");
						</cfif>
						Ext.getBody().mask("Working...");
					}
				}
			}
		}
	</cfoutput>
</cfsavecontent>
<cfset arrayappend(aActions,html) />

<!--- Container management --->
<sec:CheckPermission permission="ContainerManagement" objectid="#request.navid#">
	<cfsavecontent variable="html">
		<cfoutput>
			{
				xtype:"tbbutton",
				iconCls:<cfif request.mode.design and request.mode.showcontainers gt 0>"designmode_icon"<cfelse>"designmodedisabled_icon"</cfif>,
				text:<cfif request.mode.design and request.mode.showcontainers gt 0>"Showing Rules"<cfelse>"Hiding Rules"</cfif>,
				listeners:{
					"click":{
						fn:function(){
							<cfif request.mode.design and request.mode.showcontainers gt 0>
								parent.updateContent("#url.url#&designmode=0");
							<cfelse>
								parent.updateContent("#url.url#&designmode=1");
							</cfif>
							Ext.getBody().mask("Working...");
						}
					}
				}
			}
		</cfoutput>
	</cfsavecontent>
	<cfset arrayappend(aActions,html) />
</sec:CheckPermission>

<!--- Editing the object --->
<sec:CheckPermission objectid="#stObj.objectid#" typename="#stObj.typename#" permission="Edit">
	<cfif not stObj.typename eq "farCOAPI">
		<cfif structkeyexists(stObj,'status') and stObj.status eq "draft">
			<!--- If this is an unversioned object, ignore the status, just edit it --->
			<cfset editobjectid = stObj.objectid />
			<cfset editurl = "#application.url.webtop#/conjuror/invocation.cfm?objectid=#stObj.objectid#&method=edit&ref=&finishurl=&iframe=true" />
		<cfelseif structkeyexists(stObj,"versionid")>
			<!--- This object is versioned, but isn't in draft. Is there a draft version? --->
			<cfset qDraft = createObject("component", "#application.packagepath#.farcry.versioning").checkIsDraft(objectid=stobj.objectid,type=stobj.typename)>
			<cfif qDraft.recordcount>
				<!--- There is a draft version - edit that --->
				<cfset editobjectid = qDraft.objectid />
				<cfset editurl = "#application.url.webtop#/conjuror/invocation.cfm?objectid=#qDraft.objectid#&method=edit&ref=&finishurl=&iframe=true" />
			<cfelse>
				<!--- There isn't a draft version - create one --->
				<cfset editobjectid = "" />
				<cfset editurl = "#application.url.webtop#/conjuror/createDraftObject.cfm?objectid=#stObj.objectid#&ref=&finishurl=&iframe=true" />
			</cfif>
		<cfelse>
			<!--- If this is an unversioned object, ignore the status, just edit it --->
			<cfset editobjectid = stObj.objectid />
			<cfset editurl = "#application.url.webtop#/conjuror/invocation.cfm?objectid=#stObj.objectid#&method=edit&ref=&finishurl=&iframe=true" />
		</cfif>
		
		<cfsavecontent variable="html">
			<cfoutput>
				{
					xtype:"tbbutton",
					iconCls:"edit_icon",
					text:"Edit",
					listeners:{
						"click":{
							fn:function(){
								parent.editContent("#editurl#","Edit #stObj.label#",800,600,true<cfif len(editobjectid)>,function(){
									// make sure the object is unlocked
									Ext.Ajax.request({ 
										url: "#application.url.webtop#/navajo/unlock.cfm?objectid=#editobjectid#&typename=#stObj.typename#", 
										success: function() {
											location.href = location.href;
										}
									});
								}</cfif>);
							}
						}
					}
				}
			</cfoutput>
		</cfsavecontent>
		<cfset arrayappend(aActions,html) />
	</cfif>
</sec:CheckPermission>

<cfoutput>{
	xtype:"panel",
	layout:"border",
	items:[{
		xtype:"panel",
		region:"center",
		html:"<div class='traytext'><a href='#application.url.webtop#/' class='webtoplink' title='Webtop' target='_top'><img class='traytypeicon' src='#application.url.webtop#/facade/icon.cfm?icon=#stObj.typename#&size=16' alt='#stObj.typename#' /></a>#jsstringformat(arraytolist(aItems,'<span class=''separator''>|</span>'))#</div>",
		cls:"htmlpanel detailview"
	}<cfif arraylen(aActions)>,{
		xtype:"toolbar",
		region:"east",
		width:380,
		items:[
			#arraytolist(aActions)#
		]
	}</cfif>]
}</cfoutput>

<cfsetting enablecfoutputonly="false" />