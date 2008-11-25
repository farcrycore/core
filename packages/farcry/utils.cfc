<cfcomponent displayname="Utilities" hint="Packages generic utilities" output="true" bDocument="true" scopelocation="application.factory.oUtils">


	<cffunction access="public" returntype="utils" name="init" output="false" hint="Constructor">
		<cfargument name="jarPath" type="string" required="yes" default="/farcry/core/packages/farcry/uuid/uuid-3.0.jar" />
		
		<cfset var paths = arrayNew(1) />
		
		<!--- This points to the jar we want to load. Could also load a directory of .class files --->
		<cfset paths[1] = expandPath(arguments.jarPath) />
		
		<!--- create the loader --->
		<cfset variables.loader = createObject("component", "farcry.core.packages.farcry.javaloader.JavaLoader").init(paths) />
		
		
		<!--- Please don't take this out.  It wont run on the AOC server without it --->
		<cfset theSystem = createObject("java","java.lang.System") />
		<cfset jvmVersion = "#theSystem.getProperty('java.runtime.version')#" /> 
		<cfset aMajorMinor = listToArray(jvmVersion,".") />
		
		<cfset variables.aJVMMajorMinor = aMajorMinor />
		
		<cfset variables.JVM1_5 = false />
		<cfif variables.aJVMMajorMinor[1] gt 1 
			or (variables.aJVMMajorMinor[1] eq 1 and variables.aJVMMajorMinor[1] gte 5)>
			<cfset variables.JVM1_5 = true />
		</cfif>
		
		<cfreturn this />
	</cffunction>

	<cffunction name="createJavaUUID" access="public" returntype="any" output="false" hint="">
		<cfset var newUUID = "" />
		<cfset var oUUID = "" />
		<cfset var rMyUUID =  "" />
		
		<!--- We need to check the current java version and only use
			the fast UUID library if we are running verison 1.5 or 1.6. --->
		<cfif variables.JVM1_5>
			<cfset oUUID = loader.create("com.eaio.uuid.UUID") />
			<cfset newUUID = oUUID.init() />
			<cfset rMyUUID = reverse(newUUID) />
			
			<cfset newUUID = replace(rMyUUID,"-","") />
			<cfset newUUID = uCase(reverse(newUUID)) />
		<cfelse>
			<cfset newUUID = createUUID() />
		</cfif>
		
		<cfreturn newUUID />
	</cffunction>


	<!--- ARRAY utilities --->
	<cffunction name="arrayFind" access="public" output="false" returntype="numeric" hint="Returns the index of the first element that matches the specified value. 0 if not found." bDocument="true">
		<cfargument name="ar" type="array" required="true" hint="The array to search" />
		<cfargument name="value" type="Any" required="true" hint="The value to find" />
		
		<cfset var i = 0 />
		
		<cfloop from="1" to="#arraylen(arguments.ar)#" index="i">
			<cfif arguments.ar[i] eq arguments.value>
				<cfreturn i />
			</cfif>
		</cfloop>
		
		<cfreturn 0 />
	</cffunction>

	<!--- LIST utilities --->
	<cffunction name="listReverse" access="public" output="false" returntype="string" hint="Reverses a list" bDocument="true">
		<cfargument name="list" type="string" required="true" />
		<cfargument name="delimiters" type="string" required="false" default="," />
		
		<cfset var result = "" />
		<cfset var item = "" />
		<cfset var delimiter = left(arguments.delimiters,1) />
		
		<cfloop list="#arguments.list#" index="item">
			<cfset result = listprepend(result,item) />
		</cfloop>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="listDiff" access="public" output="false" returntype="string" hint="Returns the items in list2 that aren't in list2" bDocument="true">
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
	
	<cffunction name="listIntersection" access="public" output="false" returntype="string" hint="Returns the items in list2 that are also in list2" bDocument="true">
		<cfargument name="list1" type="string" required="true" />
		<cfargument name="list2" type="string" required="true" />
		<cfargument name="delimiters" type="string" required="false" default="," />
		
		<cfset var result = "" />
		<cfset var delimiter = left(arguments.delimiters,1) />
		
		<cfloop list="#arguments.list2#" index="item" delimiters="#arguments.delimiters#">
			<cfif listcontainsnocase(arguments.list1,item,arguments.delimiters)>
				<cfset result = listappend(result,item,delimiter) />
			</cfif>
		</cfloop>
		
		<cfreturn result />
	</cffunction>

	<cffunction name="listMerge" access="public" output="false" returntype="string" hint="Adds items from the second list to the first, where they aren't already present" bDocument="true">
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

	<cffunction name="listSlice" access="public" output="false" returntype="string" hint="Returns the specified elements of the list" bDocument="true">
		<cfargument name="list" type="string" required="true" hint="The list being sliced" />
		<cfargument name="start" type="numeric" required="false" default="1" hint="The start index of the slice. Negative numbers are reverse indexes: -1 is last item." />
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

	<cffunction name="listFilter" access="public" output="false" returntype="string" hint="Filters the items in a list though a regular expression" bDocument="true">
		<cfargument name="list" type="string" required="true" hint="The list being filtered" />
		<cfargument name="filter" type="string" required="true" hint="The regular expression to filter by" />
		<cfargument name="delimiters" type="string" required="false" default="," hint="Delimiters used by list" />
		
		<cfset var result = "" />
		<cfset var thisitem = "" />
		
		<cfloop list="#arguments.list#" index="thisitem" delimiters="#arguments.delimeters#">
			<cfif refind(arguments.filter,thisitem)>
				<cfset result = listappend(result,thisitem,left(arguments.delimiters,1)) />
			</cfif>
		</cfloop>
		
		<cfreturn result />
	</cffunction>

	<cffunction name="listContainsAny" access="public" returntype="boolean" description="Returns true if the first list contains any of the items in the second list" output="false" bDocument="true">
		<cfargument name="list1" type="string" required="true" hint="The list being searched" />
		<cfargument name="list2" type="string" required="true" hint="The list of search terms" />
		<cfargument name="delimiters" type="string" required="false" default="," hint="Delimiters used by lists" />
		
		<cfset var thisitem = "" />
		
		<cfloop list="#arguments.list2#" index="thisitem" delimiters="#arguments.delimiters#">
			<cfif listcontains(arguments.list1,thisitem,arguments.delimiters)>
				<cfreturn true />
			</cfif>
		</cfloop>
		
		<cfreturn false />
	</cffunction>

	<cffunction name="listContainsAnyNoCase" access="public" returntype="boolean" description="Returns true if the first list contains any of the items in the second list" output="false" bDocument="true">
		<cfargument name="list1" type="string" required="true" hint="The list being searched" />
		<cfargument name="list2" type="string" required="true" hint="The list of search terms" />
		<cfargument name="delimiters" type="string" required="false" default="," hint="Delimiters used by lists" />
		
		<cfset var thisitem = "" />
		
		<cfloop list="#arguments.list2#" index="thisitem" delimiters="#arguments.delimiters#">
			<cfif listcontainsnocase(arguments.list1,thisitem,arguments.delimiters)>
				<cfreturn true />
			</cfif>
		</cfloop>
		
		<cfreturn false />
	</cffunction>

	<!--- STRUCT ulilities --->
	<cffunction name="structMerge" access="public" output="false" returntype="struct" hint="Performs a deep merge on two structs" bDocument="true">
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
		
		<cfreturn arguments.struct1 />
	</cffunction>

	<cffunction name="structCreate" returntype="struct" output="false" access="public" hint="Creates and populates a struct with the provided arguments" bDocument="true">
		
		<cfreturn duplicate(arguments) />
	</cffunction>

	<!--- PACKAGE utilities --->
	<cffunction name="getPath" access="public" output="false" returntype="string" hint="Finds the component in core/plugins/project, and returns its path" bDocument="true">
		<cfargument name="package" type="string" required="true" />
		<cfargument name="component" type="string" required="true" />
		<cfargument name="locations" type="string" required="false" default="" />
		
		<cfset var item = "" />

		<cfif not len(arguments.locations) and structkeyexists(application,"plugins")>
			<cfset arguments.locations = "project,#listreverse(application.plugins)#,core" />
		<cfelseif not len(arguments.locations)>
			<cfset arguments.locations = "project,core" />
		</cfif>
		
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

	<cffunction name="getComponents" access="public" output="false" returntype="string" hint="Returns a list of components for a package" bDocument="true">
		<cfargument name="package" type="string" required="true" />
		<cfargument name="locations" type="string" required="false" default="" />

		<cfset var item = "" />
		<cfset var list = "" />
		<cfset var qItems = querynew("name","varchar") />

		<cfif not len(arguments.locations) and structkeyexists(application,"plugins")>
			<cfset arguments.locations = "project,#listreverse(application.plugins)#,core" />
		<cfelseif not len(arguments.locations)>
			<cfset arguments.locations = "project,core" />
		</cfif>

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
						<cfif directoryexists("#application.path.plugins#/#item#/packages/#arguments.package#/")>
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

	<cffunction name="extends" access="public" output="false" returntype="boolean" hint="Returns true if the specified component extends another" bDocument="true">
		<cfargument name="desc" type="string" required="true" hint="The component to test" />
		<cfargument name="anc" type="string" required="true" hint="The ancestor to check for" />
		
		<cfset var stDesc = getMetadata(createobject("component",arguments.desc)) />
		<cfset var stAnc = getMetadata(createobject("component",arguments.anc)) />
		
		<cfloop condition="#structkeyexists(stDesc,'extends')#">
			<cfset stDesc = stDesc.extends />
			<cfif stDesc.name eq stAnc.name>
				<cfreturn true />
			</cfif>
		</cfloop>
		
		<cfreturn false />
	</cffunction>

	<cffunction name="listExtends" access="public" returntype="string" description="Returns a list of the components the specified one extends (inclusive)" output="true">
		<cfargument name="path" type="string" required="true" hint="The package path of the component" />
		
		<cfset var stMeta = getMetadata(createobject("component",arguments.path)) />
		<cfset var result = stMeta.name />
		
		<cfloop condition="structkeyexists(stMeta,'extends')">
			<cfset stMeta = stMeta.extends />
			<cfset result = listappend(result,stMeta.name) />
		</cfloop>
		
		<cfreturn result />
	</cffunction>

	<!--- MISCELLANEOUS utilities --->
	<cffunction name="fixURL" returntype="string" output="false" access="public" hint="Refreshes the page with the specified query string values removed, replaced, or added. New values can be specified with a query string, struct, or named arguments." bDocument="true">
		<cfargument name="url" type="string" required="false" default="#cgi.script_name#?#cgi.query_string#" hint="The url to use" />
		<cfargument name="removevalues" type="string" required="false" default="flushcache,bAjax,designmode,draftmode,updateapp,bShowTray,bodyView=displayBody,view=displayPageStandard,logout" hint="List of values to remove from the query string" />
		<cfargument name="addvalues" type="any" required="false" hint="A query string or a struct of values, to add to the query string" />
		
		<cfset var key = "" />
		
		<!--- Remove values --->
		<cfloop list="#arguments.removevalues#" index="key">
			<cfif find("=",key)>
				<cfset arguments.url = rereplacenocase(arguments.url,"&?#key#(&|$)","") />
			<cfelse>
				<cfset arguments.url = rereplacenocase(arguments.url,"&?#key#=[^&]+","") />
			</cfif>
		</cfloop>
		
		<!--- Add and replace values --->
		<cfif structkeyexists(arguments,"addvalues") and isstruct(arguments.addvalues)>
			<cfloop collection="#arguments.addvalues#" item="key">
				<cfset arguments.url = rereplacenocase(arguments.url,"&?#key#=[^&]+","") & "#key#=#urlencodedformat(arguments.addvalues[key])#" />
			</cfloop>
		<cfelseif structkeyexists(arguments,"addvalues")><!--- Query string format --->
			<cfloop list="#arguments.addvalues#" index="key" delimiters="&">
				<cfset arguments.url = rereplacenocase(arguments.url,"&?#listfirst(key,'=')#=[^&]+","") & "#listfirst(key,'=')#=#listlast(key,'=')#" />
			</cfloop>
		<cfelse>
			<cfloop collection="#arguments#" item="key">
				<cfif not listcontainsnocase("url,removevalues,addvalues",key)>
					<cfset arguments.url = rereplacenocase(arguments.url,"&?#key#=[^&]+","") & "#key#=#urlencodedformat(arguments.params[key])#" />
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn rereplace(replacelist(arguments.url,"?&,&&","?,&"),"[?&]$","") />
	</cffunction>

</cfcomponent>