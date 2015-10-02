<cfcomponent displayname="Utilities" hint="Packages generic utilities" output="true">

	<cffunction access="public" returntype="utils" name="init" output="false" hint="Constructor">
		<cfargument name="aJarPaths" type="array" required="no" default="#arrayNew(1)#" />
		
		<cfset var paths = arrayNew(1) />
		<cfset var theSystem = "" />
		<cfset var jvmVersion = "" /> 
		<cfset var aMajorMinor = "" />
		<cfset var arrlen = "" />
		<cfset var a = "" />
		
		<!--- This points to the jar we want to load. Could also load a directory of .class files --->
		<cfset paths[1] = expandPath("/farcry/core/packages/farcry/uuid/uuid-3.2.jar") />
		
		<cfset arrlen = arrayLen(aJarPaths) />
		<cfif arrlen>
			<cfloop from="1" to="#arrlen#" index="a">
				<cfset arrayappend(paths, expandPath(aJarPaths[a])) />
			</cfloop>
		</cfif>
		
		<!--- create the loader --->
		<cfset variables.loader = createObject(
			"component", 
			"farcry.core.packages.farcry.javaloader.JavaLoader"
		).init(paths) />
		
		<!--- get the system object so we can get the runtime version --->
		<cfset theSystem = createObject("java","java.lang.System") />
		<cfset jvmVersion = "#theSystem.getProperty('java.runtime.version')#" /> 
		<!--- split the version string into an array.  We only care about the first
			two digits --->
		<cfset aMajorMinor = listToArray(jvmVersion,".") />
		
		<cfset variables.aJVMMajorMinor = aMajorMinor />
		
		<!--- if the JVM is above 1 or above 1.5 the uuid bit will work --->
		<cfset variables.JVM1_5 = false />
		<cfif variables.aJVMMajorMinor[1] gt 1 
			or (variables.aJVMMajorMinor[1] eq 1 and variables.aJVMMajorMinor[2] gte 5)>
			<cfset variables.JVM1_5 = true />
		</cfif>
		
		
		<!--- COMBINE: Used for CSS and JS --->
		<cfset variables.oCombine = createObject("component", "farcry.core.packages.farcry.combine.combine").init(
												enableCache= true,
												cachePath= "#application.path.cache#",
												enableETags= false,
												enableJSMin= true,
												enableYuiCSS= true,
												skipMissingFiles= true,
												javaLoader= createObject("component", "farcry.core.packages.farcry.javaloader.JavaLoader"),
												jarPath= expandPath('/farcry/core/packages/farcry/combine/lib')
								) />
								
		<cfreturn this />
	</cffunction>

	<cffunction name="combine" access="public" returntype="string" output="false" hint="combines a list js or css files into a single file, which is output, and cached if caching is enabled. Returns the path to the cached file.">
		<cfargument name="id" type="string" required="false" default="ID" hint="an id that is used to prefix the combine file" />
		<cfargument name="files" type="string" required="true" hint="a delimited list of jss or css paths to combine" />
		<cfargument name="type" type="string" required="false" hint="js,css" />
		<cfargument name="delimiter" type="string" required="false" default="," hint="the delimiter used in the provided paths string" />
		<cfargument name="prepend" type="string" required="false" default="" hint="Content to be placed BEFORE all the included files" />
		<cfargument name="append" type="string" required="false" default="" hint="Content to be placed AFTER all the included files" />
				
		<cfreturn oCombine.combine(argumentCollection=arguments) />
		
	</cffunction>
	
	<cffunction name="createJavaUUID" access="public" returntype="uuid" output="false" hint="">
		<cfset var newUUID = "" />
		<cfset var oUUID = "" />
		
		<!--- We need to check the current java version and only use
			the fast UUID library if we are running verison 1.5 or 1.6. --->
		<cfif variables.JVM1_5>
			<cfset oUUID = loader.create("com.eaio.uuid.UUID") />
			
			<cfset newUUID = oUUID.init() />
			<cfset newUUID = javaUUIDtoCFUUID(newUUID) />
			
		<cfelse>
			<cfset newUUID = createUUID() />
		</cfif>
		
		<cfreturn newUUID />
	</cffunction>
	
	<cffunction name="javaUUIDtoCFUUID" returntype="uuid" access="private" output="false" hint="Most java generators generate UUIDs in a form that do not conform to CFs UUID format. This fixes them.">
		<cfargument name="sJavaUUID" required="yes">
		<cfset var newUUID = "" />
		
		<!--- reverse the uuid because we need to remove the last dash --->
		<cfset newUUID = reverse(sJavaUUID) />
		<!--- remove the first dash (which will be the last dash in the end) --->
		<cfset newUUID = replace(newUUID,"-","") />
		<!--- now upper case and reverse it back --->
		<cfset newUUID = uCase(reverse(newUUID)) />
		
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
		<cfset var item = "" />
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
		<cfset var item = "" />
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

	<!--- deprecated since ? not used any where I could find. Replace with {...} syntax --->
	<cffunction name="structCreate" returntype="struct" output="false" access="public" hint="Creates and populates a struct with the provided arguments" bDocument="false" bDeprecated="true">
		
		<cfreturn duplicate(arguments) />
	</cffunction>

	<!--- deprecated since ? not used any where I could find Replace with {...} syntax --->
	<cffunction name="struct" returntype="struct" output="false" access="public" hint="Shortcut for creating structs" bDocument="false" bDeprecated="true">
		
		<cfreturn duplicate(arguments) />
	</cffunction>

	<!--- PACKAGE utilities --->
	<cffunction name="getPath" access="public" output="false" returntype="string" hint="Finds the component in core/plugins/project, and returns its path" bDocument="true">
		<cfargument name="package" type="string" required="true" />
		<cfargument name="component" type="string" required="true" />
		<cfargument name="locations" type="string" required="false" default="" />
		<cfargument name="path" type="struct" required="false" default="#structnew()#" hint="Application file paths" />
		<cfargument name="projectDirectoryName" type="string" required="false" default="#application.projectDirectoryName#" hint="" />
		<cfargument name="scope" type="string" required="false" default="ONE" hint="ONE: return path of first matching component only. ALL: return a list of all matching paths." />
		
		<cfset var item = "" />
		<cfset var sDir = "" />
		<cfset var sPath = "" />
		<cfset var sPathList = "" />
		
		<cfif not isdefined("arguments.path.core")>
			<cfset arguments.path.core = application.path.core />
		</cfif>
		<cfif not isdefined("arguments.path.project")>
			<cfset arguments.path.project = application.path.project />
		</cfif>
		
		<cfif not len(arguments.locations) and structkeyexists(application,"plugins")>
			<cfset arguments.locations = "project,#listreverse(application.plugins)#,core" />
		<cfelseif not len(arguments.locations)>
			<cfset arguments.locations = "project,core" />
		</cfif>
		
		<cfloop list="#arguments.locations#" index="item">
			<cfswitch expression="#item#">
				<cfcase value="core">
					<cfif fileexists("#arguments.path.core#/packages/#arguments.package#/#arguments.component#.cfc")>
						<cfset sPath = "farcry.core.packages.#arguments.package#.#arguments.component#" />
					</cfif>
				</cfcase>
				<cfcase value="project">
					<cfif fileexists("#arguments.path.project#/packages/#arguments.package#/#arguments.component#.cfc")>
						<cfset sPath = "farcry.projects.#arguments.projectDirectoryName#.packages.#arguments.package#.#arguments.component#" />
					<cfelseif arguments.package eq "types" and fileexists("#arguments.path.project#/packages/system/#arguments.component#.cfc")>
						<!--- Best practice is to put extensions of core types into the system package --->
						<cfset sPath = "farcry.projects.#arguments.projectDirectoryName#.packages.system.#arguments.component#" />
					<cfelseif arguments.package eq "system" and fileexists("#arguments.path.project#/packages/types/#arguments.component#.cfc")>
						<!--- Best practice is to put extensions of core types into the system package --->
						<cfset sPath = "farcry.projects.#arguments.projectDirectoryName#.packages.types.#arguments.component#" />
					</cfif>
				</cfcase>
				<cfdefaultcase><!--- Plugin --->
					<cfif isdefined("arguments.path.plugins")>
						<cfset sDir = "#arguments.path.plugins#/#item#" />
					<cfelse>
						<cfset sDir = expandpath("/farcry/plugins/#item#") />
					</cfif>
					<cfif fileexists("#sDir#/packages/#arguments.package#/#arguments.component#.cfc")>
						<cfset sPath = "farcry.plugins.#item#.packages.#arguments.package#.#arguments.component#" />
					<cfelseif arguments.package eq "types" and fileexists("#sDir#/packages/system/#arguments.component#.cfc")>
						<!--- Best practice is to put extensions of core types into the system package --->
						<cfset sPath = "farcry.plugins.#item#.packages.system.#arguments.component#" />
					<cfelseif arguments.package eq "system" and fileexists("#sDir#/packages/types/#arguments.component#.cfc")>
						<!--- Best practice is to put extensions of core types into the system package --->
						<cfset sPath = "farcry.plugins.#item#.packages.types.#arguments.component#" />
					</cfif>
				</cfdefaultcase>
			</cfswitch>
			<cfif Len(sPath)>
				<cfif arguments.scope is "one">
					<cfreturn sPath />
				<cfelse>
					<cfset sPathList = ListAppend(sPathList, sPath) />
					<cfset sPath = "" />
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn sPathList />
	</cffunction>

	<cffunction name="getComponents" access="public" output="false" returntype="string" hint="Returns a list of components for a package" bDocument="true">
		<cfargument name="package" type="string" required="true" />
		<cfargument name="locations" type="string" required="false" default="" />
		<cfargument name="path" type="struct" required="false" default="#structnew()#" />

		<cfset var item = "" />
		<cfset var list = "" />
		<cfset var qItems = querynew("name","varchar") />
		<cfset var qItemsSystem = querynew("name","varchar") />
		<cfset var sDir = "" />
		
		<cfif not isdefined("arguments.path.core")>
			<cfset arguments.path.core = application.path.core />
		</cfif>
		<cfif not isdefined("arguments.path.project")>
			<cfset arguments.path.project = application.path.project />
		</cfif>
		
		<cfif not len(arguments.locations) and structkeyexists(application,"plugins")>
			<cfset arguments.locations = "project,#listreverse(application.plugins)#,core" />
		<cfelseif not len(arguments.locations)>
			<cfset arguments.locations = "project,core" />
		</cfif>

		<cfloop list="#arguments.locations#" index="item">
			<cfswitch expression="#item#">
				<cfcase value="core">
					<cfif directoryexists("#arguments.path.core#/packages/#arguments.package#/")>
						<cfdirectory action="list" directory="#arguments.path.core#/packages/#arguments.package#/" filter="*.cfc" name="qItems" />
					</cfif>
				</cfcase>
				<cfcase value="project">
					<cfif directoryexists("#arguments.path.project#/packages/#arguments.package#/")>
						<cfdirectory action="list" directory="#arguments.path.project#/packages/#arguments.package#/" filter="*.cfc" name="qItems" />
					</cfif>
					<cfif arguments.package eq "types" and directoryexists("#arguments.path.project#/packages/system/")>
						<cfdirectory action="list" directory="#arguments.path.project#/packages/system/" filter="*.cfc" name="qItemsSystem" />
						<cfquery dbtype="query" name="qItems">
							select	*
							from	qItems
							
							UNION
							
							select	*
							from	qItemsSystem
						</cfquery>
					</cfif>
				</cfcase>
				<cfdefaultcase><!--- Plugin --->
					<cfif isdefined("arguments.path.plugins")>
						<cfset sDir = "#arguments.path.plugins#/#item#" />
					<cfelse>
						<cfset sDir = expandpath("/farcry/plugins/#item#") />
					</cfif>
					<cfif directoryexists("#sDir#/packages/#arguments.package#/")>
						<cfdirectory action="list" directory="#sDir#/packages/#arguments.package#/" filter="*.cfc" name="qItems" />
					</cfif>
					<cfif arguments.package eq "types" and directoryexists("#sDir#/packages/system/")>
						<cfdirectory action="list" directory="#sDir#/packages/system/" filter="*.cfc" name="qItemsSystem" />
						<cfquery dbtype="query" name="qItems">
							select	*
							from	qItems
							
							UNION
							
							select	*
							from	qItemsSystem
						</cfquery>
					</cfif>
				</cfdefaultcase>
			</cfswitch>
			<cfloop query="qItems">
				<cfif not refindnocase("(^|,)#listfirst(name,'.')#($|,)",list)>
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
	
	<!--- FILE utitities --->
	<cffunction name="normaliseFileList" access="public" returntype="string" description="Turns a list of relative file paths, and a single base path, and normalises them into a single list">
		<cfargument name="baseHREF" type="string" reuired="true" hint="The base path" />
		<cfargument name="lFiles" type="string" required="true" hint="The list of relative file paths" />
		
		<cfset var result = "" />
		<cfset var thisfile = "" />
		
		<cfset arguments.baseHREF = replaceNoCase(arguments.baseHREF,"\","/","all") /><!--- Change back slashes --->
		<cfif len(arguments.baseHREF) AND right(arguments.baseHREF,1) EQ "/">
			<cfset arguments.baseHREF = mid(arguments.baseHREF,1,len(arguments.baseHREF)-1) /><!--- Remove trailing slash --->
		</cfif>
		
		<cfset arguments.lFiles = replaceNoCase(arguments.lFiles,"\","/","all") /><!--- Change back slashes --->

		<cfloop list="#arguments.lFiles#" index="thisfile">
			<cfif left(thisfile,1) NEQ "/">
				<cfset thisfile = "/#thisfile#" /><!--- add slash --->
			</cfif>
			<cfset result = listAppend(result,"#arguments.baseHREF##thisfile#") />
		</cfloop>
		
		<cfreturn result />
	</cffunction>
	
	
	<!--- MISCELLANEOUS utilities --->
	<cffunction name="fixURL" returntype="string" output="false" access="public" hint="Refreshes the page with the specified query string values removed, replaced, or added. New values can be specified with a query string, struct, or named arguments." bDocument="true">
		<cfargument name="url" type="string" required="false" default="#cgi.script_name#?#cgi.query_string#" hint="The url to use" />
		<cfargument name="removevalues" type="string" required="false" hint="List of values to remove from the query string. Prefix with '+' to remove these values in addition to the defaults." />
		<cfargument name="addvalues" type="any" required="false" hint="A query string or a struct of values, to add to the query string" />
		<cfargument name="ampDelim" type="string" required="false" default="&" hint="Delimiter to use for ampersands" />
		<cfargument name="charset" type="string" required="false" default="utf-8" hint="The character encoding in which the url values are encoded." />
		
		<cfset var key = "" />

		
		<cfif not structkeyexists(arguments,"removevalues")>
			<cfset arguments.removevalues = "furl,flushcache,bAjax,designmode,draftmode,showdraft,rebuild,updateapp,bShowTray,logout" />
		<cfelseif left(arguments.removevalues,1) eq "+">
			<cfset arguments.removevalues = "furl,flushcache,bAjax,designmode,draftmode,showdraft,rebuild,updateapp,bShowTray,logout,#mid(arguments.removevalues,2,len(arguments.removevalues))#">
		</cfif>
		
		<!--- Normalise FU --->
		<cfif findNoCase("furl=",arguments.url)>
			<cfset arguments.url = rereplacenocase(arguments.url,"^.*?/index.cfm",application.url.webroot & urldecode(rereplacenocase(arguments.url,"(.*(\?|#arguments.ampDelim#)furl\=)([^&]+)(.*)","\3"),'#charset#')) />
		</cfif>
		
		<cfif application.fc.factory.farFU.isUsingFU() AND not find("?",arguments.url) and not find(".", arguments.url) and arguments.url neq "/">
			<!--- /// --->

			<!--- Removes the required url name/value pairs --->
			<cfloop list="#arguments.removevalues#" index="key">
				<cfif find("=",key)>
					<cfset arguments.url = rereplacenocase(arguments.url,"/#replace(key,'=','/')#","") />
				<cfelse>
					<cfset arguments.url = rereplacenocase(arguments.url,"/#key#/[^/]+","") />
				</cfif>
			</cfloop>
					
		<cfelse>
			<!--- &= --->
			
			<!--- Remove values --->
			<!--- Remove empty '=' signs. eg 'x=&y=' as this screws with parsing. --->
			<cfloop condition="refind('(#arguments.ampDelim#|\?)[^=]+=($|#arguments.ampDelim#)',arguments.url)">
				<cfset arguments.url = rereplace(arguments.url,"(#arguments.ampDelim#|\?)[^=]+=($|#arguments.ampDelim#)","\1") />
			</cfloop>
			<!--- Removes the required url name/value pairs --->
			<cfloop list="#arguments.removevalues#" index="key">
				<cfif find("=",key)>
					<cfset arguments.url = rereplacenocase(arguments.url,"(#arguments.ampDelim#|\?)#key#(#arguments.ampDelim#|$)","\1") />
				<cfelse>
					<cfset arguments.url = rereplacenocase(arguments.url,"(#arguments.ampDelim#|\?)#key#=[^&]+","\1") />
				</cfif>
			</cfloop>
						
		</cfif>
		

		<!--- Add and replace values --->
		<cfif structkeyexists(arguments,"addvalues") and isstruct(arguments.addvalues)>
			<cfloop collection="#arguments.addvalues#" item="key">
				<cfset arguments.url = insertQueryVariable(url=arguments.url,key=key,value=arguments.addvalues[key],ampDelim=arguments.ampDelim,charset=charset) />
			</cfloop>
		<cfelseif structkeyexists(arguments,"addvalues")><!--- Query string format --->
			<cfloop list="#arguments.addvalues#" index="key" delimiters="&">
				<cfset arguments.url = insertQueryVariable(url=arguments.url,key=listfirst(key,'='),value=listlast(key,'='),ampDelim=arguments.ampDelim,charset=charset) />
			</cfloop>
		<cfelse>
			<cfloop collection="#arguments#" item="key">
				<cfif not listcontainsnocase("url,removevalues,addvalues,ampDelim,charset",key)>
					<cfset arguments.url = insertQueryVariable(url=arguments.url,key=key,value=arguments[key],ampDelim=arguments.ampDelim,charset=charset) />
				</cfif>
			</cfloop>
		</cfif>
	
		<cfreturn replace(rereplace(rereplace(arguments.url,"(#arguments.ampDelim#){2,}",arguments.ampDelim),"(#arguments.ampDelim#|\?)+$",""),"?#arguments.ampDelim#","?") />
	</cffunction>
	
	<cffunction name="insertQueryVariable" returntype="string" output="false" access="public" hint="Inserts the specified key and value, replacing the existing value for that key">
		<cfargument name="url" type="string" required="true" hint="The url to modify" />
		<cfargument name="key" type="string" required="true" hint="The key to insert" />
		<cfargument name="value" type="string" required="true" hint="The value to insert" />
		<cfargument name="ampDelim" type="string" required="false" default="&" hint="Delimiter to use for ampersands" />
		<cfargument name="charset" type="string" required="false" default="utf-8" hint="The character encoding in which the url values are encoded." />

		<cfset var lCharsNotAllowedInFUs = ".,"",',&,@,%,=,/,\" />
		<cfset var bAllowFriendlyUrls = true />
		<cfset var i = "" />

		<!--- In case the url value was urlencoded, application.fc.lib.esapi.DecodeFromURL it --->
		<cfset arguments.value = urlDecode(arguments.value, arguments.charset) />

		<!--- If any of the following special characters are found, don't use friendly urls here or it will fail in modern browsers that remove urlencoding for most characters (like Firefox and Chrome) --->
		<cfloop index="i" list="#lCharsNotAllowedInFUs#">
			<cfif arguments.value contains i>
				<cfset bAllowFriendlyUrls = false />
				<cfbreak />
			</cfif>
		</cfloop>
		
		<!--- now urlencode the url value --->
		<cfset arguments.value = application.fc.lib.esapi.encodeForURL(arguments.value) />

		<cfif application.fc.factory.farFU.isUsingFU() AND not find("?",arguments.url) AND not find(".",arguments.url) and arguments.url neq "/" and bAllowFriendlyUrls is true>
			<cfif refindnocase("/#arguments.key#(/|$)",arguments.url)>
				<cfset arguments.url = rereplacenocase(arguments.url,"/#arguments.key#/[^/]+","/#arguments.key#/#arguments.value#") />
			<cfelse>
				<cfset arguments.url = "#arguments.url#/#arguments.key#/#arguments.value#" />
			</cfif>
		<cfelse>
			<cfif refindnocase("(#arguments.ampDelim#)?#arguments.key#=",arguments.url)>
				<cfset arguments.url = rereplacenocase(arguments.url,"(?:#arguments.ampDelim#)?(\?)?#arguments.key#=[^&]+","\1") & "#arguments.ampDelim##arguments.key#=#arguments.value#" />
			<cfelseif find("?",arguments.url)>
				<cfset arguments.url = "#arguments.url##arguments.ampDelim##arguments.key#=#arguments.value#" />
			<cfelse>
				<cfset arguments.url = "#arguments.url#?#arguments.key#=#arguments.value#" />
		</cfif>
		</cfif>

		
		<cfreturn arguments.url />
	</cffunction>
	
	<!--- 
	* Deletes a var from a query string.
	* Idea for multiple args from Michael Stephenson (michael.stephenson@adtran.com)
	* 
	* @param variable      A variable, or a list of variables, to delete from the query string. 
	* @param qs      Query string to modify. Defaults to CGI.QUERY_STRING. 
	* @return Returns a string. 
	* @author Nathan Dintenfass (michael.stephenson@adtran.comnathan@changemedia.com) 
	* @version 1.1, February 24, 2002 
	* @version X	Refactored for FarCry
	 --->
	<cffunction name="deleteQueryVariable" returntype="string" output="false" access="public" hint="Deletes a var from a query string.">
		<cfargument name="variable" type="string" required="true" hint="The variable to remove" />
		<cfargument name="qs" type="string" required="false" default="#cgi.query_string#" />
		
	    <cfset var updatedqs = "" /><!--- var to hold the final string --->
	    <cfset var ii = 1 /><!--- vars for use in the loop, so we don't have to evaluate lists and arrays more than once --->
	    <cfset var thisVar = "" />
	    <cfset var thisIndex = "" />
	    <cfset var valuearray = listToArray(arguments.qs,"&") /><!--- put the query string into an array for easier looping --->
	    
	    <!--- now, loop over the array and rebuild the string --->
	    <cfloop from="1" to="#arrayLen(valuearray)#" index="ii">
	        <cfset thisIndex = valuearray[ii] />
	        <cfset thisVar = listFirst(thisIndex,"=") />
	        
	        <!--- if this is the var, edit it to the value, otherwise, just append --->
	        <cfif not listFindnocase(variable,thisVar)>
	            <cfset updatedqs = listAppend(updatedqs,thisIndex,"&") />
	        </cfif>
	    </cfloop>
	    
	    <cfreturn updatedqs />
	</cffunction>
	
	<!--- @@hint: 
		<p>This is a private version of the function. Do not call this function directly.
			Please use the fapi.cfc version</p>
		
		<p>Provides date formatting in the style of Twitter’s timeline: "just now", "5 minutes ago", "yesterday", "2 weeks ago".</p>
		
		@@examples:
		<code>
			#application.fapi.prettyDate(myUglyDate)# 
		</code>
	 --->
	<cffunction name="prettyDate" access="public" returntype="string" output="false">
		<cfargument name="uglyDate" required="true" type="string" default="" />
		<cfargument name="bUseTime" required="false" type="boolean" default="true" hint="Should the comparison include the time part in its equation." />
		
		
		<cfset var prettyDate = arguments.uglyDate />
		<cfset var present = now() />
		<cfset var sDiff = "" />
		<cfset var nDiff = "" />
		<cfset var hDiff = "" />
		<cfset var dDiff = "" />
		<cfset var wDiff = "" />
		<cfset var mDiff = "" />
		<cfset var yDiff = "" />
		
		<cfif not arguments.bUseTime>
			<cfset prettyDate = dateFormat(prettyDate) />
			<cfset present = dateFormat(present) />
		</cfif>
		
		<cfif isDate(arguments.uglyDate)>
			<cfif arguments.uglyDate LT present>	
				<cfset sDiff = Int(dateDiff('s',arguments.uglyDate,present)) />
				<cfset nDiff = Int(dateDiff('n',arguments.uglyDate,present)) />
				<cfset hDiff = Int(dateDiff('h',arguments.uglyDate,present)) />
				<cfset dDiff = Int(dateDiff('d',arguments.uglyDate,present)) />
				<cfset wDiff = Int(dateDiff('ww',arguments.uglyDate,present)) />
				<cfset mDiff = Int(dateDiff('m',arguments.uglyDate,present)) />
				<cfset yDiff = Int(dateDiff('yyyy',arguments.uglyDate,present)) />	
				
				<cfif sDiff LT 60>
					<cfset prettyDate = "just now" />
				<cfelseif nDiff LT 2>
					<cfset prettyDate = "#nDiff# minute ago" />
				<cfelseif hDiff LT 1>
					<cfset prettyDate = "#nDiff# minutes ago" />
				<cfelseif hDiff LT 2>
					<cfset prettyDate = "#hDiff# hour ago" />
				<cfelseif dDiff LT 1>
					<cfset prettyDate = "#hDiff# hours ago" />
				<cfelseif dDiff LT 2>
					<cfset prettyDate = "yesterday" />
				<cfelseif wDiff LT 1>
					<cfset prettyDate = "#dDiff# days ago" />
				<cfelseif wDiff LT 2>
					<cfset prettyDate = "last week" />
				<cfelseif mDiff LT 1>
					<cfset prettyDate = "#wDiff# weeks ago" />
				<cfelseif mDiff LT 2>
					<cfset prettyDate = "last month" />
				<cfelseif yDiff LT 1>
					<cfset prettyDate = "#mDiff# months ago" />
				<cfelseif yDiff LT 2>
					<cfset prettyDate = "last year" />
				<cfelse>
					<cfset prettyDate = "#yDiff# years ago" />
				</cfif>
			<cfelse>
			
				<cfset sDiff = Int(dateDiff('s',present,arguments.uglyDate)) />
				<cfset nDiff = Int(dateDiff('n',present,arguments.uglyDate)) />
				<cfset hDiff = Int(dateDiff('h',present,arguments.uglyDate)) />
				<cfset dDiff = Int(dateDiff('d',present,arguments.uglyDate)) />
				<cfset wDiff = Int(dateDiff('ww',present,arguments.uglyDate)) />
				<cfset mDiff = Int(dateDiff('m',present,arguments.uglyDate)) />
				<cfset yDiff = Int(dateDiff('yyyy',present,arguments.uglyDate)) />
				
				<cfif sDiff LT 60>
					<cfset prettyDate = "just now" />
				<cfelseif nDiff LT 2>
					<cfset prettyDate = "in #nDiff# minute" />
				<cfelseif hDiff LT 1>
					<cfset prettyDate = "in #nDiff# minutes" />
				<cfelseif hDiff LT 2>
					<cfset prettyDate = "in #hDiff# hour" />
				<cfelseif dDiff LT 1>
					<cfset prettyDate = "in #hDiff# hours" />
				<cfelseif dDiff LT 2>
					<cfset prettyDate = "tomorrow" />
				<cfelseif wDiff LT 1>
					<cfset prettyDate = "in #dDiff# days" />
				<cfelseif wDiff LT 2>
					<cfset prettyDate = "next week" />
				<cfelseif mDiff LT 1>
					<cfset prettyDate = "in #wDiff# weeks" />
				<cfelseif mDiff LT 2>
					<cfset prettyDate = "next month" />
				<cfelseif yDiff LT 1>
					<cfset prettyDate = "in #mDiff# months" />
				<cfelseif yDiff LT 2>
					<cfset prettyDate = "next year" />
				<cfelse>
					<cfset prettyDate = "in #yDiff# years" />
				</cfif>	
			</cfif>
		</cfif>
		
		<cfreturn prettyDate />
	</cffunction>

	<!--- @@hint: 
		<p>This function is used to build an array of items from a set of defaults, and 
			also a string of commands to add or subtract items form the default.  For
			example, core defines a list of internet spider user agents ("google,slurp,meany,java"),
			and you may want to use all of them except "java" and also add two called
			"blarg" and "yuck".  You can do that with this function like so:	
		 </p>
		
		<p>
			arrayFromStringCommands("google,slurp,meany,java", "*:-java,+blarg,yuck")
		</p>
		
		<p>
			Currently, this function is only used for the above mentioned example, however
			it might be useful in the future to allow plugins to be added and removed
			at runtime.
		</p>
		
		<p>
			This function is defined in Application.cfc because it is used on FarCry
			init.  It is here (utils.cfc) for Unit testing, and the possibility of 
			future use.
		</p>
		
		@@examples:
		<code>
			#application.fapi.plusMinusStateMachine(myUglyDate)# 
		</code>
	 --->
	<cffunction name="arrayFromStringCommands" access="public" returntype="array" output="false">
		<cfargument name="asteriskDefaults" type="string" required="true" />
		<cfargument name="stateCommandString" type="string" required="true" />
		
		<!--- This function is needed on application startup, and as such is defined in 
			the cores version of Application.cfc. --->
		<cfreturn request.__plusMinusStateMachine(
												  arguments.asteriskDefaults, 
												  arguments.stateCommandString) />
		
	</cffunction>
	
	<cffunction name="generateRandomString" access="public" returntype="string" output="false" hint="Generate a very-hard-to-predict 40-character string">
		<cfargument name="seed" type="string" default="" hint="An optional random-looking string (like a UUID) to add a few more bits of randomness" />
		
		<cfset var source = "" />
		<cfset var randomHex = "" />
		<cfset var i = 0 />
		
		<!--- Generate a "securely pseudo-random" 12-digit hex string (roughly 48 bits of entropy) --->
		<cfloop index="i" from="1" to="3">
			<cfset randomHex = FormatBaseN(RandRange(0, 65535, "SHA1PRNG"), 16) />
			<cfset source = source & Right("000" & randomHex, 4) />
		</cfloop>
		
		<!--- Append the seed string --->
		<cfset source = source & arguments.seed />
		
		<!--- Hash and truncate the source to get a 40-digit hex string (48 bits of entropy hiding in 160 bits of hex data) --->
		<cfreturn UCase(Left(Hash(source, "SHA-256"), 40)) />
	</cffunction>
	
	<cffunction name="isGeneratedRandomString" access="public" returntype="boolean" output="false" hint="Return true if the given string looks like it came from generateRandomString()">
		<cfargument name="testString" type="string" required="true" />
		
		<cfreturn REFindNoCase("^[0-9a-f]{40}$",arguments.testString) />
	</cffunction>
	

</cfcomponent>