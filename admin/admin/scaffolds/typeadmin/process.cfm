<cfif structkeyexists(form,"generateTypeAdmin") and form.generateTypeAdmin>
		
	<!--- Webtop insertion --->
	<cffile action="read" file="#application.path.core#/admin/admin/scaffolds/typeadmin/webtop.txt" variable="content" />
	<cfset values = structnew() />
	<cfset values.sectionid = "content" />
	<cfset values.subsectionid = "farcrycmsSubSection" />
	<cfset values.menuid = "#application.applicationname#SubSection" />
	<cfset values.menulabel = "Custom Content" />
	<cfset values.itemid = "#url.typename#list" />
	<cfset values.itemlabel = "#application.stCOAPI[url.typename].displayname#" />
	<cfset values.filename = "#url.typename#" />
	<cfset content = substitute(content,values) />
	<cffile action="write" file="#application.path.project#/customadmin/#url.typename#.xml" output="#content#" />
	
	<!--- Create object admin --->
	<cffile action="read" file="#application.path.core#/admin/admin/scaffolds/typeadmin/objectadmin.txt" variable="content" />
	<cfset values = structnew() />
	<cfset values.title = form.typeadminTitle />
	<cfset values.columnlist = form.typeadminColumns />
	<cfset values.sortablecolumns = "" />
	<cfset values.filterfields = "" />
	<cfset values.typename = url.typename />
	<cfset content = substitute(content,values) />
	<cfif not directoryexists("#application.path.project#/customadmin/customlists")>
		<cfdirectory action="create" directory="#application.path.project#/customadmin/customlists" />
	</cfif>
	<cffile action="write" file="#application.path.project#/customadmin/customlists/#url.typename#.cfm" output="#content#" />
	
	<cfoutput>
		<p class="success">Type administration page created</p>
	</cfoutput>

</cfif>