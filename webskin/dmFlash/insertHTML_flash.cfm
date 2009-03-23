<cfsetting enablecfoutputonly="true">
<!--- 
|| DESCRIPTION || 
$Description: Creates a link to a movie file. $

|| DEVELOPER ||
$Developer: Matthew Bryant (mbryant@daemon.com.au) $
--->
<!--- @@displayname: Render Flash Object --->
<!--- @@author: Matthew Bryant --->

<!--- Make sure the swfobject library is added --->
<cfoutput><script type="text/javascript" src="#application.url.webtop#/js/swfobject.js"></script>
</cfoutput>

<cfif len(stobj.flashmovie)>
	<cfset swfpath = application.fapi.getFileWebRoot() & stobj.flashMovie />
<cfelse>
	<cfset swfpath = stobj.flashURL />
</cfif>
	
	<cfoutput>	
	<div id="#stobj.objectid#_flashMovieContainer"><img src="#application.url.farcry#/images/shim.gif" style="border: 1px dotted ##cc0000;background: ##ffffcc url('#application.url.webroot#/wsimages/flash.gif') center no-repeat;width:#stobj.flashWidth#px;height:#stobj.flashHeight#px;" /></div>

	<script type="text/javascript" defer="true">
		
		if(typeof SWFObject != "undefined") {
			var so = new SWFObject("#swfpath#", "#stobj.objectid#_flashMovie", "#stobj.flashWidth#", "#stobj.flashHeight#", "#stobj.FlashVersion#", "#stobj.flashBgcolor#");
			so.addParam("quality", "high");
			so.addParam("wmode", "transparent");
			so.addParam("flashvars", value="data=data.xml");
			so.write("#stobj.objectid#_flashMovieContainer");
		}
	</script>
	</cfoutput>	
	

<cfsetting enablecfoutputonly="false">