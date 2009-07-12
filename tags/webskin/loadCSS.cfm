
<cfif thistag.executionMode eq "End">
	<!--- Do Nothing --->
</cfif>

<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.id" default=""><!--- The id of the library that has been registered with the application --->
	<cfparam name="attributes.path" default=""><!--- The url path to the css files--->
	<cfparam name="attributes.lFiles" default=""><!--- The files to include in that path --->
	
	<cfset stCSS = duplicate(attributes) />
	
	<!--- Generate our id based on the path and files passed in. --->
	<cfif not len(stCSS.id)>
		<cfset stCSS.id = hash("#stCSS.path##stCSS.lFiles#") />
	</cfif>
	
	<cfif structKeyExists(application.fc.stCSSLibraries, stCSS.id)>
		<cfif not len(stCSS.path)>
			<cfset stCSS.path = application.fc.stCSSLibraries[stCSS.id].path />
		</cfif>
		<cfif not len(stCSS.lFiles)>
			<cfset stCSS.lFiles = application.fc.stCSSLibraries[stCSS.id].lFiles />
		</cfif>
	</cfif>
	
	
	<cfparam name="request.inHead.aCSSLibraries" default="#arrayNew(1)#" />
	<cfparam name="request.inHead.stCSSLibraries" default="#structNew()#" />
	
	
	<cfif NOT structKeyExists(request.inhead.stCSSLibraries, stCSS.id)>
		<!--- Add the id to the array to make sure we keep track of the order in which these libraries need to appear. --->
		<cfset arrayAppend(request.inHead.aCSSLibraries, stCSS.id) />
		
		<!--- Add the css information to the struct so we will be able to load it all correctly into the header at the end of the request. --->
		<cfset request.inHead.stCSSLibraries[stCSS.id] = stCSS />
	</cfif>
	
	
	<!--- SAVE THIS INFORMATION INTO THE RELEVENT WEBSKINS FOR CACHING --->
	<!--- <cfset application.fc.lib.objectbroker.addCSSHeadToWebskins(stCSS="#stCSS#") />	 --->
	
	
</cfif>