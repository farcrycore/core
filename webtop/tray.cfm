<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Admin Proxy --->
<!--- @@description: Provides access to the website with added administrative functionality --->

<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="url.h" default="" /><!--- The page request hash --->
<cfif structkeyexists(url,"url") and len(url.url)>
	<cfset thisurl = url.url />
<cfelse>
	<cfset thisurl = "#application.url.webroot#/" />
</cfif>

<cfparam name="session.dmProfile.bShowTray" default="true" />
<cfif not session.dmProfile.bShowTray>
	<cflocation url="#thisurl#" addtoken="false" />
</cfif>

<skin:htmlHead library="ExtJS" />
<extjs:iframeDialog />
<skin:htmlHead><cfoutput>
	<script type="text/javascript">
		if (window.location.hash.length && window.location.hash!=="##" && window.location.hash.indexOf("|"))
			traystate = window.location.hash.slice(1).split("|")[1];
		else
			traystate = "summary";
		currenturl = "";
		
		function updateTray(newtray,title,newurl) {
			// update the tray
			frames['farcry_tray'].location.href = newtray+(newtray.indexOf("?")?"&":"?")+"&tray="+traystate+"&url="+encodeURIComponent(newurl);
			document.title = 'Administration View - '+title;
			currenturl = newurl;
			window.location.hash = encodeURIComponent(currenturl)+"|"+traystate;
		};
		
		function resizeTray(height) {
			Ext.getCmp("farcrytraypanel").setHeight(height);
			Ext.getCmp("farcrylayout").doLayout();
		};
		
		function updateContent(url) {
			frames['farcry_content'].location.href = url;
		};
		
		function editContent(url,title,width,height,modal,onclose) {
			frames.farcry_content.openScaffoldDialog(url,title,width,height,modal,onclose);
		};
		
		function refreshContent() {
			frames['farcry_content'].location.href = frames['farcry_content'].location.href;
		};
		
		function rememberTrayState(state) {
			traystate = state;
			window.location.hash = encodeURIComponent(currenturl)+"|"+traystate;
		};
	</script>
</cfoutput></skin:htmlHead>
<extjs:onReady><cfoutput>
	Ext.ux.IFrameComponent = Ext.extend(Ext.BoxComponent, {
		onRender : function(ct, position){
			this.el = ct.createChild({tag: 'iframe', id: this.id, name:this.id, frameBorder: 0, src: this.url});
		}
	});
	
	// On page refresh, if there is a URL in the hash, reuse that url instead;
	if (window.location.hash.length && window.location.hash!=="##")
		thisurl = window.location.hash.slice(1).split("|")[0];
	else
		thisurl = "#thisurl#";
	
	if (!thisurl.match(/^\\/))
		thisurl = decodeURIComponent(thisurl);
	
	var all = new Ext.Viewport({
		layout:"border",
		border:false,
		id:"farcrylayout",
		hideMode:"offsets",
		items:[{
			region:"center",
			xtype:"panel",
			layout:"fit",
			border:false,
			items:[new Ext.ux.IFrameComponent({ id: "farcry_content", url: thisurl })]
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