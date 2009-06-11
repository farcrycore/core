<cfsetting enablecfoutputonly="yes" />

<!--- 
|| DESCRIPTION || 
$Description: htmlHead tag - This tag reproduces the functionality of cfhtmlHead however maintains functionality if used in a webskin and that webskin has been cached. $

|| DEVELOPER ||
$Developer: Matthew Bryant (mbryant@daemon.com.au) $

|| ATTRIBUTES ||
$in: text -- the content to be added to the head. $
$in: id -- an id for the content to be added to the head. If the key already exists, it is not added again. This ensures it is not added multiple times $
$in: library -- used in add predefined libraries from core. This can optionally be a list of libraries. $
$in: libraryState -- used to turn predefined libraries on or off. Default turns the library on. $
--->

<cfif thistag.executionMode eq "Start">

	<cfparam name="attributes.text" default="" />
	<cfparam name="attributes.id" default="#application.fc.utils.createJavaUUID()#" />
	<cfparam name="attributes.library" default="" />
	<cfparam name="attributes.libraryState" default="true" />
	<cfparam name="attributes.position" default="last" /><!--- first or last --->
	
	
	<!--- Make sure the request.inhead.stCustom exists --->
	<cfparam name="request.inhead" default="#structNew()#" />
	<cfparam name="request.inhead.stCustom" default="#structNew()#" />
	<cfparam name="request.inhead.aCustomIDs" default="#arrayNew(1)#" /><!--- This array allows us to keep track of the order in which the ids were generated --->
	
	
</cfif>

<cfif thistag.executionMode eq "End">
	
	<cfif request.mode.ajax>
		<cfif NOT structKeyExists(request.inhead.stCustom, attributes.id)>
			<!--- Dont put into the head, just output directly --->
		
			<cfset request.inHead.stCustom[attributes.id] = thisTag.generatedContent />
		<cfelse>
			<cfset thisTag.generatedContent = "" />
		</cfif>
	<cfelse>
		
		<cfif listLen(attributes.library)>
			<!--- Adding predefined library --->
			<cfloop list="#attributes.library#" index="i">
				<cfset request.inHead[i] = attributes.libraryState />
				<cfset application.fc.lib.objectbroker.addhtmlHeadToWebskins(library="#i#", libraryState="#attributes.libraryState#") />
			</cfloop>
		<cfelse>
			<!--- Adding developers own html to header --->	
			<cfif not len(attributes.text)>
				<cfset attributes.text = thisTag.generatedContent />
			</cfif>
			
			<cfif NOT structKeyExists(request.inhead.stCustom, attributes.id)>
				<cfset request.inHead.stCustom[attributes.id] = attributes.text />
				<cfif attributes.position EQ "first">
					<cfset arrayPrepend(request.inHead.aCustomIDs, attributes.id) />
				<cfelse>
					<cfset arrayAppend(request.inHead.aCustomIDs, attributes.id) />
				</cfif>
			</cfif>
			
			<cfset application.fc.lib.objectbroker.addhtmlHeadToWebskins(id="#attributes.id#", text="#attributes.text#") />
			
		</cfif>	
		
		<cfset thisTag.generatedContent = "" />
	</cfif>
	
	
	
</cfif>

<cfsetting enablecfoutputonly="no" />