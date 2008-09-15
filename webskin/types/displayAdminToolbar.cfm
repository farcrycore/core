<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Page admin toolbar --->
<!--- @@timeout: 0 --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />

<!--- The toolbar should only be added for the outermost object (not counting dmNavigation) --->
<cfif not structkeyexists(request,"addedtoolbar") and not stObj.typename eq "dmNavigation">
	<cfset request.addedtoolbar = true />
	
	<sec:CheckPermission generalpermission="Admin">
		
		<skin:view stObject="#stObj#" webskin="displayAdminToolbarSummary" r_html="summarytoolbar" />
		<skin:view stObject="#stObj#" webskin="displayAdminToolbarDetail" r_html="detailstoolbar" />
		
		<skin:htmlHead library="extjs" />
		<skin:htmlHead><cfoutput>
			<style type="text/css">
				##farcrytray .moredetail_icon { background:transparent url(#application.url.webtop#/js/ext/resources/images/default/panel/tool-sprites.gif) no-repeat scroll 0 -210px; height:15px; width:15px; }
				##farcrytray .lessdetail_icon { background:transparent url(#application.url.webtop#/js/ext/resources/images/default/panel/tool-sprites.gif) no-repeat scroll 0 -195px; height:15px; width:15px; }
				##farcrytray .edit_icon { background-image:url(#application.url.webtop#/facade/icon.cfm?icon=edit&size=16) !important; }
				##farcrytray .designmode_icon { background-image:url(#application.url.webtop#/facade/icon.cfm?icon=designmode&size=16) !important; }
				##farcrytray .previewmode_icon { background-image:url(#application.url.webtop#/facade/icon.cfm?icon=draftmode&size=16) !important; }
				##farcrytray { border-top: 1px solid ##0F7BD5; }
				##farcrytray .traytypeicon { margin-top:2px; vertical-align:middle; }
				##farcrytray .htmlpanel .x-panel-body { padding-left:5px; }
				##farcrytray .htmlpanel .x-panel-body, ##farcrytray .x-toolbar, ##farcrytray .x-table-layout-ct { background:##D7E4F3 none; border:0 none; }
				.separator { padding-left:5px; padding-right:5px; }
				##farcrytray a, ##farcrytray a:hover, ##farcrytray a:active, ##farcrytray a:visited { color: blue; font-weight:bold; }
				##farcrytray a, ##farcrytray a:active, ##farcrytray a:visited { text-decoration:none; }
				##farcrytray a:hover { text-decoration:underline; }
				##farcrytray a.webtoplink:hover { text-decoration:none; }
			</style>
		</cfoutput></skin:htmlHead>
		<extjs:onReady><cfoutput>
			var bodyhtml = Ext.getBody().dom.innerHTML;
			
			var summary = #summarytoolbar#;
			summary.region = "center";
			summary.border = false;
			
			var details = #detailstoolbar#;
			details.region = "center";
			details.border = false;
			
			Ext.getBody().dom.innerHTML = "";
			var all = new Ext.Viewport({
				layout:"border",
				items:[{
					region:"center",
					xtype:"panel",
					html:bodyhtml,
					autoScroll:true,
					border:false
				},{
					region:"south",
					xtype:"panel",
					layout:"card",
					activeItem:0,
					height:25,
					border:false,
					id:"farcrytray",
					
					items:[{
					
						xtype:"panel",
						layout:"border",
						items:[
							summary,
						{
							xtype:"toolbar",
							region:"east",
							items:[{
								xtype:"tbbutton",
								iconCls:"moredetail_icon",
								tooltip:"More detail",
								listeners:{
									"click":{
										fn:function(){
											var farcrytray = Ext.getCmp("farcrytray");
											farcrytray.setHeight(150);
											all.doLayout();
											farcrytray.getLayout().setActiveItem(1);
										}
									}
								}
							}]
						}],
						border:false
					
					},{
					
						xtype:"panel",
						layout:"border",
						items:[
							details,
						{
							xtype:"toolbar",
							region:"east",
							items:[{
								xtype:"tbbutton",
								iconCls:"lessdetail_icon",
								tooltip:"Less detail",
								listeners:{
									"click":{
										fn:function(){
											var farcrytray = Ext.getCmp("farcrytray");
											farcrytray.setHeight(25);
											all.doLayout();
											farcrytray.getLayout().setActiveItem(0);
										}
									}
								}
							}]
						}],
						border:false
					
					}]
				
				}]
			});
		</cfoutput></extjs:onReady>
		
		<!--- <skin:htmlHead library="extjs" />
		
		<skin:htmlHead id="pagetoolbar"><cfoutput>
			<style>
				##managepage { position:absolute; bottom:0; left:0; background:##ddd; border-top: 1px solid ##666; padding: 3px; width: 100%; }
				##managepage span.option label { display:inline; font-weight:bold; margin-left:10px; }
				##managepage span.option span.current { font-weight:bold; }
				##managepage span.option a, ##managepage span.option a:visited { color: ##E17000; text-decoration:none; }
				##managepage span.option a { text-decoration:none; }
				##managepage span.option .draft,
					##managepage span.option .draft a, 
					##managepage span.option .draft a:visited,
					##managepage span.option .hide,
					##managepage span.option .hide a, 
					##managepage span.option .hide a:visited { color: ##f00; }
				##managepage span.option .pending,
					##managepage span.option .pending a, 
					##managepage span.option .pending a:visited { color: ##E17000; }
				##managepage span.option .approved,
					##managepage span.option .approved a, 
					##managepage span.option .approved a:visited,
					##managepage span.option .show,
					##managepage span.option .show a, 
					##managepage span.option .show a:visited { color: ##009900; }
				##managepage span.option a:hover { text-decoration: underline; }
				@media screen{
					body>div##managepage{ position: fixed; }
				}
			</style>
		</cfoutput></skin:htmlHead>
		
		<cfif structkeyexists(request,"stObj")>
			<cfset thisurl = "#application.url.conjurer#?objectID=#request.stObj.ObjectID#" />
		<cfelse>
			<cfset thisurl = "#application.url.conjurer#?type=#listfirst(request.typewebskin,'.')#&view=#listlast(request.typewebskin,'.')#" />
		</cfif>
		
		<cfsavecontent variable="toolbar">
			<cfoutput>
				<div>&nbsp; </div>
				<div id='managepage'>
			</cfoutput>
			
			<cfif structkeyexists(stObj,"versionid") and not structkeyexists(request,"typewebskin")>
				<cfquery datasource="#application.dsn#" name="qVersions">
					select	*
					from	#application.dbowner##stObj.typename#
					where	versionid in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#stObj.versionid#,#stObj.objectid#" />)
							or objectid in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#stObj.versionid#,#stObj.objectid#" />)
					order by status
				</cfquery>
				
				<cfoutput>
					<span id="versions" class="option">
						<label>Version:</label>
				</cfoutput>
				
				<cfloop query="qVersions">
					<cfif stObj.objectid eq qVersions.objectid>
						<cfoutput>
							<span class="#qVersions.status# current">
								#ucase(left(qVersions.status,1))##mid(qVersions.status,2,len(qVersions.status))#
							</span>
						</cfoutput>
					<cfelse>
						<cfoutput>
							<span class="#qVersions.status#">
								<a href="#application.url.conjurer#?objectid=#qVersions.objectid#<cfif qVersions.status eq 'approved'>&showdraft=0<cfelse>&showdraft=1</cfif>">#ucase(left(qVersions.status,1))##mid(qVersions.status,2,len(qVersions.status))#</a>
							</span>
						</cfoutput>
					</cfif>
				</cfloop>
				
				<cfoutput>
					</span>
				</cfoutput>
			</cfif>
			
			<cfoutput>
				<span id="designmode" class="option">
					<label>Containers:</label>
					<cfif request.mode.design>
						<span class="show current">Show</span> <span class="hide"><a href="#thisurl#&designmode=0">Hide</a></span>
					<cfelse>
						<span class="show"><a href="#thisurl#&designmode=1">Show</a></span> <span class="hide current">Hide</span>
					</cfif>
				</span>
			</cfoutput>
			
			<cfif structkeyexists(stObj,"displaymethod")>
				<ft:object lFields="displaymethod" stObject="#stObj#" r_stFields="ftout" />
				
				<cfoutput>
					<span id="displaymethod" class="option">
						<label>Template:</label>
						#getWebskinDisplayname(typename=stobj.typename, template=stObj.displaymethod)#
					</span>
				</cfoutput>
			</cfif>
			
			<cfoutput>
				</div>
			</cfoutput>
		</cfsavecontent>
		
		<skin:htmlHead><cfoutput>
			<script type="text/javascript">
				Ext.onReady(function(){
					Ext.getBody().createChild("#jsstringformat(trim(toolbar))#").setOpacity(0.7);
				});
			</script>
		</cfoutput></skin:htmlHead> --->
		
	</sec:CheckPermission>
</cfif>

<cfsetting enablecfoutputonly="false" />