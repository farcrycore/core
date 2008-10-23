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
	
	<cfparam name="url.tray" default="summary" />
	
	<sec:CheckPermission generalpermission="Admin">
		<skin:view stObject="#stObj#" webskin="displayAdminToolbarSummary" r_html="summarytoolbar" />
		<skin:view stObject="#stObj#" webskin="displayAdminToolbarDetail" r_html="detailstoolbar" />
		
		<skin:htmlHead library="jQueryJS" />
		<skin:htmlHead><cfoutput>
			<style type="text/css">
				/* Tray layout */
				body{
					margin:0;
					padding:0 0 0 0;
					font
				}
				
				/* Tray style */
				##farcrytray .moredetail_icon { background:transparent url(#application.url.webtop#/js/ext/resources/images/default/panel/tool-sprites.gif) no-repeat scroll 0 -210px; height:15px; width:15px; }
				##farcrytray .lessdetail_icon { background:transparent url(#application.url.webtop#/js/ext/resources/images/default/panel/tool-sprites.gif) no-repeat scroll 0 -195px; height:15px; width:15px; }
				##farcrytray .edit_icon { background-image:url(#application.url.webtop#/facade/icon.cfm?icon=edit&size=16) !important; }
				##farcrytray .designmode_icon { background-image:url(#application.url.webtop#/facade/icon.cfm?icon=designmode&size=16) !important; }
				##farcrytray .designmodedisabled_icon { background-image:url(#application.url.webtop#/facade/icon.cfm?icon=designmodedisabled&size=16) !important; }
				##farcrytray .previewmode_icon { background-image:url(#application.url.webtop#/facade/icon.cfm?icon=draftmode&size=16) !important; }
				##farcrytray .previewmodedisabled_icon { background-image:url(#application.url.webtop#/facade/icon.cfm?icon=draftmodedisabled&size=16) !important; }
				##farcrytray .updateapp_icon { background-image:url(#application.url.webtop#/facade/icon.cfm?icon=updateapp&size=16) !important; }
				##farcrytray .logout_icon { background-image:url(#application.url.webtop#/facade/icon.cfm?icon=logout&size=16) !important; }
				
				##farcrytray.previewmodeon { border-top: 1px solid ##A291AB; }
				##farcrytray.previewmodeoff { border-top: 1px solid ##0F7BD5; }
				##farcrytray.previewmodeon .htmlpanel .x-panel-body, ##farcrytray.previewmodeon .x-toolbar, ##farcrytray.previewmodeon .x-table-layout-ct { background:##DAC3E6 none; border:0 none; }
				##farcrytray.previewmodeoff .htmlpanel .x-panel-body, ##farcrytray.previewmodeoff .x-toolbar, ##farcrytray.previewmodeoff .x-table-layout-ct { background:##D7E4F3 none; border:0 none; }
				
				.htmlpanel td { background:transparent; padding:0; }
				
				##farcrytray .traytypeicon { vertical-align:middle; }
				##farcrytray .htmlpanel .x-panel-body { padding-left:5px; }
				##farcrytray .separator { padding-left:5px; padding-right:5px; }
				##farcrytray a, ##farcrytray a:hover, ##farcrytray a:active, ##farcrytray a:visited { color: blue; font-weight:bold; }
				##farcrytray a, ##farcrytray a:active, ##farcrytray a:visited { text-decoration:none; }
				##farcrytray a:hover { text-decoration:underline; }
				##farcrytray a.webtoplink:hover { text-decoration:none; }
				##farcrytray img { border: 0 none; }
				##farcrytray * { color: ##333; font-family: arial,tahoma,helvetica,sans-serif; text-align: left; font-size:13px; }
				##farcrytray .x-toolbar { padding:0; }
				##farcrytray .traytext { padding:3px; }
			</style>
			
			<script type="text/javascript">
				var tray = "";
				
				function changeView(view) {
					var info = { 
						"summary":{ index:0, height:22 }, 
						"detail":{ index:1, height:150 } 
					}[view];
					var farcrytray = Ext.getCmp("farcrytray");
					
					parent.resizeTray(info.height);
					farcrytray.setHeight(info.height);
					farcrytray.doLayout();
					farcrytray.getLayout().setActiveItem(info.index);
					
					parent.rememberTrayState(view);
				};
				
				jQ(function(){
					jQ(document.body).append("</div><div id='loggedin_tray'></div>");
					
					var summary = #summarytoolbar#;
					summary.region = "center";
					summary.border = false;
					
					var details = #detailstoolbar#;
					details.region = "center";
					details.border = false;
					
					var tray = new Ext.Panel({
						renderTo:"loggedin_tray",
						layout:"card",
						activeItem:0,
						height:22,
						border:false,
						id:"farcrytray",
						cls:<cfif request.mode.showdraft>"previewmodeon"<cfelse>"previewmodeoff"</cfif>,
						
						items:[{
					
							xtype:"panel",
							layout:"border",
							items:[
								summary,
							{
								xtype:"toolbar",
								region:"west",
								items:[{
									xtype:"tbbutton",
									iconCls:"moredetail_icon",
									tooltip:"More detail",
									listeners:{
										"click":{
											fn:function(){
												changeView("detail");
											}
										}
									}
								},{
									xtype:"tbbutton",
									iconCls:"updateapp_icon",
									tooltip:"Update App",
									listeners:{
										"click":{
											fn:function(){
												if (confirm('Are you sure you want to update the appication?'))
													parent.updateContent("#application.url.webroot#/index.cfm?objectid=#stObj.objectid#&updateapp=1");
											}
										}
									}
								},{
									xtype:"tbbutton",
									iconCls:"logout_icon",
									tooltip:"Logout",
									listeners:{
										"click":{
											fn:function(){
												if (confirm('Are you sure you want to log out of FarCry?'))
													top.location = "#application.url.webroot#/index.cfm?objectid=#stObj.objectid#&logout=1";
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
								xtype:"panel",
								region:"west",
								layout:"table",
								border:"none",
								layoutConfig:{
									columns:1
								},
								items:[{
									xtype:"toolbar",
									border:"none",
									items:[{
										xtype:"tbbutton",
										iconCls:"lessdetail_icon",
										tooltip:"Less detail",
										listeners:{
											"click":{
												fn:function(){
													changeView("summary");
												}
											}
										}
									}]
								},{
									xtype:"toolbar",
									items:[{
										xtype:"tbbutton",
										iconCls:"updateapp_icon",
										tooltip:"Update App",
										listeners:{
											"click":{
												fn:function(){
													if (confirm('Are you sure you want to update the appication?'))
														parent.updateContent("#application.url.webroot#/index.cfm?objectid=#stObj.objectid#&updateapp=1");
												}
											}
										}
									}]
								},{
									xtype:"toolbar",
									items:[{
										xtype:"tbbutton",
										iconCls:"logout_icon",
										tooltip:"Logout",
										listeners:{
											"click":{
												fn:function(){
													if (confirm('Are you sure you want to log out of FarCry?'))
														top.location = "#application.url.webroot#/index.cfm?objectid=#stObj.objectid#&logout=1";
												}
											}
										}
									}]
								}]
							}],
							border:false
						}]
					});
					<cfif url.tray neq "summary">
						changeView("detail");
					</cfif>
				});
			</script>
		</cfoutput></skin:htmlHead>
		
	</sec:CheckPermission>
</cfif>

<cfsetting enablecfoutputonly="false" />