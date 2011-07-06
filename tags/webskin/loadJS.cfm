<cfsetting enablecfoutputonly="yes" />


<cfif not thisTag.HasEndTag>
	<cfabort showerror="skin:loadJS requires an end tag." />
</cfif>

<cfif thistag.executionMode eq "Start">
	<!--- Do Nothing --->
</cfif>

<cfif thistag.executionMode eq "End">
	<cfparam name="attributes.id" default=""><!--- The id of the library that has been registered with the application --->
	<cfparam name="attributes.lCombineIDs" default=""><!--- A list of registered JS ids, to be included in this library --->
	<cfparam name="attributes.baseHREF" default=""><!--- The url baseHREF to the JS files--->
	<cfparam name="attributes.hostname" default=""><!--- The hostname from which to load the JS files--->
	<cfparam name="attributes.lFiles" default=""><!--- The files to include in that baseHREF --->
	<cfparam name="attributes.condition" default=""><!--- the condition to wrap around the style tag --->
	<cfparam name="attributes.prepend" default=""><!--- any JS to prepend to the beginning of the script block --->
	<cfparam name="attributes.append" default=""><!--- any JS to append to the end of the script block --->
	<cfparam name="attributes.bCombine" default=""><!--- Should the files be combined into a single cached js file. Passing true/false will override how it was registered. --->
	
	<cfif len(trim(thisTag.generatedContent))>
		<cfset attributes.append = "#attributes.append##thisTag.generatedContent#" />
		<cfset thisTag.generatedContent = "" />
	</cfif>
	
	<cfset stJS = duplicate(attributes) />
	
	<!--- Generate our id based on the baseHREF and files passed in. --->
	<cfif not len(stJS.id)>
		<cfset stJS.id = hash("#stJS.baseHREF##stJS.lFiles##stJS.lCombineIDs#") />
	</cfif>
	
	
	<cfparam name="request.inHead.aJSLibraries" default="#arrayNew(1)#" />
	<cfparam name="request.inHead.stJSLibraries" default="#structNew()#" />
	
	<cfif NOT structKeyExists(request.inhead.stJSLibraries, stJS.id)>
		
		<!--- If this id is registered, use those values for defaults --->
		<cfif structKeyExists(application.fc.stJSLibraries, stJS.id)>
			<cfif not len(stJS.lCombineIDs)>
				<cfset stJS.lCombineIDs = application.fc.stJSLibraries[stJS.id].lCombineIDs />
			</cfif>
			<cfif not len(stJS.baseHREF)>
				<cfset stJS.baseHREF = application.fc.stJSLibraries[stJS.id].baseHREF />
			</cfif>
			<cfif not len(stJS.hostname)>
				<cfset stJS.hostname = application.fc.stJSLibraries[stJS.id].hostname />
			</cfif>
			<cfif not len(stJS.lFiles)>
				<cfset stJS.lFiles = application.fc.stJSLibraries[stJS.id].lFiles />
			</cfif>
			<cfif not len(stJS.condition)>
				<cfset stJS.condition = application.fc.stJSLibraries[stJS.id].condition />
			</cfif>
			<cfif not len(stJS.prepend)>
				<cfset stJS.prepend = application.fc.stJSLibraries[stJS.id].prepend />
			</cfif>
			<cfif not len(stJS.append)>
				<cfset stJS.append = application.fc.stJSLibraries[stJS.id].append />
			</cfif>
			<cfif not isBoolean(stJS.bCombine)>
				<cfset stJS.bCombine = application.fc.stJSLibraries[stJS.id].bCombine />
			</cfif>
		<cfelse>
			<cfif not isBoolean(stJS.bCombine)>
				<cfset stJS.bCombine = true />
			</cfif>
		</cfif>
		
		<!--- Normalise files --->
		<cfif len(stJS.lFiles)>
			<cfset stJS.lFullFilebaseHREFs = application.fc.utils.normaliseFileList(stJS.baseHREF,stJS.lFiles) />
		<cfelse>
			<cfset stJS.lFullFilebaseHREFs = "" />
		</cfif>
		
		<!--- Identify external files --->
		<cfif refindnocase("(^|,)http[s]?\://",stJS.lFullFilebaseHREFs)>
			<cfset stJS.bCombine = false />
			<cfset stJS.bExternal = true />
		<cfelse>
			<cfset stJS.bExternal = false />
		</cfif>
		
		<!--- Add the id to the array to make sure we keep track of the order in which these libraries need to appear. --->
		<cfset arrayAppend(request.inHead.aJSLibraries, stJS.id) />
		
		<!--- Add the JS information to the struct so we will be able to load it all correctly into the header at the end of the request. --->
		<cfset request.inHead.stJSLibraries[stJS.id] = stJS />
	
	<cfelse>
	
		<cfset stJS = request.inHead.stJSLibraries[stJS.id] />
	
	</cfif>
	
	
	<!--- SAVE THIS INFORMATION INTO THE RELEVENT WEBSKINS FOR CACHING --->
	<cfset application.fc.lib.objectbroker.addJSHeadToWebskins(stJS="#stJS#") />
	
	
</cfif>

<cfsetting enablecfoutputonly="no" />