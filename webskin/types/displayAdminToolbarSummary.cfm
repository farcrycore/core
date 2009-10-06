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
<cfif request.mode.flushcache>
	<cfset rurl = application.fapi.fixURL(url=url.url,addvalues='flushcache=0') />
<cfelse>
	<cfset rurl = application.fapi.fixURL(url=url.url,addvalues='flushcache=1') />
</cfif>
<cfsavecontent variable="html">
	<cfoutput>
		{
			xtype:"tbbutton",
			iconCls:<cfif request.mode.flushcache>"cacheoff_icon"<cfelse>"cacheon_icon"</cfif>,
			text:<cfif request.mode.flushcache>"Cache Off"<cfelse>"Cache On"</cfif>,
			listeners:{
				"click":{
					fn:function(){
						parent.updateContent("#rurl#");
						Ext.getBody().mask("Working...");
					}
				}
			}
		}
	</cfoutput>
</cfsavecontent>
<cfset arrayappend(aActions,html) />

<!--- View drafts --->
<cfif request.mode.showdraft and structkeyexists(stObj,"versionid")>
	<cfset rurl = application.fapi.fixURL(url=url.url,addvalues='flushcache=1&showdraft=0') />
<cfelseif request.mode.showdraft>
	<cfset rurl = application.fapi.fixURL(url=url.url,addvalues='flushcache=1&showdraft=0') />
<cfelse>
	<cfset rurl = application.fapi.fixURL(url=url.url,addvalues='flushcache=0&showdraft=1') />
</cfif>
<cfsavecontent variable="html">
	<cfoutput>
		{
			xtype:"tbbutton",
			iconCls:<cfif request.mode.showdraft>"previewmode_icon"<cfelse>"previewmodedisabled_icon"</cfif>,
			text:<cfif request.mode.showdraft>"Showing Drafts"<cfelse>"Hiding Drafts"</cfif>,
			listeners:{
				"click":{
					fn:function(){
						parent.updateContent("#rurl#");
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
	<cfif request.mode.design and request.mode.showcontainers gt 0>
		<cfset rurl = application.fapi.fixURL(url=url.url,addvalues='designmode=0') />
	<cfelse>
		<cfset rurl = application.fapi.fixURL(url=url.url,addvalues='designmode=1') />
	</cfif>
	<cfsavecontent variable="html">
		<cfoutput>
			{
				xtype:"tbbutton",
				iconCls:<cfif request.mode.design and request.mode.showcontainers gt 0>"designmode_icon"<cfelse>"designmodedisabled_icon"</cfif>,
				text:<cfif request.mode.design and request.mode.showcontainers gt 0>"Showing Rules"<cfelse>"Hiding Rules"</cfif>,
				listeners:{
					"click":{
						fn:function(){
							parent.updateContent("#rurl#");
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
		<cfset editurl = "#application.url.webtop#/edittabOverview.cfm?objectid=#stObj.objectid#&typename=#stObj.typename#&method=edit&ref=iframe" />
		
		<cfsavecontent variable="html">
			<cfoutput>
				{
					xtype:"tbbutton",
					iconCls:"edit_icon",
					text:"Edit",
					listeners:{
						"click":{
							fn:function(){
								parent.editContent("#editurl#","Edit #stObj.label#",800,600,true,function(){
									// make sure the object is unlocked
									Ext.Ajax.request({ 
										url: "#application.url.webtop#/navajo/unlock.cfm?objectid=#stObj.objectid#&typename=#stObj.typename#", 
										success: function() {
											parent.refreshContent();
										}
									});
								});
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