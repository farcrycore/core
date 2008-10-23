<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Detailed admin toolbar --->

<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset iDeveloperPermission = application.security.checkPermission(permission="developer") />

<extjs:iframeDialog />


<!--- DATA --->
<skin:htmlHead><cfoutput>
	<style>
		##farcrytray dt { margin-top: 2px; float:left; clear: left; width:120px; }
		##farcrytray .typename { font-size:113%; font-weight:bold; }
		##farcrytray .label { font-weight:bold; }
		##farcrytray .value {}
	</style>
</cfoutput></skin:htmlHead>
<cfsavecontent variable="dataconfig"><cfoutput>
	{
		xtype:"panel",
		region:"center",
		layout:"table",
		border:"none",
		cls:"htmlpanel",
		layoutConfig:{
			columns:2
		},
		items:[{
			xtype:"panel",
			colspan:2,
			cls:"htmlpanel",
			cellCls:"typename",
			html:</cfoutput>
			
			<cfif structKeyExists(application.stcoapi,"#stobj.typename#") AND structKeyExists(application.stcoapi[stobj.typename],"displayname")>
				<cfoutput>"#application.stcoapi[stobj.typename].displayname#"</cfoutput>
			<cfelse>
				<cfoutput>"#stobj.typename#"</cfoutput>
			</cfif>
		
		<cfoutput>
		},{
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
					"<span style='color:red'>#application.rb.formatRBString("workflow.labels.lockedwhen@label",tDT,"Locked ({1})")#</span> <a href='navajo/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#'>[#application.rb.getResource("workflow.buttons.unlock@label","Unlock")#]</a>"
				</cfoutput>
			<cfelseif stobj.locked>
				<!--- locked by another user --->
				<cfset subS=listToArray('#application.thisCalendar.i18nDateFormat(stobj.dateTimeLastUpdated,session.dmProfile.locale,application.mediumF)#,#stobj.lockedby#')>
				<cfoutput>"#application.rb.formatRBString('workflow.labels.lockedby@label',subS,'<span style="color:red">Locked ({1})</span> by {2}')#"</cfoutput>
				
				<!--- check if current user is a sysadmin so they can unlock --->
				<cfif iDeveloperPermission eq 1><!--- show link to unlock --->
					<cfoutput>
						"<a href='navajo/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#'>[#application.rb.getResource("workflow.buttons.unlock@label","Unlock")#]</a>"
					</cfoutput>
				</cfif>
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
	<cfoutput>
		]
	}
</cfoutput></cfsavecontent>


<!--- ACTIONS --->
<cfset aActions = arraynew(1) />

<!--- View drafts --->
<cfsavecontent variable="html">
	<cfoutput>
		{
			xtype:"tbbutton",
			<cfif request.mode.showdraft>iconCls:"previewmode_icon",<cfelse>iconCls:"previewmodedisabled_icon",</cfif>
			text:"Preview mode",
			listeners:{
				"click":{
					fn:function(){
						<cfif request.mode.showdraft and structkeyexists(stObj,"versionid")>
							parent.updateContent("#session.fc.requests[url.key].url#&flushcache=1&showdraft=0");
						<cfelseif request.mode.showdraft>
							parent.updateContent("#session.fc.requests[url.key].url#&flushcache=1&showdraft=0");
						<cfelse>
							parent.updateContent("#session.fc.requests[url.key].url#&flushcache=0&showdraft=1");
						</cfif>
						Ext.getBody().mask("Loading...");
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
				<cfif request.mode.design and request.mode.showcontainers gt 0>iconCls:"designmode_icon",<cfelse>iconCls:"designmodedisabled_icon",</cfif>
				text:"Design mode",
				listeners:{
					"click":{
						fn:function(){
							<cfif request.mode.design and request.mode.showcontainers gt 0>
								parent.updateContent("#session.fc.requests[url.key].url#&designmode=0");
							<cfelse>
								parent.updateContent("#session.fc.requests[url.key].url#&designmode=1");
							</cfif>
							Ext.getBody().mask("Loading...");
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
	<cfif structkeyexists(stObj,"status") and stObj.status eq "draft">
		<cfset editableid = stObj.objectid />
	<cfelseif structkeyexists(stObj,"versionid")>
		<cfset qDraft = createObject("component", "#application.packagepath#.farcry.versioning").checkIsDraft(objectid=stobj.objectid,type=stobj.typename)>
		<cfif qDraft.recordcount>
			<cfset editableid = qDraft.objectid />
		<cfelse>
			<cfset editableid = "" />
		</cfif>
	<cfelseif not structkeyexists(stObj,"status")>
		<cfset editableid = stObj.objectid />
	<cfelse>
		<cfset editableid = "" />
	</cfif>
	
	<cfif len(editableid)>
		<cfsavecontent variable="html">
			<cfoutput>
				{
					xtype:"tbbutton",
					iconCls:"edit_icon",
					text:"Edit",
					listeners:{
						"click":{
							fn:function(){
								parent.openScaffoldDialog("#application.url.webtop#/conjuror/invocation.cfm?objectid=#editableid#&method=edit&ref=&finishurl=&iframe=true","Edit #stObj.label#",800,600,true);
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
		html:"<a href='#application.url.webtop#/' class='webtoplink' title='Webtop' target='_top'><img class='traytypeicon' src='#application.url.webtop#/facade/icon.cfm?icon=#stObj.typename#&size=48' alt='#stObj.typename#' /></a>",
		cls:"htmlpanel"
	},#dataconfig#
	<cfif arraylen(aActions)>,{
		xtype:"panel",
		region:"east",
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