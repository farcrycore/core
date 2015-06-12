
<cfif thistag.executionMode eq "End">
	<!--- Do Nothing --->
</cfif>
<cfparam name="request.mode.ajax" default="0">
<cfparam name="request.mode.flushcache" default="0">
<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.inline" default="false" />
	<cfparam name="attributes.r_html" default="" />

	<cfparam name="request.mode.flushcache" default="0">
	<cfparam name="request.mode.livecombine" default="0">
	
	<cfparam name="request.inHead.aCSSLibraries" default="#arrayNew(1)#" />
	<cfparam name="request.inHead.stCSSLibraries" default="#structNew()#" />

	<cfset aCSS = arraynew(1) />
	<cfset CRLF = chr(13) & chr(10) />

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
		<cfif refindnocase("(^|,)#aCSS[i].id#(,|$)",toremove)>
			<cfset arraydeleteat(aCSS,i) />
		</cfif>
	</cfloop>
	
	<cfif len(attributes.r_html)>
		<cfparam name="caller.#attributes.r_html#" default="#arraynew(1)#" />
	</cfif>
	
	<cfloop from="1" to="#arrayLen(aCSS)#" index="i">
	
		<cfset stCSS = aCSS[i] />
	
		<cfif structKeyExists(stCSS, "bCombine") AND stCSS.bCombine>
			<cfset idHash = hash("#stCSS.baseHREF##stCSS.lFiles##stCSS.lCombineIDs##stCSS.prepend##stCSS.append#") />
		
			<cfset sCacheFileName = "" />
		
			<cfif structKeyExists(application.fc.stCSSLibraries,idHash)>
				<cfif structKeyExists(application.fc.stCSSLibraries[idHash],"sCacheFileName")>
					<cfif fileExists('#application.path.cache#/#application.fc.stCSSLibraries[idHash].sCacheFileName#')>
						<cfset sCacheFileName = application.fc.stCSSLibraries[idHash].sCacheFileName />
						
						<cfif request.mode.livecombine>
							<cfset latest = createdatetime(1970,1,1,1,1,1) />
							<cfloop list="#stCSS.lFullFilebaseHREFs#" index="thisfile">
								<cfset stAttr = getFileInfo(expandpath(thisfile)) />
								<cfif datecompare(latest,stAttr.lastmodified) lt 0>
									<cfset latest = stAttr.lastmodified />
								</cfif>
							</cfloop>
							
							<cfif not structkeyexists(application.fc.stCSSLibraries[idHash],"modified") or datecompare(application.fc.stCSSLibraries[idHash].modified,latest) lt 0>
								<cfset application.fc.stCSSLibraries[idHash].modified = latest />
								<cfset sCacheFileName = "" />
							</cfif>
						</cfif>
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
				<cflock name="#idhash#" timeout="10">
					<cfif structKeyExists(application.fc.stCSSLibraries,idHash) 
						and structKeyExists(application.fc.stCSSLibraries[idHash],"sCacheFileName")
						and fileExists('#application.path.cache#/#application.fc.stCSSLibraries[idHash].sCacheFileName#')>
						
						<cfset sCacheFileName = application.fc.stCSSLibraries[idHash].sCacheFileName />
						
					<cfelse>
					
						<cfset sCacheFileName = application.fc.utils.combine(	id=stCSS.id,
																				files=stCSS.lFullFilebaseHREFs,
																				type="css",
																				prepend=stCSS.prepend,
																				append=stCSS.append) />
				
						<cfset application.fc.stCSSLibraries[idHash].sCacheFileName = sCacheFileName />
					
					</cfif>
				</cflock>
			</cfif>
		</cfif>
	
		<cfsavecontent variable="css">

			<cfif structKeyExists(url, "debug") AND url.debug eq 1>
<cfoutput>
<!-- 
ID: #stCSS.id#<cfif len(stCSS.lCombineIDs)>
PACKAGED: #stCSS.lCombineIDs#</cfif>
FILES: #stCSS.lFullFilebaseHREFs#
-->
</cfoutput>
			</cfif>

			<cfif len(stCSS.condition)>
				<cfoutput><!--[#stCSS.condition#]>#CRLF#</cfoutput>
			</cfif>
		
			<cfif stCSS.bCombine>
				<cfset stLoc = application.fc.lib.cdn.ioGetFileLocation(location='cache',file=sCacheFileName) />
				<cfoutput><link rel="stylesheet" id="stylesheet-#stCSS.id#" type="text/css" href="#stLoc.path#" media="#stCSS.media#"></cfoutput>
			<cfelseif stCSS.bExternal>
				<cfoutput><meta id="stylesheet-#stCSS.id#" property="cssid" content="#stCSS.id#"></cfoutput>
				<cfif len(trim(stCSS.prepend))><cfoutput><style type="text/css">#stCSS.prepend#</style></cfoutput></cfif>
				<cfloop list="#stCSS.lFiles#" index="i">
					<cfoutput><link rel="stylesheet" type="text/css" href="#i#" media="#stCSS.media#"></cfoutput>
				</cfloop>
				<cfif len(trim(stCSS.append))><cfoutput><style type="text/css">#stCSS.append#</style></cfoutput></cfif>
			<cfelse>
				<cfoutput><meta id="stylesheet-#stCSS.id#" property="cssid" content="#stCSS.id#"></cfoutput>
				<cfif len(trim(stCSS.prepend))><cfoutput><style type="text/css">#stCSS.prepend#</style></cfoutput></cfif>
				<cfloop list="#stCSS.lFiles#" index="i">
					<cfoutput><link rel="stylesheet" type="text/css" href="#stCSS.baseHREF#/#i#" media="#stCSS.media#"></cfoutput>
				</cfloop>
				<cfif len(trim(stCSS.append))><cfoutput><style type="text/css">#stCSS.append#</style></cfoutput></cfif>
			</cfif>
			<cfif len(stCSS.condition)>
				<cfoutput>#CRLF#<![endif]--></cfoutput>	
			</cfif>

			<cfoutput>#CRLF#</cfoutput>
		</cfsavecontent>
		
		<cfif len(attributes.r_html)>
			<cfset st = structnew() />
			<cfset st["id"] = "stylesheet-#stCSS.id#" />
			<cfset st["html"] = css />
			<cfset arrayappend(caller[attributes.r_html],st) />
		<cfelseif attributes.inline>
			<cfoutput>#css#</cfoutput>
		<cfelse>
			<cfhtmlhead text="#css#" />
		</cfif>
	
	</cfloop>

	<cfif attributes.inline>
		<!--- MJB: clear out css libraries --->
		<cfset request.inHead.aCSSLibraries = arrayNew(1) />
	</cfif>





</cfif>