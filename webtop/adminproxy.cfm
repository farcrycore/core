<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Admin Proxy --->
<!--- @@description: Provides access to the website with added administrative functionality --->

<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="url.h" default="" /><!--- The page request hash --->
<cfif len(url.h)>
	<cfset thisurl = session.fc.requests[url.h].url />
	<cfset trayurl = session.fc.requests[url.h].tray />
<cfelse>
	<cfset thisurl = "#application.url.webroot#/" />
	<cfset trayurl = "#application.url.webroot#/index.cfm?objectid=#application.navid.home#&view=displayAdminToolbar" />
</cfif>

<skin:htmlHead library="ExtJS" />
<extjs:iframeDialog />
<skin:htmlHead><cfoutput>
	<script type="text/javascript">
		var traystate = "summary";
		
		function updateTray(newtray,title) {
			// update the tray
			document.getElementById("farcry_tray").src = newtray+(newtray.indexOf("?")?"&":"?")+"&tray="+traystate;
			document.title = 'Administration View - '+title;
		};
		
		function resizeTray(height) {
			Ext.get("farcrytraypanel").setHeight(height);
			Ext.getCmp("farcrylayout").doLayout();
		};
		
		function updateContent(url) {
			document.getElementById("farcry_content").src = url;
		};
		
		function editContent(url,title,width,height,modal) {
			frames.farcry_content.openScaffoldDialog(url,title,width,height,modal);
		};
		
		function rememberTrayState(state) {
			traystate = state;
		};
	</script>
</cfoutput></skin:htmlhead>
<extjs:onReady><cfoutput>
	Ext.ux.IFrameComponent = Ext.extend(Ext.BoxComponent, {
		onRender : function(ct, position){
			this.el = ct.createChild({tag: 'iframe', id: this.id, name:this.id, frameBorder: 0, src: this.url});
		}
	});
	
	var all = new Ext.Viewport({
		layout:"border",
		border:false,
		id:"farcrylayout",
		items:[{
			region:"center",
			xtype:"panel",
			layout:"fit",
			border:false,
			items:[new Ext.ux.IFrameComponent({ id: "farcry_content", url: "#thisurl#" })]
		},{
			region:"south",
			xtype:"panel",
			height:22,
			layout:"fit",
			border:false,
			id:"farcrytraypanel",
			items:[new Ext.ux.IFrameComponent({ id: "farcry_tray", url: "" })]
		}]
	});	
</cfoutput></extjs:onReady>

<cfoutput>
	<html>
		<head>
			<title>Administration View</title>
		</head>
		<body>
		</body>
	</html>
</cfoutput>

<cfsetting enablecfoutputonly="false" />