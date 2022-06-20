
<cfif thistag.executionMode eq "End">
	<!--- Do Nothing --->
</cfif>

<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.inline" default="false" />
	<cfparam name="attributes.r_html" default="" />

	<cfparam name="request.mode.ajax" default="0">
	<cfparam name="request.mode.flushcache" default="0">
	<cfparam name="request.mode.livecombine" default="0">
	
	<cfparam name="request.inHead.aJSLibraries" default="#arrayNew(1)#" />
	<cfparam name="request.inHead.stJSLibraries" default="#structNew()#" />

	<cfset aJS = arraynew(1) />
	<cfset CRLF = chr(13) & chr(10) />

	<!--- Remove alias duplicates --->
	<cfset listSoFar = "" />
	<cfloop list="#arraytolist(request.inHead.aJSLibraries)#" index="i">
		<cfif len(request.inHead.stJSLibraries[i].aliasOf) and listFindNoCase(listSoFar, request.inHead.stJSLibraries[i].aliasOf)>
			<cfset arraydeleteat(request.inHead.aJSLibraries,arrayfind(request.inHead.aJSLibraries,i)) />
		<cfelse>
			<cfset listSoFar = listAppend(listSoFar, i) />
		</cfif>
	</cfloop>
	
	<!--- Processes library packages --->
	<cfset toremove = "" />
	<cfloop from="#arraylen(request.inHead.aJSLibraries)#" to="1" index="i" step="-1">
		<cfset stJS = duplicate(request.inHead.stJSLibraries[request.inHead.aJSLibraries[i]]) />
		<cfif len(stJS.lCombineIDs)>
			<!--- Remove these libraries from the stack (has to be done outside this loop) --->
			<cfset toremove = listappend(toremove,stJS.lCombineIDs) />
			
			<!--- Add the files of these libraries to the package --->
			<cfloop list="#application.fc.utils.listReverse(stJS.lCombineIDs)#" index="thisid">
				<cfif structkeyexists(request.inHead.stJSLibraries,thisid)>
					<cfset stJS.lFullFilebaseHREFs = listprepend(stJS.lFullFilebaseHREFs,request.inHead.stJSLibraries[thisid].lFullFilebaseHREFs)>
				<cfelseif structkeyexists(application.fc.stJSLibraries,thisid)>
					<cfset stJS.lFullFilebaseHREFs = listprepend(stJS.lFullFilebaseHREFs,application.fc.stJSLibraries[thisid].lFullFilebaseHREFs)>
				</cfif>
			</cfloop>
		</cfif>
		<cfset arrayprepend(aJS,stJS) />
	</cfloop>
	<cfloop from="#arraylen(aJS)#" to="1" index="i" step="-1">
		<cfif refindnocase("(^|,)#aJS[i].id#(,|$)",toremove)>
			<cfset arraydeleteat(aJS,i) />
		</cfif>
	</cfloop>
	
	<cfif len(attributes.r_html)>
		<cfparam name="caller.#attributes.r_html#" default="#arraynew(1)#" />
	</cfif>
	
	<cfloop from="1" to="#arrayLen(aJS)#" index="i">
	
		
		<cfset stJS = aJS[i] />

		<cfif stJS.bCombine>
			<cfset idHash = hash("#stJS.baseHREF##stJS.lFiles##stJS.lCombineIDs##stJS.prepend##stJS.append#") />
			
			<cfset sCacheFileName = "" />
			
			<cfif structKeyExists(application.fc.stJSLibraries,idHash) AND NOT request.mode.flushcache>
				<cfif structKeyExists(application.fc.stJSLibraries[idHash],"sCacheFileName")>
					<cfif fileExists('#application.path.cache#/#application.fc.stJSLibraries[idHash].sCacheFileName#')>
						<cfset sCacheFileName = application.fc.stJSLibraries[idHash].sCacheFileName />
						
						<cfif request.mode.livecombine>
							<cfset latest = createdatetime(1970,1,1,1,1,1) />
							<cfloop list="#stJS.lFullFilebaseHREFs#" index="thisfile">
								<cfset stAttr = getFileInfo(expandpath(thisfile)) />
								<cfif datecompare(latest,stAttr.lastmodified) lt 0>
									<cfset latest = stAttr.lastmodified />
								</cfif>
							</cfloop>
							
							<cfif not structkeyexists(application.fc.stJSLibraries[idHash],"modified") or datecompare(application.fc.stJSLibraries[idHash].modified,latest) lt 0>
								<cfset application.fc.stJSLibraries[idHash].modified = latest />
								<cfset sCacheFileName = "" />
							</cfif>
						</cfif>
					</cfif>
				</cfif>
			<cfelse>
				<cfset application.fapi.registerJS(	id="#idHash#", 
													baseHREF="#stJS.baseHREF#", 
													condition="#stJS.condition#", 
													prepend="#stJS.prepend#", 
													append="#stJS.append#", 
													bCombine="#stJS.bCombine#"
													) />
			</cfif>
			
			<cfif not len(sCacheFileName) and stJS.bCombine>
				<cflock name="#idhash#" timeout="10">
					<cfif structKeyExists(application.fc.stJSLibraries,idHash) AND NOT request.mode.flushcache
						and structKeyExists(application.fc.stJSLibraries[idHash],"sCacheFileName")
						and fileExists('#application.path.cache#/#application.fc.stJSLibraries[idHash].sCacheFileName#')>
						
						<cfset sCacheFileName = application.fc.stJSLibraries[idHash].sCacheFileName />
						
					<cfelse>
					
						<cfset sCacheFileName = application.fc.utils.combine(	id=stJS.id,
																			files=stJS.lFullFilebaseHREFs,
																			type="js",
																			prepend=stJS.prepend,
																			append=stJS.append) />
					
						<cfset application.fc.stJSLibraries[idHash].sCacheFileName = sCacheFileName />
					
					</cfif>
				</cflock>
			</cfif>
		</cfif>
		
		<cfsavecontent variable="JS">

<cfset urlDebug = application.fapi.getConfig("security","urlDebug","boolean")>
<cfif isdefined("url.debug") AND urlDebug neq "disable">
    <cfif (urlDebug eq "updateappkey" AND url.debug eq application.updateappKey) or (urlDebug eq "boolean" AND url.debug eq 1) or (cgi.remote_addr eq "127.0.0.1")>
<cfoutput>
<!-- 
ID: #stJS.id#<cfif len(stJS.lCombineIDs)>
PACKAGED: #stJS.lCombineIDs#</cfif>
FILES: #stJS.lFullFilebaseHREFs#
-->
</cfoutput>
    </cfif>
</cfif>

			<cfif len(stJS.condition)>
				<cfoutput><!--[#stJS.condition#]>#CRLF#</cfoutput>
			</cfif>
			
			<cfif stJS.bCombine>
				<cfset stLoc = application.fc.lib.cdn.ioGetFileLocation(location='cache',file=sCacheFileName) />
				<cfoutput><script src="#stLoc.path#" id="javascript-#stJS.id#" type="text/javascript"></script></cfoutput>
			<cfelseif stJS.bExternal>
				<cfoutput><meta id="javascript-#stJS.id#" property="jsid" content="#stJS.id#"></cfoutput>
				<cfif len(trim(stJS.prepend))><cfoutput><script type="text/javascript">#stJS.prepend#</script></cfoutput></cfif>
				<cfloop list="#stJS.lFiles#" index="i">
					<cfoutput><script src="#i#" type="text/javascript"></script></cfoutput>
				</cfloop>
				<cfif len(trim(stJS.append))><cfoutput><script type="text/javascript">#stJS.append#</script></cfoutput></cfif>
			<cfelse>
				<cfoutput><meta id="javascript-#stJS.id#" property="jsid" content="#stJS.id#"></cfoutput>
				<cfif len(trim(stJS.prepend))><cfoutput><script type="text/javascript">#stJS.prepend#</script></cfoutput></cfif>
				<cfloop list="#stJS.lFiles#" index="i">
					<cfoutput><script src="#stJS.baseHREF#/#i#" type="text/javascript"></script></cfoutput>
				</cfloop>
				<cfif len(trim(stJS.append))><cfoutput><script type="text/javascript">#stJS.append#</script></cfoutput></cfif>
			</cfif>
			<cfif len(stJS.condition)>
				<cfoutput>#CRLF#<![endif]--></cfoutput>	
			</cfif>	
			
			<cfoutput>#CRLF#</cfoutput>
		</cfsavecontent>
		
		<cfif len(attributes.r_html)>
			<cfset st = structnew() />
			<cfset st["id"] = "javascript-#stJS.id#" />
			<cfset st["html"] = js />
			<cfset arrayappend(caller[attributes.r_html],st) />
		<cfelseif attributes.inline>
			<cfoutput>#JS#</cfoutput>
		<cfelse>
			<cfhtmlhead text="#JS#" />
		</cfif>

	</cfloop>

	<cfif attributes.inline>
		<!--- MJB: clear out js libraries --->
		<cfset request.inHead.aJSLibraries = arrayNew(1) />
	</cfif>


</cfif>