<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Summary options (CLIENTUD) --->
<!--- @@description: FarCry UD specific options --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfoutput>
	<li><a href="#application.url.webtop#/?id=dashboard&typename=farUser&bodyView=editOwnPassword"><admin:resource key="coapi.farUser.general.changepassword">Change password</admin:resource></a></li>
</cfoutput>

<cfsetting enablecfoutputonly="false" />