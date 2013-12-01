<cfif structkeyexists(form,"generateWebskinPage") and form.generateWebskinPage>
		
	<cfif not directoryexists("#application.path.project#/webskin/#url.scaffoldtypename#")>
		<cfdirectory action="create" directory="#application.path.project#/webskin/#url.scaffoldtypename#" />
	</cfif>
	
	<!--- Generate webskin --->
	<cffile action="read" file="#application.path.core#/webskin/farCOAPI/scaffolds/webskins/displayPageStandard.txt" variable="content" />
	<cfset values = structnew() />
	<cfset values.projectname = application.ApplicationName />
	<cfset values.typename = url.scaffoldtypename />
	<cfset content = substitute(content,values) />
	<cffile action="write" file="#application.path.project#/webskin/#url.scaffoldtypename#/displayPageStandard.cfm" output="#content#" mode="664" />
	
	<cfoutput>
		<p class="success">Standard page created</p>
	</cfoutput>

</cfif>

<cfif structkeyexists(form,"generateWebskinTeaser") and form.generateWebskinTeaser>
		
	<cfif not directoryexists("#application.path.project#/webskin/#url.scaffoldtypename#")>
		<cfdirectory action="create" directory="#application.path.project#/webskin/#url.scaffoldtypename#" />
	</cfif>
	
	<!--- Generate webskin --->
	<cffile action="read" file="#application.path.core#/webskin/farCOAPI/scaffolds/webskins/displayTeaserStandard.txt" variable="content" />
	<cfset values = structnew() />
	<cfset values.projectname = application.ApplicationName />
	<cfset values.typename = url.scaffoldtypename />
	<cfset content = substitute(content,values) />
	<cffile action="write" file="#application.path.project#/webskin/#url.scaffoldtypename#/displayTeaserStandard.cfm" output="#content#" mode="664" />
	
	<cfoutput>
		<p class="success">Standard teaser created</p>
	</cfoutput>

</cfif>