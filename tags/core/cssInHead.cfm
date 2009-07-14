
<cfif thistag.executionMode eq "End">
	<!--- Do Nothing --->
</cfif>

<cfif thistag.executionMode eq "Start">
	
	<cfif NOT request.mode.ajax>
		<cfparam name="request.inHead.aCSSLibraries" default="#arrayNew(1)#" />
		<cfparam name="request.inHead.stCSSLibraries" default="#structNew()#" />
		
	
		<cfloop from="1" to="#arrayLen(request.inHead.aCSSLibraries)#" index="i">
		
			
			<cfset stCSS = duplicate(request.inHead.stCSSLibraries[request.inHead.aCSSLibraries[i]]) />
		
			
			<cfset idHash = hash("#stCSS.path##stCSS.lFiles#") />
			
			<cfset sCacheFileName = "" />
			
			<cfif structKeyExists(application.fc.stCSSLibraries,idHash)>
				<cfif structKeyExists(application.fc.stCSSLibraries[idHash],"sCacheFileName")>
					<cfif fileExists(expandPath('/farcry/projects/#application.applicationname#/www/cache/#application.fc.stCSSLibraries[idHash].sCacheFileName#'))>
						<cfset sCacheFileName = application.fc.stCSSLibraries[idHash].sCacheFileName />
					</cfif>
				</cfif>
			<cfelse>
				<cfset application.fapi.registerCSS(id="#idHash#", path="#stCSS.path#", lFiles="#stCSS.lFiles#") />
			</cfif>
			
			<cfif not len(sCacheFileName)>			
					
				<cfset stCSS.path = replaceNoCase(stCSS.path,"\","/","all") /><!--- Change back slashes --->
				<cfif len(stCSS.path) AND right(stCSS.path,1) EQ "/">
					<cfset stCSS.path = mid(stCSS.path,1,len(stCSS.path)-1) /><!--- Remove trailing slash --->
				</cfif>
				
				
				<cfset stCSS.lFiles = replaceNoCase(stCSS.lFiles,"\","/","all") /><!--- Change back slashes --->
		
				<cfset stCSS.lFullFilePaths = "" />
				
				<cfloop list="#stCSS.lFiles#" index="i">
					<cfif left(i,1) NEQ "/">
						<cfset i = "/#i#" /><!--- add slash --->
					</cfif>
					<cfset stCSS.lFullFilePaths = listAppend(stCSS.lFullFilePaths,"#stCSS.path##i#") />
				</cfloop>
			
				<cfset sCacheFileName = application.fc.utils.combine(	files=stCSS.lFullFilePaths,
																		prepend:stCSS.prepend,
																		append:stCSS.append) />
				
				<cfset application.fc.stCSSLibraries[idHash].sCacheFileName = sCacheFileName />
			</cfif>
			
			<cfsavecontent variable="css">
				<cfoutput>
				<!-- 
				PATH: #stCSS.path#
				FILES: #stCSS.lFiles#
				 -->
				</cfoutput>
				
				<cfif len(stCSS.condition)>
					<cfoutput><!--[#stCSS.condition#]>
					<link rel="stylesheet" type="text/css" href="#application.url.webroot#/cache/#sCacheFileName#" media="#stCSS.media#">
					<![endif]-->
					</cfoutput>
				<cfelse>
					<cfoutput><link rel="stylesheet" type="text/css" href="/cache/#sCacheFileName#" media="#stCSS.media#">
					</cfoutput>
				</cfif>			
			</cfsavecontent>
			<cfhtmlhead text="#css#">
	
		</cfloop>
	</cfif>
</cfif>