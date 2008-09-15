<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Low profile admin toolbar --->

<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />

<extjs:iframeDialog />

<!--- DATA --->
<cfset aItems = arraynew(1) />

<!--- Status --->
<cfif structkeyexists(stObj,"status")>
	<cfset arrayappend(aItems,"Status: #stObj.status#") />
</cfif>

<!--- Current template --->
<cfif structkeyexists(stObj,"displayMethod")>
	<cfquery dbtype="query" name="qWebskin">
		select		displayname
		from		application.stCOAPI.#stObj.typename#.qWebskins
		where		name='#stObj.displaymethod#.cfm'
	</cfquery>
	
	<cfset arrayappend(aItems,"Template: #qWebskin.displayname#") />
</cfif>


<!--- ACTIONS --->
<cfset aActions = arraynew(1) />

<!--- View drafts --->
<cfsavecontent variable="html">
	<cfoutput>
		{
			xtype:"tbbutton",
			iconCls:"previewmode_icon",
			text:"Preview mode",
			enableToggle:true,
			allowDepress:true,
			pressed:#request.mode.showdraft#,
			listeners:{
				"click":{
					fn:function(){
						<cfif request.mode.showdraft and structkeyexists(stObj,"versionid")>
							window.location = "#application.url.webroot#/index.cfm?objectid=#stObj.versionid#&flushcache=1&showdraft=0";
						<cfelseif request.mode.showdraft>
							window.location = "#application.url.webroot#/index.cfm?objectid=#stObj.objectid#&flushcache=1&showdraft=0";
						<cfelse>
							window.location = "#application.url.webroot#/index.cfm?objectid=#stObj.objectid#&flushcache=0&showdraft=1";
						</cfif>
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
				iconCls:"designmode_icon",
				text:"Design mode",
				enableToggle:true,
				allowDepress:true,
				pressed:#request.mode.design and request.mode.showcontainers#,
				listeners:{
					"click":{
						fn:function(){
							<cfif request.mode.design and request.mode.showcontainers gt 0>
								window.location = "#application.url.webroot#/index.cfm?objectid=#stObj.objectid#&designmode=0";
							<cfelse>
								window.location = "#application.url.webroot#/index.cfm?objectid=#stObj.objectid#&designmode=1";
							</cfif>
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
	<cfelseif structkeyexists(stObj,"status")>
		<cfset qDraft = createObject("component", "#application.packagepath#.farcry.versioning").checkIsDraft(objectid=stobj.objectid,type=stobj.typename)>
		<cfif qDraft.recordcount>
			<cfset editableid = qDraft.objectid />
		<cfelse>
			<cfset editableid = "" />
		</cfif>
	<cfelse>
		<cfset editableid = stObj.objectid />
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
								openScaffoldDialog("#application.url.webtop#/conjuror/invocation.cfm?objectid=#editableid#&method=edit&ref=&finishurl=&iframe=true","Edit #stObj.label#",800,600,true);
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
		html:"<a href='#application.url.webtop#/' class='webtoplink' title='Webtop'><img class='traytypeicon' src='#application.url.webtop#/facade/icon.cfm?icon=farcrycore&size=16' alt='#stObj.typename#' /></a>#jsstringformat(arraytolist(aItems,'<span class=''separator''>|</span>'))#",
		cls:"htmlpanel"
	}<cfif arraylen(aActions)>,{
		xtype:"toolbar",
		region:"east",
		items:[
			#arraytolist(aActions)#
		]
	}</cfif>]
}</cfoutput>

<cfsetting enablecfoutputonly="false" />