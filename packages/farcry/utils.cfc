<cfcomponent displayname="Utilities" hint="Packages generic utilities" output="true">

	<!--- LIST utilities --->
	<cffunction name="listReverse" access="public" output="false" returntype="string" hint="Reverses a list">
		<cfargument name="list" type="string" required="true" />
		<cfargument name="delimiters" type="string" required="false" default="," />
		
		<cfset var result = "" />
		<cfset var item = "" />
		<cfset var delimiter = left(arguments.delimiters,1) />
		
		<cfloop list="#arguments.list#" index="item">
			<cfif len(result)>
				<cfset result = item & delimiter & result />
			<cfelse>
				<cfset result = item />
			</cfif>
		</cfloop>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="listDiff" access="public" output="false" returntype="string" hint="Returns the items in list2 that aren't in list2">
		<cfargument name="list1" type="string" required="true" />
		<cfargument name="list2" type="string" required="true" />
		<cfargument name="delimiters" type="string" required="false" default="," />
		
		<cfset var result = "" />
		<cfset var delimiter = left(arguments.delimiters,1) />
		
		<cfloop list="#arguments.list2#" index="item" delimiters="#arguments.delimiters#">
			<cfif not listcontainsnocase(arguments.list1,item,arguments.delimiters)>
				<cfset result = listappend(result,item,delimiter) />
			</cfif>
		</cfloop>
		
		<cfreturn result />
	</cffunction>

	<cffunction name="listMerge" access="public" output="false" returntype="string" hint="Adds items from the second list to the first, where they aren't already present">
		<cfargument name="list1" type="string" required="true" hint="The list being built on" />
		<cfargument name="list2" type="string" required="true" hint="The list being added" />
		<cfargument name="delimiters" type="string" required="false" default="," hint="The delimiters used the lists" />
		
		<cfset var lResult = arguments.list1 />
		<cfset var thisitem = "" />
		<cfset var delimiter = left(arguments.delimiters,1) />
		
		<cfloop list="#arguments.list2#" index="thisitem" delimiters="#arguments.delimiters#">
			<cfif not listcontainsnocase(lResult,thisitem,arguments.delimiters)>
				<cfset lResult = listappend(lResult,thisitem,delimiter) />
			</cfif>
		</cfloop>
		
		<cfreturn lResult />
	</cffunction>

	<cffunction name="listSlice" access="public" output="false" returntype="string" hint="Returns the specified elements of the list">
		<cfargument name="list" type="string" required="true" hint="The list being sliced" />
		<cfargument name="start" type="numeric" required="false" defaykt="1" hint="The start index of the slice. Negative numbers are reverse indexes: -1 is last item." />
		<cfargument name="end" type="numeric" required="false" default="-1" hint="The end index of the slice. Negative values are reverse indexes: -1 is last item." />
		<cfargument name="delimiters" type="string" required="false" default="," hint="Delimiters used by list" />
		
		<cfset var aDelimiters = arraynew(1) />
		<cfset var last = 0 />
		<cfset var next = 0 />
		
		<cfset arguments.delimiters = replacelist(arguments.delimiters,'\,[,],{,},(,),+,?,.,$,^,|,!,:','\\,\[,\],\{,\},\(,\),\+,\?,\.,\$,\^,\|,\!,\:') />
		
		<cfset aDelimiters[1] = 0 />
		<cfset last = 1 />
		<cfset next = refindnocase("[#arguments.delimiters#]",arguments.list,last,false) />
		<cfloop condition="#next#">
			<cfset arrayappend(aDelimiters,next)>
			<cfset last = next />
			<cfset next = refindnocase("[#arguments.delimiters#]",arguments.list,last+1,false) />
			<cfif next eq 0 and last lt len(arguments.list)+1>
				<cfset next = len(arguments.list)+1 />
			</cfif>
		</cfloop>
		
		<cfif arguments.start lt 0>
			<cfset arguments.start = arraylen(aDelimiters) + arguments.start />
		</cfif>
		
		<cfif arguments.end gt 0>
			<cfset arguments.end = arguments.end+1 />
		<cfelseif arguments.end lt 0>
			<cfset arguments.end = arraylen(aDelimiters) + arguments.end + 1 />
		</cfif>
		
		<cfif arguments.start lte arguments.end and 0 lt arguments.end>
			<cfreturn mid(arguments.list,aDelimiters[arguments.start]+1,aDelimiters[arguments.end]-aDelimiters[arguments.start]-1) />
		</cfif>
		
		<cfreturn "" />
	</cffunction>

	<!--- STRUCT ulilities --->
	<cffunction name="structMerge" access="public" output="false" returntype="struct" hint="Performs a deep merge on two structs">
		<cfargument name="struct1" type="struct" required="true" />
		<cfargument name="struct2" type="struct" required="true" />
		<cfargument name="replace" type="boolean" required="false" default="true" />
		
		<cfset var key="" />
		
		<cfloop collection="#arguments.struct2#" item="key">
			<cfif isstruct(arguments.struct2[key])>
				<cfif structkeyexists(arguments.struct1,key) and isstruct(arguments.struct1[key])>
					<cfset structMerge(arguments.struct1[key],arguments.struct2[key],arguments.replace) />
				<cfelseif arguments.replace>
					<cfset arguments.struct1[key] = arguments.struct2[key] />
				</cfif>
			<cfelseif issimplevalue(arguments.struct2[key]) and arguments.replace>
				<cfset arguments.struct1[key] = arguments.struct2[key] />
			<cfelseif arguments.replace>
				<cfset arguments.struct1[key] = duplicate(arguments.struct2[key]) />
			</cfif>
		</cfloop>
	</cffunction>

	<!--- PACKAGE utilities --->
	<cffunction name="getPath" access="public" output="false" returntype="string" hint="Finds the component in core/plugins/project, and returns its path">
		<cfargument name="package" type="string" required="true" />
		<cfargument name="component" type="string" required="true" />
		<cfargument name="locations" type="string" required="false" default="project,#listreverse(application.plugins)#,core" />
		
		<cfset var item = "" />
		
		<cfloop list="#arguments.locations#" index="item">
			<cfswitch expression="#item#">
				<cfcase value="core">
					<cfif fileexists("#application.path.core#/packages/#arguments.package#/#arguments.component#.cfc")>
						<cfreturn "farcry.core.packages.#arguments.package#.#arguments.component#" />
					</cfif>
				</cfcase>
				<cfcase value="project">
					<cfif fileexists("#application.path.project#/packages/#arguments.package#/#arguments.component#.cfc")>
						<cfreturn "farcry.projects.#application.projectDirectoryName#.packages.#arguments.package#.#arguments.component#" />
					<cfelseif arguments.package eq "types" and fileexists("#application.path.project#/packages/system/#arguments.component#.cfc")>
						<!--- Best practice is to put extensions of core types into the system package --->
						<cfreturn "farcry.projects.#application.projectDirectoryName#.packages.system.#arguments.component#" />
					<cfelseif arguments.package eq "system" and fileexists("#application.path.project#/packages/types/#arguments.component#.cfc")>
						<!--- Best practice is to put extensions of core types into the system package --->
						<cfreturn "farcry.projects.#application.projectDirectoryName#.packages.types.#arguments.component#" />
					</cfif>
				</cfcase>
				<cfdefaultcase><!--- Plugin --->
					<cfif listcontainsnocase(application.plugins,item)>
						<cfif fileexists("#application.path.plugins#/#item#/packages/#arguments.package#/#arguments.component#.cfc")>
							<cfreturn "farcry.plugins.#item#.packages.#arguments.package#.#arguments.component#" />
						<cfelseif arguments.package eq "types" and fileexists("#application.path.plugins#/#item#/packages/system/#arguments.component#.cfc")>
							<!--- Best practice is to put extensions of core types into the system package --->
							<cfreturn "farcry.plugins.#item#.packages.system.#arguments.component#" />
						<cfelseif arguments.package eq "system" and fileexists("#application.path.plugins#/#item#/packages/types/#arguments.component#.cfc")>
							<!--- Best practice is to put extensions of core types into the system package --->
							<cfreturn "farcry.plugins.#item#.packages.types.#arguments.component#" />
						</cfif>
					</cfif>
				</cfdefaultcase>
			</cfswitch>
		</cfloop>
		
		<cfreturn "" />
	</cffunction>

	<cffunction name="getComponents" access="public" output="false" returntype="string" hint="Returns a list of components for a package">
		<cfargument name="package" type="string" required="true" />
		<cfargument name="locations" type="string" required="false" default="project,#listreverse(application.plugins)#,core" />

		<cfset var item = "" />
		<cfset var list = "" />
		<cfset var qItems = querynew("name","varchar") />

		<cfloop list="#arguments.locations#" index="item">
			<cfswitch expression="#item#">
				<cfcase value="core">
					<cfif directoryexists("#application.path.core#/packages/#arguments.package#/")>
						<cfdirectory action="list" directory="#application.path.core#/packages/#arguments.package#/" filter="*.cfc" name="qItems" />
					</cfif>
				</cfcase>
				<cfcase value="project">
					<cfif directoryexists("#application.path.project#/packages/#arguments.package#/")>
						<cfdirectory action="list" directory="#application.path.project#/packages/#arguments.package#/" filter="*.cfc" name="qItems" />
					</cfif>
				</cfcase>
				<cfdefaultcase><!--- Plugin --->
					<cfif listcontainsnocase(application.plugins,item)>
						<cfif directoryexists("#application.path.project#/packages/#arguments.package#/")>
							<cfdirectory action="list" directory="#application.path.plugins#/#item#/packages/#arguments.package#/" filter="*.cfc" name="qItems" />
						</cfif>
					</cfif>
				</cfdefaultcase>
			</cfswitch>
			<cfloop query="qItems">
				<cfif not listcontainsnocase(list,listfirst(name,"."))>
					<cfset list = listappend(list,listfirst(name,".")) />
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn list />
	</cffunction>

</cfcomponent>