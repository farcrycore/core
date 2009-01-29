<cfsetting enablecfoutputonly="true" /> 

<!--- @@displayname: Core standard cron display --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au)--->

	
<cfloop list="#stObj.parameters#" index="thisparam" delimiters="&">
	<cfset url[listfirst(thisparam,"=")] = listlast(thisparam,"=") />
</cfloop>


<cftry>
	<!--- include scheduled task code and pass in parameters --->
	<cfinclude template="#stObj.template#">
	<cfcatch type="any"><cfdump var="#cfcatch#"></cfcatch>
</cftry>

<cfoutput>Done</cfoutput>

<cfsetting enablecfoutputonly="false" /> 