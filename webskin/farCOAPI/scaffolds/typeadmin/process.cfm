<cfif structkeyexists(form,"generateTypeAdmin") and form.generateTypeAdmin>
		
	<!--- Webtop insertion --->
	<cffile action="read" file="#application.path.core#/webskin/farCOAPI/scaffolds/typeadmin/webtop.txt" variable="content" />
	<cfset values = structnew() />
	<cfset values.sectionid = "customcontent" />
	<cfset values.sectionlabel = "Custom Content" />
	<cfset values.subsectionid = "customsubsection" />
	<cfset values.subsectionlabel = "Custom Content" />
	<cfset values.menuid = "#application.applicationname#SubSection" />
	<cfset values.menulabel = "Custom Content" />
	<cfset values.itemid = "#url.scaffoldtypename#list" />
	<cfset values.itemlabel = "#application.stCOAPI[url.scaffoldtypename].displayname#" />
	<cfset values.filename = "#url.scaffoldtypename#" />
	<cfset content = substitute(content,values) />
	<cffile action="write" file="#application.path.project#/customadmin/#url.scaffoldtypename#.xml" output="#content#" mode="664" />
	
	<!--- Create object admin --->
	<cffile action="read" file="#application.path.core#/webskin/farCOAPI/scaffolds/typeadmin/objectadmin.txt" variable="content" />
	<cfset values = structnew() />
	<cfset values.title = form.typeadminTitle />
	<cfset values.columnlist = form.typeadminColumns />
	<cfset values.sortablecolumns = "" />
	<cfset values.filterfields = "" />
	<cfset values.typename = url.scaffoldtypename />
	<cfset content = substitute(content,values) />
	<cfif not directoryexists("#application.path.project#/customadmin/customlists")>
		<cfdirectory action="create" directory="#application.path.project#/customadmin/customlists" />
	</cfif>
	<cffile action="write" file="#application.path.project#/customadmin/customlists/#url.scaffoldtypename#.cfm" output="#content#" mode="664" />
	
	<cfoutput>
		<p class="success">Type administration page created</p>
	</cfoutput>

</cfif>