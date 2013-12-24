<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Dashboard Logo --->
<!--- @@viewstack: fragment --->
<!--- @@viewbinding: type --->
<!--- @@cardClass: fc-dashboard-card-medium --->
<!--- @@cardHeight: 200px --->
<!--- @@seq: 5 --->

<cfoutput>

<div style="margin:-10px;" data-intro="#application.sysInfo.farcryVersionTagLine#" data-position="bottom">
	<img src="#application.url.webtop#/images/farcry-dashboard-logo.jpg" style="opacity:0.85;" />
</div>

</cfoutput>


<cfsetting enablecfoutputonly="false">