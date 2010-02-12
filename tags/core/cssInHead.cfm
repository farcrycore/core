
<cfif thistag.executionMode eq "End">
	<!--- Do Nothing --->
</cfif>

<cfif thistag.executionMode eq "Start">
	
	<cfif NOT request.mode.ajax>
		<cfparam name="request.inHead.aCSSLibraries" default="#arrayNew(1)#" />
		<cfparam name="request.inHead.stCSSLibraries" default="#structNew()#" />
		
		<!--- If XMTHML, then we need the trailing slash --->
		<cfset tagEnding = application.fapi.getDocType().tagEnding />
	
		<cfloop from="1" to="#arrayLen(request.inHead.aCSSLibraries)#" index="i">
		
			<cfif structKeyExists( request.inHead.stCSSLibraries, request.inHead.aCSSLibraries[i] )>
				
				<cfset stCSS = duplicate(request.inHead.stCSSLibraries[request.inHead.aCSSLibraries[i]]) />
			
				<cfif structKeyExists(stCSS, "bCombine") AND stCSS.bCombine>
					<cfset idHash = hash("#stCSS.baseHREF##stCSS.lFiles##stCSS.prepend##stCSS.append#") />
				
					<cfset sCacheFileName = "" />
				
					<cfif structKeyExists(application.fc.stCSSLibraries,idHash)>
						<cfif structKeyExists(application.fc.stCSSLibraries[idHash],"sCacheFileName")>
							<cfif fileExists(application.path.project & '/www/cache/#application.fc.stCSSLibraries[idHash].sCacheFileName#')>
								<cfset sCacheFileName = application.fc.stCSSLibraries[idHash].sCacheFileName />
							</cfif>
						</cfif>
					<cfelse>
						<cfset application.fapi.registerCSS(	id="#idHash#", 
																baseHREF="#stCSS.baseHREF#", 
																media="#stCSS.media#", 
																condition="#stCSS.condition#", 
																prepend="#stCSS.prepend#", 
																append="#stCSS.append#", 
																bCombine="#stCSS.bCombine#"
																) />
					</cfif>
				
					<cfif not len(sCacheFileName)>			
						
						<cfset stCSS.baseHREF = replaceNoCase(stCSS.baseHREF,"\","/","all") /><!--- Change back slashes --->
						<cfif len(stCSS.baseHREF) AND right(stCSS.baseHREF,1) EQ "/">
							<cfset stCSS.baseHREF = mid(stCSS.baseHREF,1,len(stCSS.baseHREF)-1) /><!--- Remove trailing slash --->
						</cfif>
					
					
						<cfset stCSS.lFiles = replaceNoCase(stCSS.lFiles,"\","/","all") /><!--- Change back slashes --->
			
						<cfset stCSS.lFullFileBaseHREFs = "" />
					
						<cfloop list="#stCSS.lFiles#" index="i">
							<cfif left(i,1) NEQ "/">
								<cfset i = "/#i#" /><!--- add slash --->
							</cfif>
							<cfset stCSS.lFullFileBaseHREFs = listAppend(stCSS.lFullFileBaseHREFs,"#stCSS.baseHREF##i#") />
						</cfloop>
				
						<cfif stCSS.bCombine>
							<cfset sCacheFileName = application.fc.utils.combine(	id=stCSS.id,
																					files=stCSS.lFullFilebaseHREFs,
																					type="css",
																					prepend=stCSS.prepend,
																					append=stCSS.append) />
					
							<cfset application.fc.stCSSLibraries[idHash].sCacheFileName = sCacheFileName />
						</cfif>
					</cfif>
				</cfif>
			
				<cfsavecontent variable="css">
					<cfoutput>
					<!-- 
					ID: #stCSS.id#
					baseHREF: #stCSS.baseHREF#
					FILES: #stCSS.lFiles#
					 -->
					</cfoutput>
				
					<cfif len(stCSS.condition)>
						<cfoutput><!--[#stCSS.condition#]>
						</cfoutput>
					</cfif>
				
					<cfif stCSS.bCombine>
						<cfoutput>
						<link rel="stylesheet" type="text/css" href="#application.url.webroot#/cache/#sCacheFileName#" media="#stCSS.media#" #tagEnding#>
						</cfoutput>
					<cfelse>
						<cfloop list="#stCSS.lFiles#" index="i">						
							<cfif left(i,1) NEQ "/">
								<cfset i = "/#i#" /><!--- add slash --->
							</cfif>
							<cfoutput>
							<link rel="stylesheet" type="text/css" href="#stCSS.baseHREF##i#" media="#stCSS.media#" #tagEnding#>
							</cfoutput>
						</cfloop>
					</cfif>
					<cfif len(stCSS.condition)>
						<cfoutput><![endif]-->
						</cfoutput>	
					</cfif>		
				</cfsavecontent>
				<cfhtmlhead text="#css#">
		
			</cfif>
		
		</cfloop>
	</cfif>
</cfif>