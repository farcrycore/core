
<cfif thistag.executionMode eq "End">
	<!--- Do Nothing --->
</cfif>

<cfif thistag.executionMode eq "Start">
	
	<cfif NOT request.mode.ajax>
		<cfparam name="request.inHead.aJSLibraries" default="#arrayNew(1)#" />
		<cfparam name="request.inHead.stJSLibraries" default="#structNew()#" />
		
	
		<cfloop from="1" to="#arrayLen(request.inHead.aJSLibraries)#" index="i">
		
			
			<cfset stJS = duplicate(request.inHead.stJSLibraries[request.inHead.aJSLibraries[i]]) />
		
			
			<cfset idHash = hash("#stJS.path##stJS.lFiles#") />
			
			<cfset sCacheFileName = "" />
			
			<cfif structKeyExists(application.fc.stJSLibraries,idHash) AND NOT request.mode.flushcache>
				<cfif structKeyExists(application.fc.stJSLibraries[idHash],"sCacheFileName")>
					<cfif fileExists(expandPath('/farcry/projects/#application.applicationname#/www/cache/#application.fc.stJSLibraries[idHash].sCacheFileName#'))>
						<cfset sCacheFileName = application.fc.stJSLibraries[idHash].sCacheFileName />
					</cfif>
				</cfif>
			<cfelse>
				<cfset application.fapi.registerJS(id="#idHash#", path="#stJS.path#", lFiles="#stJS.lFiles#") />
			</cfif>
			
			<cfif not len(sCacheFileName)>			
					
				<cfset stJS.path = replaceNoCase(stJS.path,"\","/","all") /><!--- Change back slashes --->
				<cfif len(stJS.path) AND right(stJS.path,1) EQ "/">
					<cfset stJS.path = mid(stJS.path,1,len(stJS.path)-1) /><!--- Remove trailing slash --->
				</cfif>
				
				
				<cfset stJS.lFiles = replaceNoCase(stJS.lFiles,"\","/","all") /><!--- Change back slashes --->
		
				<cfset stJS.lFullFilePaths = "" />
				
				<cfloop list="#stJS.lFiles#" index="i">
					<cfif left(i,1) NEQ "/">
						<cfset i = "/#i#" /><!--- add slash --->
					</cfif>
					<cfset stJS.lFullFilePaths = listAppend(stJS.lFullFilePaths,"#stJS.path##i#") />
				</cfloop>
			
				<cfset sCacheFileName = application.fc.utils.combine(	files=stJS.lFullFilePaths,
																		prepend:stJS.prepend,
																		append:stJS.append) />
				
				<cfset application.fc.stJSLibraries[idHash].sCacheFileName = sCacheFileName />
			</cfif>
			
			<cfsavecontent variable="JS">
				<cfoutput>
				<!-- 
				PATH: #stJS.path#
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