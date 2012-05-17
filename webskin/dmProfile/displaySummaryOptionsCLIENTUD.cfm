<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Summary options (CLIENTUD) --->
<!--- @@description: Farcry UD specific options --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset stUser = createObject("component", application.stcoapi["farUser"].packagePath).getByUserID(listfirst(stObj.username,"_")) />

<cfoutput>
	<li>
		<small>
			<skin:buildLink objectid="#stUser.objectid#" view="editOwnPassword" target="content" title="#application.rb.getResource('coapi.farUser.general.changepassword@label','Change password')#">#application.rb.getResource('coapi.farUser.general.changepassword@label','Change password')#</skin:buildLink>
		</small>
	</li>
</cfoutput>

<cfsetting enablecfoutputonly="false" />