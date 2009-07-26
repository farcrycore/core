<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset session.fc.trayWebskin = "displayAdminBarHidden" />
<skin:onReady>
<cfoutput>
$j('##open-tray').click(function(){
	$fc.traySwitch('displayAdminBarSummary');
});
</cfoutput>
</skin:onReady>
<cfoutput>
<img id="open-tray" src="#application.url.webtop#/facade/icon.cfm?icon=toggletray&size=64" />
</cfoutput>