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
$j("##open-tray").hover(
	function() {
		$j(this).addClass('icon-over');
	},
	function() {
		$j(this).removeClass('icon-over');
	}
);	
</cfoutput>
</skin:onReady>

<skin:icon id="open-tray" icon='toggletray' size='32' style="margin-left:20px;cursor:pointer;" />

<cfsetting enablecfoutputonly="false" />