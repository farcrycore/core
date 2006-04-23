
<cfsetting enablecfoutputonly="No">
<cfimport taglib="/fourq/tags/" prefix="q4">

<cfoutput>
	<link rel="stylesheet" type="text/css" href="#application.url.farcry#/css/admin.css">
</cfoutput>

<q4:contentobjectget typename="#application.packagepath#.types.#url.type#" objectid="#url.objectID#" r_stobject="stObj">

<!--- See if we can edit this object --->
<cfif structKeyExists(stObj,"versionID") AND structKeyExists(stObj,"status")>
	<cfinvoke component="#application.packagepath#.farcry.versioning" method="getVersioningRules" objectID="#url.objectID#" returnvariable="stRules">

	<cfinvoke component="#application.packagepath#.farcry.versioning" method="checkEdit" stRules="#stRules#" stObj="#stObj#">
</cfif>

<cfif structCount(stObj)>
	<q4:contentobject
		 typename="#application.packagepath#.types.#url.type#"
		 method="edit"
		 objectID="#url.objectID#"
	 >
<cfelse>
	<cfoutput><script>window.close();</script></cfoutput>
</cfif>	  
	  
<cfsetting enablecfoutputonly="No">