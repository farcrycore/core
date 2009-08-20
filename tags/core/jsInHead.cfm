
<cfif thistag.executionMode eq "End">
	<!--- Do Nothing --->
</cfif>

<cfif thistag.executionMode eq "Start">
	
	<cfif NOT request.mode.ajax>
		<cfparam name="request.inHead.aJSLibraries" default="#arrayNew(1)#" />
		<cfparam name="request.inHead.stJSLibraries" default="#structNew()#" />
		
	
		<cfloop from="1" to="#arrayLen(request.inHead.aJSLibraries)#" index="i">
		
			
			<cfset stJS = duplicate(request.inHead.stJSLibraries[request.inHead.aJSLibraries[i]]) />

			<cfset idHash = hash("#stJS.baseHREF##stJS.lFiles##stJS.prepend##stJS.append#") />
			
			<cfset sCacheFileName = "" />
			
			<cfif structKeyExists(application.fc.stJSLibraries,idHash) AND NOT request.mode.flushcache>
				<cfif structKeyExists(application.fc.stJSLibraries[idHash],"sCacheFileName")>
					<cfif fileExists(application.path.project & '/www/cache/#application.fc.stJSLibraries[idHash].sCacheFileName#')>
						<cfset sCacheFileName = application.fc.stJSLibraries[idHash].sCacheFileName />
					</cfif>
				</cfif>
			<cfelse>
				<cfset application.fapi.registerJS(id="#idHash#", baseHREF="#stJS.baseHREF#", lFiles="#stJS.lFiles#") />
			</cfif>
			
			<cfif not len(sCacheFileName)>			
					
				<cfset stJS.baseHREF = replaceNoCase(stJS.baseHREF,"\","/","all") /><!--- Change back slashes --->
				<cfif len(stJS.baseHREF) AND right(stJS.baseHREF,1) EQ "/">
					<cfset stJS.baseHREF = mid(stJS.baseHREF,1,len(stJS.baseHREF)-1) /><!--- Remove trailing slash --->
				</cfif>
				
				
				<cfset stJS.lFiles = replaceNoCase(stJS.lFiles,"\","/","all") /><!--- Change back slashes --->
		
				<cfset stJS.lFullFilebaseHREFs = "" />
				
				<cfloop list="#stJS.lFiles#" index="i">
					<cfif left(i,1) NEQ "/">
						<cfset i = "/#i#" /><!--- add slash --->
					</cfif>
					<cfset stJS.lFullFilebaseHREFs = listAppend(stJS.lFullFilebaseHREFs,"#stJS.baseHREF##i#") />
				</cfloop>
			
				<cfset sCacheFileName = application.fc.utils.combine(	files=stJS.lFullFilebaseHREFs,
																		type="js",
																		prepend:stJS.prepend,
																		append:stJS.append) />
				
				<cfset application.fc.stJSLibraries[idHash].sCacheFileName = sCacheFileName />
			</cfif>
			
			<cfsavecontent variable="JS">
				<cfoutput>
				<!-- 
				baseHREF: #stJS.baseHREF#
				FILES: #stJS.lFiles#
				 -->
				</cfoutput>
				
				<cfif len(stJS.condition)>
					<cfoutput><!--[#stJS.condition#]>
					<script src="#application.url.webroot#/cache/#sCacheFileName#" type="text/javascript"></script>
					<![endif]-->
					</cfoutput>
				<cfelse>
					<cfoutput><script src="#application.url.webroot#/cache/#sCacheFileName#" type="text/javascript"></script>
					</cfoutput>
				</cfif>			
			</cfsavecontent>
			<cfhtmlhead text="#JS#">
	
		</cfloop>
	</cfif>
</cfif>