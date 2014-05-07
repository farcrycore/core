<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Summary options (CLIENTUD) --->
<!--- @@description: FarCry UD specific options --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfset stUser = createObject("component", application.stcoapi["farUser"].packagePath).getByUserID(listdeleteat(stObj.username,listlen(stObj.username,"_"),"_")) />

<cfoutput>
	<li><a href="#application.url.webtop#?id=dashboard&typename=farUser&objectid=#stUser.objectid#&bodyView=editOwnPassword"><admin:resource key="coapi.farUser.general.changepassword">Change password</admin:resource></a></li>
</cfoutput>

<cfsetting enablecfoutputonly="false" />