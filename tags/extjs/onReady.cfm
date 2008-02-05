<cfsetting enablecfoutputonly="yes" />

<!--- 
|| DESCRIPTION || 
$Description: onREady tag - This tag reproduces the functionality of skin:htmlHead but aggregates all the generated contents and places them in the html head section of a page . $

|| DEVELOPER ||
$Developer: Matthew Bryant (mbryant@daemon.com.au) $

|| ATTRIBUTES ||
$in: text -- the content to be added to the head. $
$in: id -- an id for the content to be added to the head. If the key already exists, it is not added again. This ensures it is not added multiple times $
--->

<!--- IPORT LIBRARIES --->
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">



<cfif thistag.executionMode eq "Start">

	<cfparam name="attributes.id" default="#createUUID()#" />
	<cfparam name="request.mode.ajax" default="false" >
	
	<!--- Make sure the request.inhead.stCustom exists --->
	<cfparam name="request.inhead" default="#structNew()#" />
	<cfparam name="request.inhead.stOnReady" default="#structNew()#" />
	<cfparam name="request.inhead.aOnReadyIDs" default="#arrayNew(1)#" /><!--- This array allows us to keep track of the order in which the ids were generated --->
	
	<cfif request.mode.ajax>
		<cfoutput><script type="text/javascript"></cfoutput>
	<cfelse>
		<skin:htmlHead library="extjs" />
	</cfif>
</cfif>

<cfif thistag.executionMode eq "End">

	
	<cfif request.mode.ajax>
		<!--- Dont put into the head, just output directly --->
		<cfoutput></script></cfoutput>
	<cfelse>
		<cfif NOT structKeyExists(request.inhead.stOnReady, attributes.id)>
			<cfset request.inHead.stOnReady[attributes.id] = thisTag.generatedContent />
			<cfset arrayAppend(request.inHead.aOnReadyIDs, attributes.id) />
		</cfif>
		
		<cfset application.coapi.objectbroker.addhtmlHeadToWebskins(id="#attributes.id#", onReady="#thisTag.generatedContent#") />
	
		
		
		<cfset thisTag.generatedContent = "" />
	</cfif>

	
</cfif>

<cfsetting enablecfoutputonly="no" />