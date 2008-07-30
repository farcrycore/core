<cfsetting enablecfoutputonly="true" /> 

<!--- @@displayname: Core standard display --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au)--->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<skin:view objectid="#stobj.objectid#" typename="#stobj.typename#" template="displayHeaderStandard" pageTitle="#stObj.title#" />
		
	<skin:breadcrumb separator=" / ">
	
	<cfoutput>
	<h1>#stObj.label#</h1>
	<cfif structKeyExists(stobj, "body")>
		#stObj.body#
	</cfif>
	</cfoutput>

<skin:view objectid="#stobj.objectid#" typename="#stobj.typename#" template="displayFooterStandard" />

<cfsetting enablecfoutputonly="false" /> 