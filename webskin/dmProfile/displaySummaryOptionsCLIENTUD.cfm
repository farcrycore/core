<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Summary options (CLIENTUD) --->
<!--- @@description: Farcry UD specific options --->

<cfset stUser = createObject("component", application.stcoapi["farUser"].packagePath).getByUserID(listfirst(stObj.username,"_")) />

<cfoutput>
	<li>
		<small>
			<a href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#stUser.objectid#&typename=dmProfile&method=editOwnPassword" target="content" title="#application.rb.getResource('coapi.farUser.general.changepassword@label','Change password')#">#application.rb.getResource('coapi.farUser.general.changepassword@label','Change password')#</a>
		</small>
	</li>
</cfoutput>

<cfsetting enablecfoutputonly="false" />