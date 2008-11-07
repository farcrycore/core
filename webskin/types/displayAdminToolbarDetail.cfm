<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Detailed admin toolbar --->

<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset iDeveloperPermission = application.security.checkPermission(permission="developer") />

<extjs:iframeDialog />

<cfif stObj.typename eq "farCOAPI">
	<cfset currenttype = stObj.name />
<cfelse>
	<cfset currenttype = stObj.typename />
</cfif>

<!--- DATA --->
<cfsavecontent variable="dataconfig"><cfoutput>
	{
		xtype:"panel",
		region:"center",
		layout:"table",
		border:"none",
		cls:"htmlpanel detailview",
		layoutConfig:{
			columns:2
		},
		items:[{
			xtype:"panel",
			colspan:2,
			cls:"htmlpanel",
			cellCls:"typename",
			html:</cfoutput>
			
			<cfif structKeyExists(application.stcoapi,"#currenttype#") AND structKeyExists(application.stcoapi[currenttype],"displayname")>
				<cfoutput>"#application.stcoapi[currenttype].displayname#"</cfoutput>
			<cfelse>
				<cfoutput>"#currenttype#"</cfoutput>
			</cfif>
		
		<cfoutput>
		},{
			xtype:"panel",
			cls:"htmlpanel",
			html:"#application.rb.getResource("workflow.labels.locking@label","URL")#",
			cellCls:"label"
		},{
			xtype:"panel",
			cls:"htmlpanel",
			html:"#url.url#",
			cellCls:"value"
		}</cfoutput>
		
		<cfif stObj.typename eq "farCOAPI">
			<cfquery dbtype="query" name="qWebskin">
				select		displayname
				from		application.stCOAPI.#currenttype#.qWebskins
				where		name='#url.webskinused#.cfm'
			</cfquery>
			
			<cfoutput>
				,{
					xtype:"panel",
					cls:"htmlpanel",
					html:"#application.rb.getResource('coapi.farCOAPI.properties.typewebskin@label','Type webskin:')#",
					cellCls:"label"
				},{
					xtype:"panel",
					cls:"htmlpanel",
					html:"#qWebskin.displayname#",
					cellCls:"value"
				}
			</cfoutput>
		<cfelse>
			<cfoutput>,{
				xtype:"panel",
				cls:"htmlpanel",
				html:"#application.rb.getResource("workflow.labels.locking@label","Locking")#",
				cellCls:"label"
			},{
				xtype:"panel",
				cls:"htmlpanel",
				html:</cfoutput>
				
				<cfif stobj.locked and stobj.lockedby eq session.security.userid>
					<!--- locked by current user --->
					<cfset tDT=application.thisCalendar.i18nDateTimeFormat(stobj.dateTimeLastUpdated,session.dmProfile.locale,application.mediumF)>
					<cfoutput>
						"<span style='color:red'>#application.rb.formatRBString("workflow.labels.lockedwhen@label",tDT,"Locked ({1})")#</span> <a href='#application.url.webtop#/navajo/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#' onclick='Ext.getBody().mask(\"Working...\");Ext.Ajax.request({url:this.href,success:function(){ location.href=location.href; } });return false;' target='_top'>[#application.rb.getResource("workflow.buttons.unlock@label","Unlock")#]</a>"
					</cfoutput>
				<cfelseif stobj.locked>
					<!--- locked by another user --->
					<cfset subS=listToArray('#application.thisCalendar.i18nDateFormat(stobj.dateTimeLastUpdated,session.dmProfile.locale,application.mediumF)#,#stobj.lockedby#')>
					<cfoutput>"#application.rb.formatRBString('workflow.labels.lockedby@label',subS,'<span style=\"color:red\">Locked ({1})</span> by {2}')#</cfoutput>
					
					<!--- check if current user is a sysadmin so they can unlock --->
					<cfif iDeveloperPermission eq 1><!--- show link to unlock --->
						<cfoutput>
							<a href='#application.url.webtop#/navajo/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#' onclick='Ext.getBody().mask(\"Working...\");Ext.Ajax.request({url:this.href,success:function(){ location.href=location.href; } });return false;' target='_top'>[#application.rb.getResource("workflow.buttons.unlock@label","Unlock")#]</a>
						</cfoutput>
					</cfif>
					
					<cfoutput>"</cfoutput>
				<cfelse><!--- no locking --->
					<cfoutput>"#application.rb.getResource("workflow.labels.unlocked@unlocked","Unlocked")#"</cfoutput>
				</cfif>
			
			<cfoutput>,
				cellCls:"value"
			},{
				xtype:"panel",
				cls:"htmlpanel",
				html:"#getI18Property('datetimelastupdated','label')#",
				cellCls:"label"
			},{
				xtype:"panel",
				cls:"htmlpanel",
				html:"#application.thisCalendar.i18nDateFormat(stobj.datetimelastupdated,session.dmProfile.locale,application.mediumF)#",
				cellCls:"value"
			},{
				xtype:"panel",
				cls:"htmlpanel",
				html:"#getI18Property('lastupdatedby','label')#",
				cellCls:"label"
			},{
				xtype:"panel",
				cls:"htmlpanel",
				html:"#stobj.lastupdatedby#",
				cellCls:"value"
			}</cfoutput>
			
			<cfif structkeyexists(stObj,"status")>
				<cfoutput>
					,{
						xtype:"panel",
						cls:"htmlpanel",
						html:"#getI18Property('status','label')#",
						cellCls:"label"
					},{
						xtype:"panel",
						cls:"htmlpanel",
						html:"#application.rb.getResource('workflow.constants.#stobj.status#@label',stObj.status)#",
						cellCls:"value"
					}
				</cfoutput>
			</cfif>
			
			<cfif structkeyexists(stObj,"displaymethod")>
				<cfquery dbtype="query" name="qWebskin">
					select		displayname
					from		application.stCOAPI.#stObj.typename#.qWebskins
					where		name='#stObj.displaymethod#.cfm'
				</cfquery>
				
				<cfoutput>
					,{
						xtype:"panel",
						cls:"htmlpanel",
						html:"#getI18Property('displaymethod','label')#",
						cellCls:"label"
					},{
						xtype:"panel",
						cls:"htmlpanel",
						html:"#qWebskin.displayname#",
						cellCls:"value"
					}
				</cfoutput>
			</cfif>
		</cfif>
		
	<cfoutput>
		]
	}
</cfoutput></cfsavecontent>


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
		region:"west",
		width:48,
		html:"<a href='#application.url.webtop#/' class='webtoplink' title='Webtop' target='_top'><img class='traytypeicon' src='#application.url.webtop#/facade/icon.cfm?icon=#stObj.typename#&size=48' alt='#stObj.typename#' /></a>",
		cls:"htmlpanel"
	},#dataconfig#
	<cfif arraylen(aActions)>,{
		xtype:"panel",
		region:"east",
		width:120,
		layout:"table",
		border:"none",
		layoutConfig:{
			columns:1
		},
		items:[
			<cfloop from="1" to="#arraylen(aActions)#" index="i">
				<cfif i neq 1>,</cfif>
				{
					xtype:"toolbar",
					border:"none",
					items:[
						#aActions[i]#
					]
				}
			</cfloop>
		]
		
	}</cfif>]
}</cfoutput>

<cfsetting enablecfoutputonly="false" />