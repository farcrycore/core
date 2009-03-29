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
		<cfif stObj.typename eq "farCOAPI">
			<skin:view typename="#stObj.name#" webskin="displayAdminToolbarSummary" r_html="summarytoolbar" bAllowTrace="false" />
			<skin:view typename="#stObj.name#" webskin="displayAdminToolbarDetail" r_html="detailstoolbar" bAllowTrace="false" />
		<cfelse>
			<skin:view stObject="#stObj#" webskin="displayAdminToolbarSummary" r_html="summarytoolbar" bAllowTrace="false" />
			<skin:view stObject="#stObj#" webskin="displayAdminToolbarDetail" r_html="detailstoolbar" bAllowTrace="false" />
		</cfif>
		
		<skin:htmlHead library="jQueryJS" />
		<skin:htmlHead><cfoutput>
			<style type="text/css">
				@import url("#application.url.webtop#/css/tray.css");
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
					var summary = #reReplace(summarytoolbar,"</?webskin.*?>","","ALL")#;
					summary.region = "center";
					summary.border = false;
					
					var details = #reReplace(detailstoolbar,"</?webskin.*?>","","ALL")#;
					details.region = "center";
					details.border = false;
					
					var tray = new Ext.Panel({
						renderTo:"loggedin_tray",
						layout:"card",
						activeItem:0,
						height:22,
						border:false,
						id:"farcrytray",
						hideMode:"offsets",
						cls:<cfif request.mode.showdraft>"previewmodeon"<cfelse>"previewmodeoff"</cfif>,
						
						items:[{
					
							xtype:"panel",
							layout:"border",
							items:[
								summary,
							{
								xtype:"toolbar",
								region:"west",
								width:87,
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
									iconCls:"toggletray_icon",
									tooltip:"Disable tray",
									listeners:{
										"click":{
											fn:function(){
												top.location = "#url.url#&bShowTray=0";
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
												if (confirm('Are you sure you want to update the application?'))
													parent.updateContent("#url.url#&updateapp=1");
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
													top.location = "#url.url#&logout=1";
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
								width:22,
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
										iconCls:"toggletray_icon",
										tooltip:"Toggle tray",
										listeners:{
											"click":{
												fn:function(){
													top.location = "#url.url#&bShowTray=0";
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
													if (confirm('Are you sure you want to update the application?'))
														parent.updateContent("#url.url#&updateapp=1");
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
														top.location = "#url.url#&logout=1";
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
		
		<cfoutput><div id='loggedin_tray'></div></cfoutput>
	</sec:CheckPermission>
</cfif>

<cfsetting enablecfoutputonly="false" />