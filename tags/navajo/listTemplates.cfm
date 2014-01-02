<!--- 
listTemplates
 - list templates from webskin

attributes
-> typename
-> prefix
-> path
 --->
<!--- 
TODO
Need to work out a way of generating a suitable displayname.  Perhaps 
this could be a special comment in the template itself picked up
by a regular expression match here???
 --->

<cfprocessingDirective pageencoding="utf-8">

<cfparam name="attributes.typename">
<cfparam name="attributes.prefix" default="display">
<cfparam name="attributes.path" default="">
<cfparam name="attributes.r_qMethods" default="r_qMethods">

<cfset qTemplates = queryNew("blah") />


<!--- if we send in a path then only get templates from that path --->
<cfif len(attributes.path)>

	<cfdirectory action="LIST" filter="*.cfm" name="qTemplates" directory="#attributes.path#">
	
	<cfset qMethods = queryNew("methodname, displayname")>
	
	<!--- This is to overcome casesensitivity issues on mac/linux machines --->
<cfquery name="qTemplates" dbtype="query">
	SELECT * FROM qTemplates
	WHERE lower(qTemplates.name) LIKE '#lCase(attributes.prefix)#%'
</cfquery>
	
	<cfloop query="qTemplates">
	<!--- TODO
	must be able to do this more neatly with a regEX, especially if we 
	want more than one bit of template metadata --->
		<cffile action="READ" file="#qTemplates.directory#/#qTemplates.name#" variable="template">
	
		<cfset pos = findNoCase('@@displayname:', template)>
		<cfif pos eq 0>
			<cfset displayname = listfirst(qTemplates.name, ".")>
		<cfelse>
			<cfset pos = pos + 14>
			<cfset count = findNoCase('--->', template, pos)-pos>
			<cfset displayname = listLast(mid(template,  pos, count), ":")>
		</cfif>
	
		<cfset queryAddRow(qMethods, 1)>
		<cfset querySetCell(qMethods, "methodname", listfirst(qTemplates.name, "."))>
		<cfset querySetCell(qMethods, "displayname", displayname)>
	</cfloop>
	
	<!--- 
	<cfdump var="#qTemplates#">
	<cfdump var="#qMethods#">
	 --->
	<!--- Reorder List --->
	<cfquery name="qOrderedMethods" dbtype="query">
	SELECT *
	FROM qMethods
	ORDER BY DisplayName
	</cfquery>

	<cfset caller[attributes.r_qMethods] = qOrderedMethods>
<!---
OTHERWISE WE NEED TO LOOP THROUGH ALL THE LIBRARIES AND GET ALL RELEVENT TEMPLATES
 --->
<cfelse>
	
		
	<cfif structKeyExists(application.stcoapi, attributes.typename)>		
			
		<cfset qTemplates = createObject("component", application.stcoapi[attributes.typename].packagepath).getWebskins(typename="#attributes.typename#", prefix="#attributes.prefix#") />
		<cfset caller[attributes.r_qMethods] = qTemplates>
	<cfelse>
		<cfset caller[attributes.r_qMethods] = queryNew("name,directory,size,type,datelastmodified,attributes,mode,displayname,methodname") />
			
	</cfif>

<!--- 	<cfdirectory action="LIST" filter="*.cfm" name="qTemplates" directory="#application.path.webskin#/#attributes.typename#">
	
	<cfset stPluginTemplates = structNew() />
	
	<cfif structKeyExists(application, "plugins") and listLen(application.plugins)>
	
		<cfloop list="#application.plugins#" index="plugin">
			
			<cfif directoryExists("#application.path.plugins#/#plugin#/webskin/#attributes.typename#")>
				<cfdirectory directory="#application.path.plugins#/#plugin#/webskin/#attributes.typename#" name="stPluginTemplates.#plugin#.qTemplates" filter="*.cfm" sort="name">
			
			</cfif>
		</cfloop>
	</cfif> --->
	
	
</cfif>





