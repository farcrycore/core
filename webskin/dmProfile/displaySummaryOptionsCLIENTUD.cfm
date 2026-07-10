<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Summary options (CLIENTUD) --->
<!--- @@description: FarCry UD specific options --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfoutput>
	<li><a href="#application.url.webtop#/?id=dashboard&typename=farUser&bodyView=editOwnPassword"><admin:resource key="coapi.farUser.general.changepassword">Change password</admin:resource></a></li>
	<cfif application.fapi.getConfig("security","mfaMode","off") neq "off">
		<li><a href="#application.url.webtop#/?id=dashboard&typename=farUser&bodyView=editOwnMFA"><admin:resource key="security.mfa.manage.title">Multi-factor authentication</admin:resource></a></li>
	</cfif>
</cfoutput>

<cfsetting enablecfoutputonly="false" />