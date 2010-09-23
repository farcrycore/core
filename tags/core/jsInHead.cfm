
<cfif thistag.executionMode eq "End">
	<!--- Do Nothing --->
</cfif>

<cfif thistag.executionMode eq "Start">
	
	<cfif NOT request.mode.ajax>
		<cfparam name="request.inHead.aJSLibraries" default="#arrayNew(1)#" />
		<cfparam name="request.inHead.stJSLibraries" default="#structNew()#" />
		<cfset aJS = arraynew(1) />
		
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
			<cfif listcontainsnocase(toremove,aJS[i].id)>
				<cfset arraydeleteat(aJS,i) />
			</cfif>
		</cfloop>
		
		<cfloop from="1" to="#arrayLen(aJS)#" index="i">
		
			
			<cfset stJS = aJS[i] />

			<cfif stJS.bCombine>
				<cfset idHash = hash("#stJS.baseHREF##stJS.lFiles##stJS.prepend##stJS.append#") />
				
				<cfset sCacheFileName = "" />
				
				<cfif structKeyExists(application.fc.stJSLibraries,idHash) AND NOT request.mode.flushcache>
					<cfif structKeyExists(application.fc.stJSLibraries[idHash],"sCacheFileName")>
						<cfif fileExists('#application.path.cache#/#application.fc.stJSLibraries[idHash].sCacheFileName#')>
							<cfset sCacheFileName = application.fc.stJSLibraries[idHash].sCacheFileName />
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
					<cfset sCacheFileName = application.fc.utils.combine(	id=stJS.id,
																		files=stJS.lFullFilebaseHREFs,
																		type="js",
																		prepend=stJS.prepend,
																		append=stJS.append) />
				
					<cfset application.fc.stJSLibraries[idHash].sCacheFileName = sCacheFileName />
				</cfif>
			</cfif>
			
			<cfsavecontent variable="JS">
				<cfoutput>
				<!-- 
				ID: #stJS.id#<cfif len(stJS.lCombineIDs)>
				PACKAGED: #stJS.lCombineIDs#</cfif>
				FILES: #stJS.lFullFilebaseHREFs#
				 -->
				</cfoutput>
				
				<cfif len(stJS.condition)>
					<cfoutput><!--[#stJS.condition#]>
					</cfoutput>
				</cfif>
				
				<cfif stJS.bCombine>
					<cfoutput>
					<script src="#stJS.hostname##application.url.webroot##application.url.cache#/#sCacheFileName#" type="text/javascript"></script>
					</cfoutput>
				<cfelse>
					<cfloop list="#stJS.lFiles#" index="i">						
						<cfif left(i,1) NEQ "/">
							<cfset i = "/#i#" /><!--- add slash --->
						</cfif>
						<cfoutput>
						<script src="#stJS.hostname##stJS.baseHREF##i#" type="text/javascript"></script>
						</cfoutput>
					</cfloop>
				</cfif>
				<cfif len(stJS.condition)>
					<cfoutput><![endif]-->
					</cfoutput>	
				</cfif>	
				
			</cfsavecontent>
			
			<cfhtmlhead text="#JS#">
	
		</cfloop>
	</cfif>
</cfif>