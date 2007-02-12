<cfsetting enablecfoutputonly="Yes">
<!--- Change this to the name of your mapping if it's different --->
<cfset fqmapping = '/fourq'>

<!--- Change this to highlight different CVS style keywords --->
<cfset keyword = "review">


<!--- create service factory so we can find the path to the mapping --->
<cfobject action="CREATE" 
		type="JAVA"
		class="coldfusion.server.ServiceFactory"
		name="factory">

<!--- Get the mappings from the factory --->
<cfset mappings = factory.runtimeservice.getMappings()>

<!--- check if the mapping exists --->
<cfif structKeyExists(mappings,fqmapping)>
	<cfset fsroot = mappings[fqmapping]>
<cfelse>
	<cfoutput>The fourq autodoc tool was unable to locate the mapping for your 'fourq' installation. Make sure that you have a ColdFusion mapping that points to the directory containing fourq.cfc. If this mapping is not called fourq you will need to edit <strong>#getCurrentTemplatePath()#</strong> and set the value of fqmappings to the same as the name of your mapping.</cfoutput>
	<cfabort>
</cfif>