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
<cfparam name="attributes.path" default="#application.path.webskin#/#attributes.typename#">
<cfparam name="attributes.r_qMethods" default="r_qMethods">

<cfdirectory action="LIST" filter="*.cfm" name="qTemplates" directory="#attributes.path#">

<!--- This is to overcome casesensitivity issues on mac/linux machines --->
<cfquery name="qTemplates" dbtype="query">
	SELECT *
	FROM qTemplates
	WHERE lower(qTemplates.name) LIKE '#lCase(attributes.prefix)#%'
</cfquery>

<cfset qMethods = queryNew("methodname, displayname")>

<cfloop query="qTemplates">
<!--- TODO
must be able to do this more neatly with a regEX, especially if we 
want more than one bit of template metadata --->
	<cffile action="READ" file="#attributes.path#/#qTemplates.name#" variable="template">

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

<cfset setVariable("caller.#attributes.r_qMethods#", qOrderedMethods)>


