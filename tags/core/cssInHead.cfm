
<cfif thistag.executionMode eq "End">
	<!--- Do Nothing --->
</cfif>

<cfif thistag.executionMode eq "Start">

	<cfparam name="request.mode.ajax" default="0">

	<cfif NOT request.mode.ajax>
		<cfparam name="request.inHead.aCSSLibraries" default="#arrayNew(1)#" />
		<cfparam name="request.inHead.stCSSLibraries" default="#structNew()#" />
		<cfset aCSS = arraynew(1) />
		
		<!--- Processes library packages --->
		<cfset toremove = "" />
		<cfloop from="#arraylen(request.inHead.aCSSLibraries)#" to="1" index="i" step="-1">
			<cfset stCSS = duplicate(request.inHead.stCSSLibraries[request.inHead.aCSSLibraries[i]]) />
			<cfif len(stCSS.lCombineIDs)>
				<!--- Remove these libraries from the stack (has to be done outside this loop) --->
				<cfset toremove = listappend(toremove,stCSS.lCombineIDs) />
				
				<!--- Add the files of these libraries to the package --->
				<cfloop list="#application.fc.utils.listReverse(stCSS.lCombineIDs)#" index="thisid">
					<cfif structkeyexists(request.inHead.stCSSLibraries,thisid)>
						<cfset stCSS.lFullFilebaseHREFs = listprepend(stCSS.lFullFilebaseHREFs,request.inHead.stCSSLibraries[thisid].lFullFilebaseHREFs)>
					<cfelseif structkeyexists(application.fc.stCSSLibraries,thisid)>
						<cfset stCSS.lFullFilebaseHREFs = listprepend(stCSS.lFullFilebaseHREFs,application.fc.stCSSLibraries[thisid].lFullFilebaseHREFs)>
					</cfif>
				</cfloop>
			</cfif>
			<cfset arrayprepend(aCSS,stCSS) />
		</cfloop>
		<cfloop from="#arraylen(aCSS)#" to="1" index="i" step="-1">
			<cfif listfindnocase(toremove,aCSS[i].id)>
				<cfset arraydeleteat(aCSS,i) />
			</cfif>
		</cfloop>
		
		<!--- If XMTHML, then we need the trailing slash --->
		<cfset tagEnding = application.fapi.getDocType().tagEnding />
	
		<cfloop from="1" to="#arrayLen(aCSS)#" index="i">
		
			<cfset stCSS = aCSS[i] />
		
			<cfif structKeyExists(stCSS, "bCombine") AND stCSS.bCombine>
				<cfset idHash = hash("#stCSS.baseHREF##stCSS.lFiles##stCSS.lCombineIDs##stCSS.prepend##stCSS.append#") />
			
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
			
				<cfif not len(sCacheFileName) and stCSS.bCombine>
					<cfset sCacheFileName = application.fc.utils.combine(	id=stCSS.id,
																			files=stCSS.lFullFilebaseHREFs,
																			type="css",
																			prepend=stCSS.prepend,
																			append=stCSS.append) />
			
					<cfset application.fc.stCSSLibraries[idHash].sCacheFileName = sCacheFileName />
				</cfif>
			</cfif>
		
			<cfsavecontent variable="css">
<cfoutput>#chr(13)#
  <!-- 
  ID: #stCSS.id#<cfif len(stCSS.lCombineIDs)>
  PACKAGED: #stCSS.lCombineIDs#</cfif>
  FILES: #stCSS.lFullFilebaseHREFs#
  -->
</cfoutput>
			
				<cfif len(stCSS.condition)>
					<cfoutput>  <!--[#stCSS.condition#]>#chr(13)#</cfoutput>
				</cfif>
			
				<cfif stCSS.bCombine>
					<cfoutput><link rel="stylesheet" type="text/css" href="#stCSS.hostname##application.url.cache#/#sCacheFileName#" media="#stCSS.media#" #tagEnding#></cfoutput>
				<cfelseif stCSS.bExternal>
					<cfif len(trim(stCSS.prepend))><cfoutput><style type="text/css">#stCSS.prepend#</style></cfoutput></cfif>
					<cfloop list="#stCSS.lFiles#" index="i">
						<cfoutput><link rel="stylesheet" type="text/css" href="#i#" media="#stCSS.media#" #tagEnding#></cfoutput>
					</cfloop>
					<cfif len(trim(stCSS.append))><cfoutput><style type="text/css">#stCSS.append#</style></cfoutput></cfif>
				<cfelse>
					<cfif len(trim(stCSS.prepend))><cfoutput><style type="text/css">#stCSS.prepend#</style></cfoutput></cfif>
					<cfloop list="#stCSS.lFiles#" index="i">
						<cfoutput><link rel="stylesheet" type="text/css" href="#stCSS.hostname##stCSS.baseHREF#/#i#" media="#stCSS.media#" #tagEnding#></cfoutput>
					</cfloop>
					<cfif len(trim(stCSS.append))><cfoutput><style type="text/css">#stCSS.append#</style></cfoutput></cfif>
				</cfif>
				<cfif len(stCSS.condition)>
					<cfoutput>  <![endif]-->#chr(13)#</cfoutput>	
				</cfif>		
			</cfsavecontent>

			<cfhtmlhead text="#css#" />
		
		</cfloop>
	</cfif>
</cfif>