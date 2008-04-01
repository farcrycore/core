<cfsetting enablecfoutputonly="true" /> 

<!--- @@displayname: Core standard HTML display --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au)--->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<skin:view objectid="#stobj.objectid#" typename="#stobj.typename#" template="displayHeaderStandard" pageTitle="#stObj.title#" />
		
	<skin:breadcrumb separator=" / ">
	
	<cfoutput>
	<h1>#stObj.title#</h1>
	<div class="fc-richtext">#stObj.body#</div>
	</cfoutput>

<skin:view objectid="#stobj.objectid#" typename="#stobj.typename#" template="displayFooterStandard" />

<cfsetting enablecfoutputonly="false" /> 