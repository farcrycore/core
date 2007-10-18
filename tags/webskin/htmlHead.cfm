<!--- start enable output only from cfoutput tags --->
<cfsetting enablecfoutputonly="yes" />

<!--- 
|| DESCRIPTION || 
$Description: htmlHead tag - This tag reproduces the functionality of cfhtmlhead however maintains functionality if used in a webskin and that webskin has been cached. $

|| DEVELOPER ||
$Developer: Matthew Bryant (mbryant@daemon.com.au) $

|| ATTRIBUTES ||
$in: text -- the content to be added to the head. (REQUIRED) $
$in: id -- an id for the content to be added to the head. If the key already exists, it is not added again. This ensures it is not added multiple times (NOT REQUIRED) $
--->

<cfif thistag.executionMode eq "Start">

	<!--- class : defines the class of the flashWrapper div --->
	<cfparam name="attributes.text" default="" />
	<cfparam name="attributes.id" default="#createUUID()#" />
	
	
	<!--- Make sure the request.inhead.stCustom exists --->
	<cfparam name="request.inhead" default="#structNew()#" />
	<cfparam name="request.inhead.stCustom" default="#structNew()#" />
	<cfparam name="request.inhead.aCustomIDs" default="#arrayNew(1)#" /><!--- This array allows us to keep track of the order in which the ids were generated --->
	
</cfif>

<cfif thistag.executionMode eq "End">

	
	<cfif len(attributes.text)>
		<cfset thisTag.generatedContent = attributes.text />
	</cfif>
	
	<cfif NOT structKeyExists(request.inhead.stCustom, attributes.id)>
		<cfset request.inHead.stCustom[attributes.id] = thisTag.generatedContent />
		<cfset arrayAppend(request.inHead.aCustomIDs, attributes.id) />
	</cfif>
	
	<cfset application.coapi.objectbroker.addHTMLHeadToWebskins(id="#attributes.id#", text="#thisTag.generatedContent#") />
	
	
	<cfset thisTag.generatedContent = "" />
	
</cfif>

<cfsetting enablecfoutputonly="no" />
<!--- end enable output only from cfoutput tags --->