<cfsetting enablecfoutputonly="true">
<!--- 
|| DESCRIPTION || 
$Description: Creates a link to a movie file. $

|| DEVELOPER ||
$Developer: Matthew Bryant (mbryant@daemon.com.au) $
--->
<!--- @@displayname: Render Flash Object --->
<!--- @@author: Matthew Bryant --->

<!--- Import Tag Libraries --->
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!--- Add the swfObject Javascript Library to the header --->
<skin:htmlHead library="swfObject" />


<cfif len(stobj.flashmovie)>
	<cfset swfpath = application.url.fileroot & stobj.flashMovie />
<cfelse>
	<cfset swfpath = stobj.flashURL />
</cfif>
	
	<cfoutput>	
	<h1>#stobj.title#</h1>
<!--- 	<div id="#stobj.objectid#_flashMovieContainer"><img src="#application.url.farcry#/images/shim.gif" style="border: 1px dotted ##cc0000;background: ##ffffcc url('#application.url.webroot#/wsimages/flash.gif') center no-repeat;width:100px;height:#stobj.flashHeight#px;" /></div>

	<script type="text/javascript">
		
		if(typeof SWFObject != "undefined") {
			var so = new SWFObject("#swfpath#", "#stobj.objectid#_flashMovie", "100", "#stobj.flashHeight#", "#stobj.FlashVersion#", "#stobj.flashBgcolor#");
			so.addParam("quality", "high");
			so.addParam("wmode", "transparent");
			so.addParam("flashvars", value="data=data.xml");
			so.write("#stobj.objectid#_flashMovieContainer");
		}
	</script> --->
	</cfoutput>	
	

<cfsetting enablecfoutputonly="false">