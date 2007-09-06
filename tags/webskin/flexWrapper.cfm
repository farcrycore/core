<!--- start enable output only from cfoutput tags --->
<cfsetting enablecfoutputonly="yes" />

<!--- 
|| DESCRIPTION || 
$Description: flexWrapper tag - embbeds compiled flex swf. $

|| DEVELOPER ||
$Developer: Patrick Tai (pat@daemon.com.au) $

|| ATTRIBUTES ||
$in: SWFSource -- defines SWF source $
$in: flexAssetsPath -- Location of the flex assets : optional $
--->

<cfif thistag.executionMode eq "Start">

<!--- SWFSource : defines SWF source --->
<cfparam name="attributes.SWFSource" default="" />
<cfparam name="attributes.SWFID" default="" />
<cfparam name="attributes.flashVars" default="" />
<cfparam name="attributes.flexAssetsPath" default="#application.url.farcry#/admin/ui/flexassets" />
<cfparam name="attributes.FAbridgeJS" default="" />


<cfif attributes.flashVars neq "">
	<cfset attributes.flashVars="#attributes.flashVars#&">
</cfif>

<cfsavecontent variable="flexInHead">
<cfoutput>
<script src="#attributes.flexAssetsPath#/AC_OETags.js" language="javascript"></script>
<cfif attributes.FAbridgeJS neq "">
	<script src="#attributes.flexAssetsPath#/FABridge.js" language="javascript"></script>
	<script language="javascript">
	#attributes.FAbridgeJS#
	</script>
</cfif>
<script language="JavaScript" type="text/javascript">
<!--
// -----------------------------------------------------------------------------
// Globals
// Major version of Flash required
var requiredMajorVersion = 9;
// Minor version of Flash required
var requiredMinorVersion = 0;
// Minor version of Flash required
var requiredRevision = 0;
// -----------------------------------------------------------------------------
// -->
</script>
</cfoutput>
</cfsavecontent>
<cfhtmlhead text="#flexInHead#">
<cfoutput>
<script language="JavaScript" type="text/javascript" src="#attributes.flexAssetsPath#/history.js"></script>

<script language="JavaScript" type="text/javascript">
<!--
// Version check for the Flash Player that has the ability to start Player Product Install (6.0r65)
var hasProductInstall = DetectFlashVer(6, 0, 65);

// Version check based upon the values defined in globals
var hasRequestedVersion = DetectFlashVer(requiredMajorVersion, requiredMinorVersion, requiredRevision);


// Check to see if a player with Flash Product Install is available and the version does not meet the requirements for playback
if ( hasProductInstall && !hasRequestedVersion ) {
	// MMdoctitle is the stored document.title value used by the installation process to close the window that started the process
	// This is necessary in order to close browser windows that are still utilizing the older version of the player after installation has completed
	// DO NOT MODIFY THE FOLLOWING FOUR LINES
	// Location visited after installation is complete if installation is required
	var MMPlayerType = (isIE == true) ? "ActiveX" : "PlugIn";
	var MMredirectURL = window.location;
    document.title = document.title.slice(0, 47) + " - Flash Player Installation";
    var MMdoctitle = document.title;

	AC_FL_RunContent(
		"src", "playerProductInstall",
		"FlashVars", "MMredirectURL="+MMredirectURL+'&MMplayerType='+MMPlayerType+'&MMdoctitle='+MMdoctitle+"",
		"width", "100%",
		"height", "100%",
		"align", "middle",
		"id", "#attributes.SWFID#",
		"quality", "high",
		"bgcolor", "##ffffff",
		"name", "#attributes.SWFID#",
		"allowScriptAccess","sameDomain",
		"type", "application/x-shockwave-flash",
		"pluginspage", "http://www.adobe.com/go/getflashplayer"
	);
} else if (hasRequestedVersion) {
	// if we've detected an acceptable version
	// embed the Flash Content SWF when all tests are passed
	AC_FL_RunContent(
			"src", "#listFirst(attributes.SWFSource,'.')#",
			"width", "100%",
			"height", "100%",
			"align", "middle",
			"id", "#attributes.SWFID#",
			"quality", "high",
			"bgcolor", "##ffffff",
			"name", "#attributes.SWFID#",
			"flashvars",'#attributes.flashVars#historyUrl=#attributes.flexAssetsPath#/history.htm%3F&lconid=' + lc_id + '',
			"allowScriptAccess","sameDomain",
			"type", "application/x-shockwave-flash",
			"pluginspage", "http://www.adobe.com/go/getflashplayer"
	);
  } else {  // flash is too old or we can't detect the plugin
    var alternateContent = 'Alternate HTML content should be placed here. '
  	+ 'This content requires the Adobe Flash Player. '
   	+ '<a href=http://www.adobe.com/go/getflash/>Get Flash</a>';
    document.write(alternateContent);  // insert non-flash content
  }
// -->
</script>
<noscript>
  	<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
			id="#attributes.SWFID#" width="100%" height="100%"
			codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
			<param name="movie" value="#attributes.SWFSource#" />
			<param name="quality" value="high" />
			<param name="bgcolor" value="##ffffff" />
			<param name="flashvars" value="#attributes.flashVars#" />
			<param name="allowScriptAccess" value="sameDomain" />
			<embed src="#attributes.SWFSource#" quality="high" bgcolor="##ffffff"
				width="100%" height="100%" name="#attributes.SWFID#" align="middle"
				play="true"
				loop="false"
				quality="high"
				flashvars="#attributes.flashVars#"
				allowScriptAccess="sameDomain"
				type="application/x-shockwave-flash"
				pluginspage="http://www.adobe.com/go/getflashplayer">
			</embed>
	</object>
</noscript>
<iframe name="_history" src="#attributes.flexAssetsPath#/history.htm" frameborder="0" scrolling="no" width="22" height="0"></iframe>

</cfoutput>
</cfif>

<cfif thistag.executionMode eq "End">
	<!--- null --->
</cfif>

<cfsetting enablecfoutputonly="no" />
<!--- end enable output only from cfoutput tags --->