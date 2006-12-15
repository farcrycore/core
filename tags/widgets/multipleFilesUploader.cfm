<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| DESCRIPTION || 
$Description: embeds the multiple flex file uploader a almost 100% copy of the flexbuilder 2 generated code$

|| DEVELOPER ||
$Developer: Patrick Tai (pat@daemon.com.au)$

Typicla Integration example code
**********************************************

<cfimport taglib="/farcry/farcry_core/tags/widgets" prefix="skin">
<skin:multipleFilesUploader ObjectID="sdfsdf" serverUrl="/upload.cfm" />

 --->
<cfsetting enablecfoutputonly="yes" />

	<cfif thistag.executionMode eq "Start">
		<cfparam name="flashVars" default="">
		<cfif not isdefined("attributes.ObjectID") or not isdefined("attributes.serverUrl") >
			<cfoutput>missing parameters</cfoutput>
			<cfexit method="exittag" />
		</cfif>
	

	<cfset flashVars=  "objectID=#attributes.ObjectID#&serverUrl=#attributes.serverUrl#">
	
	<cfif isDefined("attributes.stFlashVars")>
		<cfloop collection="#attributes.stFlashVars#" item="fvar">
			<cfset flashVars= flashVars & "&" & fvar & "=" & attributes.stFlashVars[fvar]>
		</cfloop>		
	</cfif>
	<cfoutput>
<script language="JavaScript" type="text/javascript" src="/farcry/js/history.js"></script>

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
		"id", "FileUploader",
		"quality", "high",
		"bgcolor", "##869ca7",
		"name", "FileUploader",
		"allowScriptAccess","sameDomain",
		"type", "application/x-shockwave-flash",
		"pluginspage", "http://www.adobe.com/go/getflashplayer"
	);
} else if (hasRequestedVersion) {
	// if we've detected an acceptable version
	// embed the Flash Content SWF when all tests are passed
	AC_FL_RunContent(
			"src", "/farcry/swf/FileUploader",
			"width", "100%",
			"height", "100%",
			"align", "middle",
			"id", "FileUploader",
			"quality", "high",
			"bgcolor", "##869ca7",
			"name", "FileUploader",
			"FlashVars",'#flashVars#&historyUrl=history.htm%3F&lconid=' + lc_id + '',
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
			id="FileUploader" width="100%" height="100%"
			codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
			<param name="movie" value="/facry/swf/FileUploader.swf" />
			<param name="quality" value="high" />
			<param name="bgcolor" value="##869ca7" />
			<param name="allowScriptAccess" value="sameDomain" />
			<embed src="/facry/swf/FileUploader.swf" quality="high" bgcolor="##869ca7"
				width="100%" height="100%" name="FileUploader" align="middle"
				play="true"
				loop="false"
				quality="high"
				allowScriptAccess="sameDomain"
				type="application/x-shockwave-flash"
				pluginspage="http://www.adobe.com/go/getflashplayer">
			</embed>
	</object>
</noscript>

	<iframe name="_history" src="/farcry/flex/history.htm" frameborder="0" scrolling="no" width="22" height="0"></iframe>
	
	</cfoutput>

<cfsaveContent variable="shoot2Head">
	<cfoutput><script src="/farcry/js/AC_OETags.js" language="javascript"></script>
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
	<style>
		body { margin: 0px; overflow:hidden }
</style>
	</cfoutput>
</cfsaveContent>

<cfhtmlhead text="#shoot2Head#">
</cfif>

<cfif thistag.executionMode eq "End">
	<!--- null --->
</cfif>

<cfsetting enablecfoutputonly="no" />
<!--- end enable output only from cfoutput tags --->