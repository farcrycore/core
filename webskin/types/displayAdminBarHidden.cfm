<cfsetting enablecfoutputonly="true" />
<cfsetting showdebugoutput="false" />

<!--- @@viewBinding: any --->
<!--- @@viewStack: fragment --->


<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<cfset session.fc.trayWebskin = "displayAdminBarHidden" />
<skin:onReady>
<cfoutput>
$j('##open-tray').click(function(){
	$fc.traySwitch('displayAdminBarDetail');
	return false;
});
</cfoutput>
</skin:onReady>
<cfoutput>
<img id="open-tray" src="#application.url.webtop#/facade/icon.cfm?icon=toggletray&size=64" style="width:32px;height:32px;" />
</cfoutput>

<cfsetting enablecfoutputonly="false" />