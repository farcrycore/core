<cfparam name="url.icon" default="" />
<cfparam name="url.size" default="48" />
<cfparam name="url.default" default="farcrycore" />

<!--- @@displayname: Icon streamer --->
<!--- @@description: This will go and get the physical path to the icon and stream it to the browser --->

<cfset iconPath = application.fapi.getIconURL(icon=url.icon, size=url.size, default=url.default, bPhysicalPath="true") />

<cfcontent file="#iconPath#" />
