<cfif structkeyexists(form,"generateWebskinPage") and form.generateWebskinPage>
		
	<cfif not directoryexists("#application.path.project#/webskin/#url.typename#")>
		<cfdirectory action="create" directory="#application.path.project#/webskin/#url.typename#" />
	</cfif>
	
	<!--- Generate webskin --->
	<cffile action="read" file="#application.path.core#/webtop/admin/scaffolds/webskins/displayPageStandard.txt" variable="content" />
	<cfset values = structnew() />
	<cfset values.projectname = application.ApplicationName />
	<cfset values.typename = url.typename />
	<cfset content = substitute(content,values) />
	<cffile action="write" file="#application.path.project#/webskin/#url.typename#/displayPageStandard.cfm" output="#content#" />
	
	<cfoutput>
		<p class="success">Standard page created</p>
	</cfoutput>

</cfif>

<cfif structkeyexists(form,"generateWebskinTeaser") and form.generateWebskinTeaser>
		
	<cfif not directoryexists("#application.path.project#/webskin/#url.typename#")>
		<cfdirectory action="create" directory="#application.path.project#/webskin/#url.typename#" />
	</cfif>
	
	<!--- Generate webskin --->
	<cffile action="read" file="#application.path.core#/webtop/admin/scaffolds/webskins/displayTeaserStandard.txt" variable="content" />
	<cfset values = structnew() />
	<cfset values.projectname = application.ApplicationName />
	<cfset values.typename = url.typename />
	<cfset content = substitute(content,values) />
	<cffile action="write" file="#application.path.project#/webskin/#url.typename#/displayTeaserStandard.cfm" output="#content#" />
	
	<cfoutput>
		<p class="success">Standard teaser created</p>
	</cfoutput>

</cfif>