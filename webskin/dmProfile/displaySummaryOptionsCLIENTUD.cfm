<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Summary options (CLIENTUD) --->
<!--- @@description: Farcry UD specific options --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset stUser = createObject("component", application.stcoapi["farUser"].packagePath).getByUserID(listdeleteat(stObj.username,listlen(stObj.username,"_"),"_")) />

<cfoutput>
	<li>
		<small>
			<skin:buildLink objectid="#stUser.objectid#" view="editOwnPassword" target="content" title="Change password" rbkey="coapi.farUser.general.changepassword">Change password</skin:buildLink>
		</small>
	</li>
</cfoutput>

<cfsetting enablecfoutputonly="false" />