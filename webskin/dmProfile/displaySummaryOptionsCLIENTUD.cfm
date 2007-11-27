<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Summary options (CLIENTUD) --->
<!--- @@description: Farcry UD specific options --->

<cfset stUser = createObject("component", application.stcoapi["farUser"].packagePath).getByUserID(listfirst(stObj.username,"_")) />

<cfoutput>
	<li>
		<small>
			<a href="#application.url.farcry#/facade/view.cfm?objectid=#stUser.objectid#&method=displayChangePassword" onClick="window.open('#application.url.farcry#/facade/view.cfm?objectid=#stUser.objectid#&method=displayChangePassword','update_password','width=459,height=250,left=200,top=100');return false;" title="#application.rb.getResource('coapi.farUser.general.changepassword@label','Change password')#">#application.rb.getResource('coapi.farUser.general.changepassword@label','Change password')#</a>
		</small>
	</li>
</cfoutput>

<cfsetting enablecfoutputonly="false" />