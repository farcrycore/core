<cfcomponent name="coapiadmin" bDocument="true" scopelocation="application.coapi.coapiadmin">


<cffunction name="init" access="public" output="false" hint="Initialise component." returntype="coapiadmin">

	<cfset variables.qIncludedObjects = initializeIncludes() />
	<cfset this.qIncludedObjects = variables.qIncludedObjects />
	
	<cfset variables.stWebskinDetails = structNew() />
	
	<cfreturn this />

</cffunction>

<cffunction name="getCOAPIComponents" access="public" output="false" returntype="query" hint="Get query of COAPI components by package directory." bDocument="true">
	<cfargument name="project" required="true" type="string" />
	<cfargument name="package" required="true" type="string" />
	<cfargument name="plugins" default="" type="string" />
	
	<cfset var qResult=queryNew("ATTRIBUTES, DATELASTMODIFIED, DIRECTORY, MODE, NAME, SIZE, TYPE, typepath") />
	<cfset var qComps=queryNew("blah") />
	<cfset var qDupe=queryNew("blah") />
	<cfset var lDir=arguments.plugins />
	<cfset var packagedir = "" />
	<cfset var packagepath = "" />
	<cfset var typepath = "" />
	<cfset var col = "" />
	
	
	<!--- 
	must go in reverse order
	- project
	- reverse library
	- core
	--->
	
	<cfset ldir=listprepend(ldir, "projectpackage") />
	<cfset ldir=listappend(ldir, "corepackage") />
	
	<cfloop list="#lDir#" index="packagedir">

		<!--- get directory listing of components --->
		<cfif packagedir eq "projectpackage">
			<cfset packagepath=expandpath("/farcry/projects/#arguments.project#/packages/#arguments.package#") />
			<cfset typepath="farcry.projects.#arguments.project#.packages.#arguments.package#" />
			<cfif directoryExists(packagepath)>
				<cfdirectory directory="#packagepath#" name="qComps" filter="*.cfc" sort="name" listinfo="name" />
				<!--- <cfdump var="#qcomps#" label="project: #packagepath#../../packages/#arguments.package#"> --->
			</cfif>
		<cfelseif packagedir eq "corepackage">
			<cfset packagepath=expandpath("/farcry/core/packages/#arguments.package#") />
			<cfset typepath="farcry.core.packages.#arguments.package#" />
			<cfif directoryExists(packagepath)>
				<cfdirectory directory="#packagepath#" name="qComps" filter="*.cfc" sort="name" listinfo="name" />
				<!--- <cfdump var="#qcomps#" label="core: #packagepath##arguments.package#"> --->
			</cfif>
		<cfelse>
			<cfset packagepath=ExpandPath("/farcry/plugins/#packagedir#/packages/#arguments.package#") />
			<cfset typepath="farcry.plugins.#packagedir#.packages.#arguments.package#" />
			<cfif directoryExists(packagepath)>
				<cfdirectory action="list" directory="#packagepath#" filter="*.cfc" name="qComps" sort="name" listinfo="name" />
				<!--- <cfdump var="#qcomps#" label="#packagedir#: #packagepath#"> --->
			</cfif>
		</cfif>

		<cfloop query="qComps">
			<cfquery dbtype="query" name="qDupe">
			SELECT * FROM qResult
			WHERE name = '#qComps.name#'
			</cfquery>
			
			<cfif NOT qDupe.Recordcount>
				<cfset queryaddrow(qresult,1) />
				<cfloop list="#qComps.columnlist#" index="col">
					<cfset querysetcell(qresult, col, qComps[col][qcomps.currentrow]) />
				</cfloop>
				<!--- additional type specific information --->
				<cfset querysetcell(qresult, "typepath", typepath & "." & listfirst(qComps.name, ".")) />
			</cfif>
		</cfloop>

	</cfloop>

	<cfquery dbtype="query" name="qResult">
	SELECT * FROM qResult
	ORDER BY name
	</cfquery>

	<cfreturn qResult />

</cffunction>


<cffunction name="getPluginInstallers" access="public" output="false" returntype="query" hint="Get query of library install files. Install files limitd to CFM includes.">
	<cfargument name="plugins" required="true" type="string" hint="List of farcry libraries to process." />

	<cfset var qResult=querynew("ATTRIBUTES, DATELASTMODIFIED, DIRECTORY, MODE, NAME, SIZE, TYPE, library") />
	<cfset var qInstalls=querynew("ATTRIBUTES, DATELASTMODIFIED, DIRECTORY, MODE, NAME, SIZE, TYPE, library") />
	<cfset var installdir="" />
	<cfset var aCol=arrayNew(1) />
	<cfset var pluginName="" />
	<cfset var i="" />

	<cfloop list="#arguments.plugins#" index="pluginName">
		<cfset installdir=expandpath("/farcry/plugins/#pluginName#/config/install") />
		<cfif directoryexists(installdir)>
			<cfdirectory action="list" directory="#installdir#" filter="*.cfm" name="qInstalls" sort="asc" />
			
			<cfif qinstalls.recordcount>
				<cfset aCol=arrayNew(1) />
				<cfloop from="1" to="#qinstalls.recordcount#" index="i">
					<cfset arrayAppend(acol, pluginName) />
				</cfloop>
				<cfset queryAddColumn(qinstalls, "plugin", aCol) />
				
				<cfquery dbtype="query" name="qResult">
					SELECT * FROM qinstalls
					<cfif qResult.recordcount>
					UNION
					SELECT * FROM qResult
					</cfif>
				</cfquery>
			</cfif>
		
		</cfif>
	</cfloop>

	<cfreturn qResult />
</cffunction>

<cffunction name="getExtendedTypeArray" access="public" output="false" hint="Initialise component." returntype="array">
	<cfargument name="packagePath" required="true">
	
	<cfset var md = getMetaData(createObject("component", arguments.packagePath)) />
	<cfset var aExtends = arrayNew(1) />
	<cfset var extendedMD = "">
	<cfset var extendedTypeName = "" />
	<cfset var bFourQ = false />
	
	<cfif structKeyExists(md, "extends")>
		
		<cfset extendedMD = md.extends>
		<cfset extendedTypeName = extendedMD.name />
		
		<!--- Loop through the type extends heirachy until we hit fourq --->
		<cfloop condition="NOT bFourQ">
			<cfif extendedTypeName EQ 'farcry.core.packages.fourq.fourq'>
				<cfset bFourQ = true />
			</cfif>
			
			<cfset arrayAppend(aExtends, listLast(extendedTypeName , ".")) />
			
			<cfif structKeyExists(extendedMD, "extends") AND structKeyExists(extendedMD.extends, "name")>		
				
				<cfset extendedMD = extendedMD.extends>				
				<cfset extendedTypeName = extendedMD.name />
			<cfelse>
				<cfbreak />
			</cfif>
		</cfloop>
	</cfif>
	
	<cfreturn aExtends />
</cffunction>


	<cffunction name="setupProjectDirectorys" returntype="void" access="public" output="false" hint="sets up a query containing ALL webskins available to the project">
		
		<cfset var fapi = createobject("component","farcry.core.packages.lib.fapi") />
		<cfset var qResult="" />
		<cfset var webskinid = 0 />
		<cfset var WebskinFilePath = "" />
		<cfset var stWebskinDetails = structNew() />
		<cfset var webskins = "" />
		<cfset var qThis = "" />
		<cfset var thisvar = "" />
		<cfset var webskinpath = "" />
		<cfset var webskinrel = "" />
		<cfset var pluginName = "" />
		<cfset var stWebskinMetadata = "" />
		<cfset var qSummary = "" />

		<cfset var thisFile = "" />
		<cfset var thisTypename = "" />
		<cfset var thisFileParentDirectory = "" />
		
				
		<cfif not structKeyExists(request.fc, "stProjectDirectorys")>
			<!--- Generate the webskin report for this type if it isn't already in request --->
			
		
	
			<cfset request.fc.stProjectDirectorys = structNew() />
			<cfset request.fc.stWebskins = structnew() />
			
			<cfset request.stPluginDirectorys = structNew() />
			<cfparam name="application.plugins" default="" />
			<cfloop list="project,#fapi.listReverse(list='#application.plugins#')#,core" index="pluginName">
				
				<!--- Find the webskin path for the source --->
				<cfswitch expression="#pluginName#">
					<cfcase value="project">
						<cfset webskinrel = "/farcry/projects/#application.projectDirectoryName#/webskin" />
					</cfcase>
					
					<cfcase value="core">
						<cfset webskinrel = "/farcry/core/webskin" />
					</cfcase>
					
					<cfdefaultcase><!--- A plugin --->
						<cfset webskinrel = "/farcry/plugins/#pluginName#/webskin" />
					</cfdefaultcase>
				</cfswitch>
				
				<!--- Get all webskins --->
				<cfset webskinpath = replaceNoCase(expandPath(webskinrel),"\","/","all") />
				<cfdirectory action="list" directory="#webskinpath#" filter="*.cfm" name="qThis" recurse="true" listinfo="name" />

				<!--- Add extra columns to query --->
				<cfquery dbtype="query" name="qThis">
					SELECT 	<!--- from cfdirectory --->
							*, 
							'' AS directory,
							
							<!--- derived from cfdirectory right now --->
							'' as typename, '' as webskin, cast(0 as integer) as id, '' as path, 
							
							<!--- extracted from webkin later --->
							'anonymous' as author, '' as description, name as displayname, 0 as cacheStatus, 0 as cacheTimeout, -1 as browserCacheTimeout, -1 as proxyCacheTimeout, 0 as cacheByURL, 0 as cacheFlushOnFormPost, 0 as cacheByForm, 0 as cacheByRoles, '' as cacheByVars, '' as cacheTypeWatch, 0 as cacheFlushOnObjectChange, name as methodname, '' as fuAlias, '' as viewstack, '' as viewbinding, '' as allowredirect
							
					FROM 	qThis
				</cfquery>
				<cfloop query="qThis">
					<cfif listLen(qThis.name, "/\") eq 2>
						<cfset webskinID = webskinID + 1 />

						<cfset thisFile = listLast(qThis.name,"/\")>
						<cfset thisTypename = listFirst(qThis.name,"/\")>
						<cfset thisFileParentDirectory = "#webskinpath#/#thisTypename#">

						<cfset querysetcell(qThis, 'id', webskinID, qThis.currentRow) />		
						<cfset querysetcell(qThis, 'directory', thisFileParentDirectory, qThis.currentRow) />		
						<cfset querysetcell(qThis, 'typename', thisTypename, qThis.currentRow) />		
						<cfset querysetcell(qThis, 'webskin', "/#thisTypename#/#thisFile#", qThis.currentRow) />	
						<cfset querysetcell(qThis, 'methodname', thisFile, qThis.currentRow) />	
						<cfset querysetcell(qThis, 'path', "#webskinrel#/#thisTypename#", qThis.currentRow) />
						<cfset querysetcell(qThis, 'name', thisFile, qThis.currentRow) />

					<cfelse>
						<cfset querysetcell(qThis, 'id', -1, qThis.currentRow) />
					</cfif>
				</cfloop>
				<cfquery dbtype="query" name="qThis">
					SELECT * FROM qThis WHERE id>-1
				</cfquery>

				<!--- Add new webskins to summary --->
				<cfif isdefined("request.fc.stProjectDirectorys.qAll") and request.fc.stProjectDirectorys.qAll.recordcount>
					<cfquery dbtype="query" name="request.fc.stProjectDirectorys.qAll">
						SELECT 	* 
						FROM 	request.fc.stProjectDirectorys.qAll
						
						UNION
						
						SELECT 	* 
						FROM 	qThis
						WHERE	webskin not in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#valuelist(request.fc.stProjectDirectorys.qAll.webskin)#" />)
					</cfquery>
				<cfelse>
					<cfset request.fc.stProjectDirectorys.qAll = qThis />
				</cfif>


				<!--- I don't think this get's used, but I'm leaving it until I can test properly --->
				<cfset request.fc.stProjectDirectorys["q#pluginname#"] = qThis />
			</cfloop>
			
			
			<!--- Set up paths --->
			<cfset request.pluginPath=replaceNoCase(ExpandPath('/farcry/plugins'),"\","/","all") />	
			<cfset request.corePath=replaceNoCase(ExpandPath('/farcry/core'),"\","/","all") />	
			<cfset request.projectPath=replaceNoCase(ExpandPath('/farcry/projects'),"\","/","all") />	
			<cfset request.sortedPlugins = fapi.listReverse(list='#application.plugins#') />
			
			
			<cfloop query="request.fc.stProjectDirectorys.qAll">				
				
				<!--- SETUP THE METADATA INFO --->
				<cfset stWebskinDetails = structNew() />
				<cfset stWebskinDetails.path = "#request.fc.stProjectDirectorys.qAll.path#/#request.fc.stProjectDirectorys.qAll.name#" />
				<cfset stWebskinDetails.methodname = ReplaceNoCase(request.fc.stProjectDirectorys.qAll.name, '.cfm', '','ALL') />
				
				<!--- DYNAMIC DEFAULTS --->
				<cfif refind("^displayPage",stWebskinDetails.methodname)>
					<cfset stWebskinDetails.viewstack = "page" />
					<cfset stWebskinDetails.viewbinding = "any" />
				<cfelseif refind("^displayBody",stWebskinDetails.methodname) or refind("^edit",stWebskinDetails.methodname)>
					<cfset stWebskinDetails.viewstack = "body" />
					<cfset stWebskinDetails.viewbinding = "object" />
				<cfelseif refind("^displayTypeBody",stWebskinDetails.methodname)>
					<cfset stWebskinDetails.viewstack = "body" />
					<cfset stWebskinDetails.viewbinding = "type" />
				<cfelseif refind("^displayType",stWebskinDetails.methodname)>
					<cfset stWebskinDetails.viewstack = "any" />
					<cfset stWebskinDetails.viewbinding = "type" />
				<cfelse>
					<cfset stWebskinDetails.viewstack = "any" />
					<cfset stWebskinDetails.viewbinding = "any" />
				</cfif>
				
				<!--- Parse the webskin for the metadata --->
				<cfset stWebskinMetadata = parseWebskinMetadata(
						typename=request.fc.stProjectDirectorys.qAll.typename, 
						template=stWebskinDetails.methodname, 
						path=stWebskinDetails.path, 
						lProperties="displayname,author,description,cacheStatus,cacheTimeout,browserCacheTimeout,proxyCacheTimeout,cacheByURL,cacheFlushOnFormPost,cacheByForm,cacheByRoles,cacheByVars,cacheTypeWatch,cacheFlushOnObjectChange,fuAlias,viewstack,viewbinding,allowredirect", 
						lTypes="string,string,string,numeric,numeric,numeric,numeric,boolean,boolean,boolean,boolean,string,string,boolean,string,string,string,boolean", 
						lDefaults=" , , ,0,#application.defaultWebskinCacheTimeout#,-1,-1,false,false,false,false, , ,false, ,#stWebskinDetails.viewstack#,#stWebskinDetails.viewbinding#,1"
					) />
				
				<!--- Assign the metadata --->
				<cfset structappend(stWebskinDetails,stWebskinMetadata,true) />
				<cfparam name="request.fc.stWebskins.#request.fc.stProjectDirectorys.qAll.typename#" default="#structnew()#" />
				<cfset request.fc.stWebskins[request.fc.stProjectDirectorys.qAll.typename][stWebskinDetails.methodname] = stWebskinDetails />
				
				<!--- UPDATE THE METADATA QUERY --->
				<cfloop list="path,methodname,displayname,author,description,cacheStatus,cacheTimeout,browserCacheTimeout,proxyCacheTimeout,cacheByURL,cacheFlushOnFormPost,cacheByForm,cacheByRoles,cacheByVars,cacheTypeWatch,cacheFlushOnObjectChange,fuAlias,viewstack,viewbinding,allowredirect" index="thisvar">
					<cfset querysetcell(request.fc.stProjectDirectorys.qAll,thisvar,stWebskinDetails[thisvar],request.fc.stProjectDirectorys.qAll.currentRow) />	
				</cfloop>
			</cfloop>
				
		</cfif>
		
	</cffunction>

	<cffunction name="getWebskins" returntype="query" access="public" output="false" hint="Returns a query of all available webskins. Search through project first, then any library's that have been included.">
		<cfargument name="typename" type="string" default="#gettablename()#" hint="Typename of instance." />
		<cfargument name="prefix" type="string" required="false" default="" hint="Prefix to filter template results." />
		<cfargument name="bForceRefresh" type="boolean" required="false" default="false" hint="Force to reload and not use application scope." />
		<cfargument name="excludeWebskins" type="string" required="false" default="" hint="Allows developers to exclude webskins that might be contained in plugins." />
		<cfargument name="packagePath" type="string" required="false" hint="The path to the type." />
		<cfargument name="aExtends" type="array" required="false" hint="The components this type extends" />
		<cfargument name="viewBinding" type="string" required="false" default="" /><!--- type,object --->
		<cfargument name="viewStack" type="string" required="false" default="" /><!--- page,body,fragment --->
		
		<cfset var qResult="" />
		<cfset var webskinid = 0 />
		<cfset var WebskinFilePath = "" />
		<cfset var stWebskinDetails = structNew() />
		<cfset var webskins = "" />
		<cfset var qThis = "" />
		<cfset var thisvar = "" />
		<cfset var webskinpath = "" />
		<cfset var webskinrel = "" />
		<cfset var i = "" />
				
		
		<!--- If the webskins are available from the application or request scope, just use those --->
		<cfif not bForceRefresh AND isdefined("application.stcoapi.#arguments.typename#.qWebskins")>
			<cfset qResult = application.stcoapi[arguments.typename].qWebskins />
		<cfelseif isdefined("request.fc.stcoapiWebskins.#arguments.typename#.qWebskins")>
			<cfset qResult = request.fc.stcoapiWebskins[arguments.typename].qWebskins />
		</cfif>
		
		<cfif isquery(qResult)>
			
			<cfquery dbtype="query" name="qResult">
			SELECT *
			FROM qResult
			WHERE 1 = 1
			<cfif len(arguments.prefix)>
				AND lower(qResult.name) LIKE '#lCase(arguments.prefix)#%'
			</cfif>
			<cfif len(arguments.viewBinding)>
				AND viewBinding = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.viewBinding#" />
			</cfif>
			<cfif len(arguments.viewStack)>
				AND viewStack = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.viewStack#" />
			</cfif>
			</cfquery>
	
			<cfreturn qResult />
		</cfif>
		
		
		<!--- 
		CACHING IN THE REQUEST SCOPE
		WE ONLY WANT THIS TO BE RUN ONCE PER TYPE PER REQUEST AT THE MOST.		
		THIS IS OFTEN THE CASE FOR ABSTRACT TYPES THAT ARE EXTENDED BY MULTIPLE TYPES.
		IN THIS CASE, ANY FILTERING OPTIONS PASSED IN (prefix,viewBinding,viewStack) AS ARGUMENTS WILL BE IGNORED.
		 --->		
		<cfparam name="request.fc.stcoapiWebskins" default="#structNew()#" />
		<cfparam name="request.fc.stcoapiWebskins.#arguments.typename#" default="#structNew()#" />
		<cfparam name="request.fc.stWebskins" default="#structnew()#" />
		
		<!--- INITIALIZE PROJECT DIRECTORIES IF REQUIRED --->
		<cfset setupProjectDirectorys() />
		
		
		<!--- The ancestor components are used later. Make sure they're available. --->
		<cfif not structkeyexists(arguments,"aExtends") and structkeyexists(arguments,"packagepath")>
			<cfset arguments.aExtends = getExtendedTypeArray(packagePath=arguments.packagepath) />
		</cfif>
		<cfset arrayPrepend(arguments.aExtends, arguments.typename) />

		
		<!--- Loop through ancestors in order of precedence, only adding webskins that have not already been defined --->
		<cfloop from="1" to="#arrayLen(aExtends)#" index="i">
			<cfparam name="request.fc.stWebskins.#arguments.typename#" default="#structnew()#" />
			<cfparam name="request.fc.stWebskins.#lcase(aExtends[i])#" default="#structnew()#" />
			<cfset structappend(request.fc.stWebskins[arguments.typename],request.fc.stWebskins[lcase(aExtends[i])],false) />
			
			<cfif isquery(qResult) and qResult.recordcount>
				<!--- Some webskins have been retrieved already, merge in any new ones defined for this ancestor --->
				<cfquery dbtype="query" name="qResult">
					select		*
					from		qResult
					
					UNION
					
					SELECT 		*
					FROM 		request.fc.stProjectDirectorys.qAll
					WHERE 		lower(typename) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(aExtends[i])#" />
								AND name NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#valuelist(qResult.name)#" />)
								<cfif listLen(arguments.excludeWebskins)>
									AND lower(methodname) NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lCase(arguments.excludeWebskins)#" />)
								</cfif>
				</cfquery>
			<cfelse>
				<!--- This is probably the type itself - these are the webskins with the most precedence --->
				<cfquery dbtype="query" name="qResult">
					SELECT 		*
					FROM 		request.fc.stProjectDirectorys.qAll
					WHERE 		lower(typename) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#lcase(aExtends[i])#" />
								<cfif listLen(arguments.excludeWebskins)>
									AND lower(methodname) NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lCase(arguments.excludeWebskins)#" />)
								</cfif>
				</cfquery>
			</cfif>
		</cfloop>

		<!--- 
		PLACE IT IN THE REQUEST SCOPE JUST INCASE WE NEED THIS AGAIN THIS REQUEST.
		 --->
		<cfset request.fc.stcoapiWebskins[arguments.typename].qWebskins = qresult />
		
		

		<cfreturn qresult />
	</cffunction>

	<cffunction name="getWebskin" returntype="struct" access="public" output="false" hint="Returns the webskins struct for a webskin specified by methodname">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="webskin" type="string" required="true" hint="methodname" />
		
		<cfif len(arguments.typename) gt 0 AND isdefined("application.stCOAPI.#arguments.typename#.stWebskins.#arguments.webskin#")>
			<cfreturn application.stCOAPI[arguments.typename].stWebskins[arguments.webskin] />
		<cfelse><!--- Not found --->
			<cfreturn structnew() />
		</cfif>
	</cffunction>

	<cffunction name="getWebskinPath" returntype="string" access="public" output="false" hint="Returns the path to a webskin. Search through project first, then any library's that have been included.">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="template" type="string" required="true" />
		
		<cfset var webskinPath = "" />
		<cfset var qWebskinMetadata = queryNew("blah") />
		<cfset var qWebskinPath = queryNew("blah") />
		<cfset var plugin = "" />
	
		<!--- If the webskin is in the application.stcoapi then just use it --->
		<cfif structKeyExists(application.stcoapi, typename)
			AND structKeyExists(application.stcoapi[typename], "stWebskins") 
			AND structKeyExists(application.stcoapi[typename].stWebskins, template) 
			AND structKeyExists(application.stcoapi[typename].stWebskins[template], "path")>
			<cfset webskinPath = application.stcoapi[arguments.typename].stWebskins[arguments.template].path />
		<cfelse>
		
			<cfif fileExists("#application.path.project#/webskin/#arguments.typename#/#arguments.template#.cfm")>
				
				<cfset webskinPath = "/farcry/projects/#application.projectDirectoryName#/webskin/#arguments.typename#/#arguments.template#.cfm" />
				
			<cfelseif structKeyExists(application, "plugins") and listLen(application.plugins)>
	
				<cfloop list="#application.plugins#" index="plugin">
					
					<cfif fileExists(ExpandPath("/farcry/plugins/#plugin#/webskin/#arguments.typename#/#arguments.template#.cfm"))>
					
						<cfset webskinPath = "/farcry/plugins/#plugin#/webskin/#arguments.typename#/#arguments.template#.cfm" />
					</cfif>	
					
				</cfloop>
				
			</cfif>
			
			<!--- If it hasnt been found yet, check in core. --->
			<cfif not len(webskinPath) AND fileExists(ExpandPath("/farcry/core/webskin/#arguments.typename#/#arguments.template#.cfm"))>
				<cfset webskinPath = "/farcry/core/webskin/#arguments.typename#/#arguments.template#.cfm" />
			<cfelse>
				<cflog file="coapi" text="Unable to locate webskin [#arguments.template#] for typename [#arguments.typename#]">
			</cfif>
		</cfif>
		
		<cfreturn webskinPath>
		
	</cffunction>
	

	<cffunction name="parseWebskinMetadata" returntype="struct" access="public" output="false" hint="Returns a struct of the metadata for all requested property metadata in a webskin">
		<cfargument name="typename" type="string" required="false" />
		<cfargument name="template" type="string" required="false" />
		<cfargument name="path" type="string" required="false" />
		<cfargument name="lProperties" type="string" required="true" />
		<cfargument name="lTypes" type="string" required="false" default="" />
		<cfargument name="lDefaults" type="string" required="false" default="" />
		
		<cfset var templateCode = "" />
		<cfset var i = "" />		
		<cfset var stResult = structNew() />
		<cfset var thisvar = "" />
		<cfset var thistype = "" />
		<cfset var thisdefault = "" />
		<cfset var matcher = "" />
		<cfset var start = 1 />
		
		<cfif not structkeyexists(this,"commentVariableRegex")>
			<cfset this.commentVariableRegex = createObject( "java", "java.util.regex.Pattern" ).compile(javaCast( "string", "@@(\w+):(.*?)(?:--->|@@)" )) />
		</cfif>
		
		<!--- Check that the webskin can be used as a variable name --->
		<cfif not isValid("variablename",template)>
			<cfthrow 	message="Invalid webskin filename (#path#)."
						detail=" FarCry webskin names must adhere to the standard ColdFusion variable naming conventions. For example, no spaces in filename." />
		</cfif>
		
		<!--- Figure out the file path of the webskin --->
		<cfif NOT structKeyExists(arguments, "path")>
			<cfif len(arguments.typename) AND len(arguments.template)>
				<cfset arguments.path = getWebskinPath(typename=arguments.typename, template=arguments.template) />
			<cfelse>
				<cfthrow type="Application" detail="Error: [parseWebskinMetadata] You must pass in a path or both the typename and template, #arguments.toString()#" />	
			</cfif>
		</cfif>
		
		<!--- Load file --->
		<cfif len(arguments.path) and fileExists(Expandpath(arguments.path))>
			<cffile action="READ" file="#Expandpath(arguments.path)#" variable="templateCode">
		<cfelse>
			<cfthrow type="Application" detail="Error: [parseWebskinMetadata] Webskin file does not exist, #arguments.toString()#" />
		</cfif>
		
		<!--- Find and extract every "@@variable: value" pair --->
		<cfset matcher = this.commentVariableRegex.matcher(javaCast( "string", templateCode )) />
		<cfloop condition="matcher.find()">
			<cfset stResult[trim(matcher.group(javaCast( "int", 1 )))] = trim(matcher.group(javaCast( "int", 2 ))) />
		</cfloop>
		
		<!--- Apply defaults and validate types --->
		<cfloop from="1" to="#listlen(arguments.lProperties)#" index="i">
			<cfset thisvar = listgetat(arguments.lProperties,i) />
			
			<!--- Get this property's type --->
			<cfif listlen(arguments.lTypes) lt i>
				<cfset thistype = "string" />
			<cfelse>
				<cfset thistype = listgetat(arguments.lTypes,i) />
			</cfif>
			
			<!--- Get the default for this property --->
			<cfif listlen(arguments.lDefaults) lt i>
				<cfset thisdefault = "" />
			<cfelse>
				<cfset thisdefault = listgetat(arguments.lDefaults,i) />
			</cfif>
			
			<cfif not structKeyExists(stResult, thisvar) or not isvalid(thistype,stResult[thisvar])>
				<!--- If the variable wasn't found or was invalid, set it to the provided default --->
				<cfset stResult[thisvar] = trim(thisdefault) />
			</cfif>
		</cfloop>		
			
		<cfreturn stResult />
	</cffunction>	
		
	<cffunction name="getWebskinCacheStatus" returntype="string" access="public" output="false" hint="Returns the objectbroker cache status of a webskin. Status can be -1:force ancestors to not cache, 0:do not cache, 1:cache">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="template" type="string" required="true" />
		<cfargument name="path" type="string" required="false" />
		<cfargument name="defaultStatus" type="numeric" default="0" required="false" />
		
		<cfset var result = "" />
		<cfset var templateCode = "" />
		<cfset var pos = "" />	
		<cfset var count = "" />		
		
		<cfif structKeyExists(application.stcoapi, typename)
			AND structKeyExists(application.stcoapi[typename], "stWebskins") 
			AND structKeyExists(application.stcoapi[typename].stWebskins, template) 
			AND structKeyExists(application.stcoapi[typename].stWebskins[template], "cacheStatus")>
			<cfset result = application.stcoapi['#typename#'].stWebskins['#template#'].cacheStatus />

		</cfif>
		
		<cfif result NEQ -1 AND result NEQ 0 AND result NEQ 1>
			<cfset result = arguments.defaultStatus />
		</cfif>
		
		<cfreturn result />
		
	</cffunction>
		
	<cffunction name="getWebskinCacheTimeOut" returntype="string" access="public" output="false" hint="Returns the objectbroker timeout value of a webskin. A result of 0 will FORCE any ancestor webskins to NEVER cache. The default value is the objectBrokerWebskinCacheTimeout value set in the type cfc which defaults to 1400 minutes">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="template" type="string" required="true" />
		<cfargument name="path" type="string" required="false" />
		<cfargument name="defaultTimeOut" type="numeric" default="#application.defaultWebskinCacheTimeout#" required="false" />
		
		<cfset var result = "" />
		<cfset var templateCode = "" />
		<cfset var pos = "" />	
		<cfset var count = "" />		
		
		<cfif structKeyExists(application.stcoapi, typename)
			AND structKeyExists(application.stcoapi[typename], "stWebskins") 
			AND structKeyExists(application.stcoapi[typename].stWebskins, template) 
			AND structKeyExists(application.stcoapi[typename].stWebskins[template], "cacheTimeout")>
			<cfset result = application.stcoapi['#typename#'].stWebskins['#template#'].cacheTimeout />

		</cfif>
			
		<cfif not isNumeric(result)>
	 		<cfset result = arguments.defaultTimeOut />
		</cfif>
			
		<cfreturn result />
		
	</cffunction>
		
	<cffunction name="getBrowserCacheTimeOut" returntype="string" access="public" output="false" hint="Returns the objectbroker timeout value of a webskin. A result of 0 will FORCE any ancestor webskins to NEVER cache. The default value is the objectBrokerWebskinCacheTimeout value set in the type cfc which defaults to 1400 minutes">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="template" type="string" required="true" />
		<cfargument name="path" type="string" required="false" />
		<cfargument name="defaultTimeOut" type="numeric" default="-1" required="false" />
		
		<cfset var result = "" />
		<cfset var templateCode = "" />
		<cfset var pos = "" />	
		<cfset var count = "" />		
		
		<cfif structKeyExists(application.stcoapi, typename)
			AND structKeyExists(application.stcoapi[typename], "stWebskins") 
			AND structKeyExists(application.stcoapi[typename].stWebskins, template) 
			AND structKeyExists(application.stcoapi[typename].stWebskins[template], "browserCacheTimeout")>
			<cfset result = application.stcoapi['#typename#'].stWebskins['#template#'].browserCacheTimeout />

		</cfif>
			
		<cfif not isNumeric(result)>
	 		<cfset result = arguments.defaultTimeOut />
		</cfif>
			
		<cfreturn result />
		
	</cffunction>
		
	<cffunction name="getProxyCacheTimeOut" returntype="string" access="public" output="false" hint="Returns the objectbroker timeout value of a webskin. A result of 0 will FORCE any ancestor webskins to NEVER cache. The default value is the objectBrokerWebskinCacheTimeout value set in the type cfc which defaults to 1400 minutes">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="template" type="string" required="true" />
		<cfargument name="path" type="string" required="false" />
		<cfargument name="defaultTimeOut" type="numeric" default="-1" required="false" />
		
		<cfset var result = "" />
		<cfset var templateCode = "" />
		<cfset var pos = "" />	
		<cfset var count = "" />		
		
		<cfif structKeyExists(application.stcoapi, typename)
			AND structKeyExists(application.stcoapi[typename], "stWebskins") 
			AND structKeyExists(application.stcoapi[typename].stWebskins, template) 
			AND structKeyExists(application.stcoapi[typename].stWebskins[template], "proxyCacheTimeout")>
			<cfset result = application.stcoapi['#typename#'].stWebskins['#template#'].proxyCacheTimeout />

		</cfif>
			
		<cfif not isNumeric(result)>
	 		<cfset result = arguments.defaultTimeOut />
		</cfif>
			
		<cfreturn result />
		
	</cffunction>
		
	
	<cffunction name="getWebskinCacheByURL" returntype="boolean" access="public" output="false" hint="Returns the objectbroker cacheByURL boolean value of a webskin. A result of true will HASH the cgi.QUERY_STRING on all ancestor webskins in the cache.">
		<cfargument name="typename" type="string" required="false" default="" />
		<cfargument name="template" type="string" required="false" default="" />
		<cfargument name="path" type="string" required="false" />
	
		<cfset var result = "false" />
		<cfset var templateCode = "" />
		<cfset var pos = "" />	
		<cfset var count = "" />
		
		
		<cfif structKeyExists(application.stcoapi, typename)
			AND structKeyExists(application.stcoapi[typename], "stWebskins") 
			AND structKeyExists(application.stcoapi[typename].stWebskins, template) 
			AND structKeyExists(application.stcoapi[typename].stWebskins[template], "cacheByURL")>
			<cfset result = application.stcoapi['#typename#'].stWebskins['#template#'].cacheByURL />
		</cfif>
		
		
		<cfif not isBoolean(result)>
			<cfset result = false>
		</cfif>
	
	
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getWebskinCacheFlushOnFormPost" returntype="boolean" access="public" output="false" hint="Returns the objectbroker cacheFlushOnFormPost boolean value of a webskin. A result of true will HASH all simple form scope variables on all ancestor webskins in the cache.">
		<cfargument name="typename" type="string" required="false" default="" />
		<cfargument name="template" type="string" required="false" default="" />
		<cfargument name="path" type="string" required="false" />
	
		<cfset var result = "false" />
		<cfset var templateCode = "" />
		<cfset var pos = "" />	
		<cfset var count = "" />
		
		
		<cfif structKeyExists(application.stcoapi, typename)
			AND structKeyExists(application.stcoapi[typename], "stWebskins") 
			AND structKeyExists(application.stcoapi[typename].stWebskins, template) 
			AND structKeyExists(application.stcoapi[typename].stWebskins[template], "cacheFlushOnFormPost")>
			<cfset result = application.stcoapi['#typename#'].stWebskins['#template#'].cacheFlushOnFormPost />
		</cfif>
		
		<cfif not isBoolean(result)>
			<cfset result = false>
		</cfif>
		
	
	
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getWebskinCacheByForm" returntype="boolean" access="public" output="false" hint="Returns the objectbroker cacheByForm boolean value of a webskin. A result of true will HASH all simple form scope variables on all ancestor webskins in the cache.">
		<cfargument name="typename" type="string" required="false" default="" />
		<cfargument name="template" type="string" required="false" default="" />
		<cfargument name="path" type="string" required="false" />
	
		<cfset var result = "false" />
		<cfset var templateCode = "" />
		<cfset var pos = "" />	
		<cfset var count = "" />
		
		
		<cfif structKeyExists(application.stcoapi, typename)
			AND structKeyExists(application.stcoapi[typename], "stWebskins") 
			AND structKeyExists(application.stcoapi[typename].stWebskins, template) 
			AND structKeyExists(application.stcoapi[typename].stWebskins[template], "cacheByForm")>
			<cfset result = application.stcoapi['#typename#'].stWebskins['#template#'].cacheByForm />
		</cfif>
		
		<cfif not isBoolean(result)>
			<cfset result = false>
		</cfif>
		
	
	
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getWebskinCacheByRoles" returntype="boolean" access="public" output="false" hint="Returns the objectbroker cacheByRoles boolean value of a webskin. A result of true will HASH the session.security.roles on all ancestor webskins in the cache.">
		<cfargument name="typename" type="string" required="false" default="" />
		<cfargument name="template" type="string" required="false" default="" />
		<cfargument name="path" type="string" required="false" />
	
		<cfset var result = "false" />
		<cfset var templateCode = "" />
		<cfset var pos = "" />	
		<cfset var count = "" />
		
		
		<cfif structKeyExists(application.stcoapi, typename)
			AND structKeyExists(application.stcoapi[typename], "stWebskins") 
			AND structKeyExists(application.stcoapi[typename].stWebskins, template) 
			AND structKeyExists(application.stcoapi[typename].stWebskins[template], "cacheByRoles")>
			<cfset result = application.stcoapi['#typename#'].stWebskins['#template#'].cacheByRoles />

		</cfif>
		
		<cfif not isBoolean(result)>
			<cfset result = false>
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getWebskinCacheByVars" returntype="string" access="public" output="false" hint="Returns the objectbroker cacheByVars list of a webskin. The list of session vars will HASH the values of those vars on all ancestor webskins in the cache.">
		<cfargument name="typename" type="string" required="false" default="" />
		<cfargument name="template" type="string" required="false" default="" />
		<cfargument name="path" type="string" required="false" />
	
		<cfset var result = "" />
		<cfset var templateCode = "" />
		<cfset var pos = "" />	
		<cfset var count = "" />
		<cfset var iViewState = "" />
		
		<cfif structKeyExists(application.stcoapi, typename)
			AND structKeyExists(application.stcoapi[typename], "stWebskins") 
			AND structKeyExists(application.stcoapi[typename].stWebskins, template) 
			AND structKeyExists(application.stcoapi[typename].stWebskins[template], "cacheByVars")>
			<cfset result = application.stcoapi['#arguments.typename#'].stWebskins['#arguments.template#'].cacheByVars />
			
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getWebskinCacheTypeWatch" returntype="string" access="public" output="false" hint="Returns the objectbroker cacheTypeWatch list of a webskin. The list of typenames will be watched for crud methods on any of its objects and if so, will flush all instances of the webskin for that types listed here.">
		<cfargument name="typename" type="string" required="false" default="" />
		<cfargument name="template" type="string" required="false" default="" />
		<cfargument name="path" type="string" required="false" />
	
		<cfset var result = "" />
		<cfset var templateCode = "" />
		<cfset var pos = "" />	
		<cfset var count = "" />
		<cfset var iViewState = "" />
		
		<cfif structKeyExists(application.stcoapi, typename)
			AND structKeyExists(application.stcoapi[typename], "stWebskins") 
			AND structKeyExists(application.stcoapi[typename].stWebskins, template) 
			AND structKeyExists(application.stcoapi[typename].stWebskins[template], "cacheTypeWatch")>
			<cfset result = application.stcoapi['#arguments.typename#'].stWebskins['#arguments.template#'].cacheTypeWatch />
			
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getWebskinCacheFlushOnObjectChange" returntype="boolean" access="public" output="false" hint="Returns the objectbroker cacheFlushOnObjectChange value of a webskin. If true, the ancestry of this webskin will be captured and will be flushed if any crud methods on its object is fired.">
		<cfargument name="typename" type="string" required="false" default="" />
		<cfargument name="template" type="string" required="false" default="" />
		<cfargument name="path" type="string" required="false" />
	
		<cfset var result = false />
		<cfset var templateCode = "" />
		<cfset var pos = "" />	
		<cfset var count = "" />
		<cfset var iViewState = "" />
		
		<cfif structKeyExists(application.stcoapi, typename)
			AND structKeyExists(application.stcoapi[typename], "stWebskins") 
			AND structKeyExists(application.stcoapi[typename].stWebskins, template) 
			AND structKeyExists(application.stcoapi[typename].stWebskins[template], "cacheFlushOnObjectChange")>
			<cfset result = application.stcoapi['#arguments.typename#'].stWebskins['#arguments.template#'].cacheFlushOnObjectChange />
			
		</cfif>
		<cfif not isBoolean(result)>
			<cfset result = false>
		</cfif>
		
		<cfreturn result />
	</cffunction>

	<cffunction name="getWebskinDisplayname" returntype="string" access="public" output="false" hint="">
		<cfargument name="typename" type="string" required="false" />
		<cfargument name="template" type="string" required="false" />
		<cfargument name="path" type="string" required="false" />
	
		<cfset var result = "" />
		<cfset var templateCode = "" />
		<cfset var pos = "" />	
		<cfset var count = "" />		
		
		<cfif structKeyExists(application.stcoapi, typename)
			AND structKeyExists(application.stcoapi[typename], "stWebskins") 
			AND structKeyExists(application.stcoapi[typename].stWebskins, template) 
			AND structKeyExists(application.stcoapi[typename].stWebskins[template], "displayname")
			AND len(application.stcoapi['#typename#'].stWebskins['#template#'].displayname)>
			
			<cfset result = application.stcoapi['#typename#'].stWebskins['#template#'].displayname />
		<cfelse>
			<cfset result = template />
		</cfif>
			
		<cfreturn result />
	</cffunction>
	
		
	<cffunction name="getWebskinAuthor" returntype="string" access="public" output="false" hint="">
		<cfargument name="typename" type="string" required="false" />
		<cfargument name="template" type="string" required="false" />
		<cfargument name="path" type="string" required="false" />
	
		<cfset var result = "" />
		<cfset var templateCode = "" />
		<cfset var pos = "" />	
		<cfset var count = "" />	
		
		<cfif structKeyExists(application.stcoapi, typename)
			AND structKeyExists(application.stcoapi[typename], "stWebskins") 
			AND structKeyExists(application.stcoapi[typename].stWebskins, template) 
			AND structKeyExists(application.stcoapi[typename].stWebskins[template], "author")>
			<cfset result = application.stcoapi['#typename#'].stWebskins['#template#'].author />

		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	
	<cffunction name="getWebskinDescription" returntype="string" access="public" output="false" hint="">
		<cfargument name="typename" type="string" required="false" />
		<cfargument name="template" type="string" required="false" />
		<cfargument name="path" type="string" required="false" />
	
		<cfset var result = "" />
		<cfset var templateCode = "" />
		<cfset var pos = "" />	
		<cfset var count = "" />
		
		<cfif structKeyExists(application.stcoapi, typename)
			AND structKeyExists(application.stcoapi[typename], "stWebskins") 
			AND structKeyExists(application.stcoapi[typename].stWebskins, template) 
			AND structKeyExists(application.stcoapi[typename].stWebskins[template], "description")>
			<cfset result = application.stcoapi['#typename#'].stWebskins['#template#'].description />

		</cfif>
		
		<cfreturn result />
	</cffunction>


	<cffunction name="getIncludes" returntype="query" access="public" output="false" hint="Returns a query of all available included objects. Search through project first, then any library's that have been included.">
		
		<cfreturn variables.qIncludedObjects />

	</cffunction>
	
	<cffunction name="initializeIncludes" returntype="query" access="public" output="false" hint="Returns a query of all available included objects. Search through project first, then any library's that have been included.">
	
		<cfset var qResult=queryNew("name,directory,size,type,datelastmodified,attributes,mode") />
		<cfset var qLibResult=queryNew("name,directory,size,type,datelastmodified,attributes,mode") />
		<cfset var qCoreResult=queryNew("name,directory,size,type,datelastmodified,attributes,mode") />
		<cfset var qDupe=queryNew("name,directory,size,type,datelastmodified,attributes,mode") />
		<cfset var includePath = "#application.path.project#/includedObj" />
		<cfset var library="" />
		<cfset var col="" />
		<cfset var includeDisplayName = "" />
		<cfset var includeAuthor = "" />
		<cfset var includeDescription = "" />
		<cfset var includeHashURL = "" />
		<cfset var includeFilePath = "" />
		<cfset var recordNum = "" />
		<cfset var qFindDupe = "" />


			<!--- check project includes --->
			<cfif directoryExists(includePath)>
				<cfdirectory action="list" directory="#includePath#" name="qResult" recurse="true" sort="asc" />
				
				<cfquery name="qResult" dbtype="query">
					SELECT *
					FROM qResult
					WHERE lower(qResult.name) LIKE '%.cfm'
				</cfquery>
				
			</cfif>
	
			<!--- check library includes --->
			<cfif structKeyExists(application, "plugins") and Len(application.plugins)>
	
				<cfloop list="#application.fapi.listReverse('#application.plugins#')#" index="library">
					<cfset includepath=ExpandPath("/farcry/plugins/#library#/includedObj") />
					
					<cfif directoryExists(includepath)>
						<cfdirectory action="list" directory="#includePath#" name="qLibResult" sort="asc" />
	
						<cfquery name="qLibResult" dbtype="query">
							SELECT *
							FROM qLibResult
							WHERE lower(qLibResult.name) LIKE '%.cfm'
						</cfquery>
						
						<cfloop query="qLibResult">
							<cfquery dbtype="query" name="qDupe">
							SELECT *
							FROM qResult
							WHERE name = '#qLibResult.name#'
							</cfquery>
							
							<cfif NOT qDupe.Recordcount>
								<cfset queryaddrow(qresult,1) />
								<cfloop list="#qlibresult.columnlist#" index="col">
									<cfset querysetcell(qresult, col, qlibresult[col][qLibResult.currentrow]) />
								</cfloop>
							<cfelse>
								<!--- overwrite record since its being extended --->
								<!--- <cfquery dbtype="query" name="qFindDupe">
								SELECT name
								FROM qResult
								</cfquery>
								<cfset recordNum = listFindNoCase(valueList(qFindDupe.name),qDupe.name) />
								<cfloop list="#qLibResult.columnList#" index="col">
									<cfset querySetCell(qResult, col, qLibResult[col][qLibResult.currentRow],recordNum) />
								</cfloop> --->
							</cfif>
							
						</cfloop>
					</cfif>	
					
				</cfloop>
				
			</cfif>
			
			
			
			
			<!--- ORDER AND SET DISPLAYNAME FOR COMBINED include RESULTS --->		
	 		<cfquery dbtype="query" name="qResult">
			SELECT *, name as displayname,  name as methodname, 'anonymous' as author, '' as description, '' as path
			FROM qResult
			ORDER BY name
			</cfquery>

			<cfoutput query="qResult">				

				<!--- Strip the .cfm from the filename --->
				<cfset querysetcell(qresult, 'methodname', ReplaceNoCase(qResult.name, '.cfm', '','ALL'), qResult.currentRow) />	

				<!--- See if the DisplayName is defined in the include and if so, replace displayName field in the query. --->
				<cfset includeDisplayName = getincludeDisplayname(template="#qResult.name#", directory="#qResult.directory#") />
				<cfif len(includeDisplayName)>
					<cfset querysetcell(qresult, 'displayname', includeDisplayName, qResult.currentRow) />			
				</cfif>	
				
				<!--- See if the Author is defined in the include and if so, replace author field in the query. --->
				<cfset includeAuthor = getincludeAuthor(template="#qResult.name#", directory="#qResult.directory#") />
				<cfif len(includeAuthor)>
					<cfset querysetcell(qresult, 'author', includeAuthor, qResult.currentRow) />			
				</cfif>	
				
				<!--- See if the description is defined in the include and if so, replace author field in the query. --->
				<cfset includeDescription = getincludeDescription(template="#qResult.name#", directory="#qResult.directory#") />
				<cfif len(includeDescription)>
					<cfset querysetcell(qresult, 'description', includeDescription, qResult.currentRow) />			
				</cfif>	
				
				
				<!--- See if the description is defined in the include and if so, replace author field in the query. --->
				<cfset includeFilePath = getincludePath(template="#qResult.name#", directory="#qResult.directory#") />
				<cfif len(includeFilePath)>
					<cfset querysetcell(qresult, 'Path', includeFilePath, qResult.currentRow) />								
				</cfif>
			</cfoutput>

		
		<cfreturn qresult />
	</cffunction>
	
	
	<cffunction name="getIncludeDisplayname" returntype="string" access="public" output="false" hint="">
		<cfargument name="template" type="string" required="true" />
		<cfargument name="directory" type="string" required="true" />
	
		<cfset var result = "" />
		<cfset var pos = "" />
		<cfset var count = "" />
		<cfset var templateCode = "" />
		
		<cfif fileExists("#arguments.directory#/#arguments.template#")>
			<cffile action="READ" file="#arguments.directory#/#arguments.template#" variable="templateCode">
		
			<cfset pos = findNoCase('@@displayname:', templateCode)>
			<cfif pos GT 0>
				<cfset pos = pos + 14>
				<cfset count = findNoCase('--->', templateCode, pos)-pos>
				<cfset result = trim(listLast(mid(templateCode,  pos, count), ":"))>
			</cfif>	
		</cfif>
		
		<cfreturn result />
	</cffunction>
		
	<cffunction name="getIncludePath" returntype="string" access="public" output="false" hint="Returns the cfmapping path to an include. Search through project first, then any library's that have been included.">
		<cfargument name="template" type="string" required="true" />
		<cfargument name="directory" type="string" required="true" />
		
		<cfset var result = "" />
		<cfset var includePath = "#arguments.directory#/#arguments.template#" />
	
		<cfif isdefined("application.path.project")>
			<cfset includePath = replaceNoCase(includePath, application.path.project, "/farcry/projects/#application.projectDirectoryName#") />
		</cfif>
		<cfif isdefined("application.path.plugins")>
			<cfset includePath = replaceNoCase(includePath, application.path.plugins, "/farcry/plugins") />
		</cfif>
		<cfset includePath = replaceNoCase(includePath, expandPath("/farcry"), "/farcry") />
		
		<cfreturn includePath>
		
	</cffunction>
	
		
	<cffunction name="getincludeAuthor" returntype="string" access="public" output="false" hint="">
		<cfargument name="template" type="string" required="true" />
		<cfargument name="directory" type="string" required="true" />
		
		<cfset var result = "" />
		<cfset var includePath = "#arguments.directory#/#arguments.template#" />
		<cfset var templateCode = "" />
		<cfset var pos = "" />
		<cfset var count = "" />
		
		<cffile action="READ" file="#includePath#" variable="templateCode">
	
		<cfset pos = findNoCase('@@author:', templateCode)>
		<cfif pos GT 0>
			<cfset pos = pos + 9>
			<cfset count = findNoCase('--->', templateCode, pos)-pos>
			<cfset result = trim(listLast(mid(templateCode,  pos, count), ":"))>
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getincludeDescription" returntype="string" access="public" output="false" hint="">
		<cfargument name="template" type="string" required="true" />
		<cfargument name="directory" type="string" required="true" />
		
		<cfset var result = "" />
		<cfset var includePath = "#arguments.directory#/#arguments.template#" />
		<cfset var templateCode = "" />
		<cfset var pos = "" />
		<cfset var count = "" />

		<cffile action="READ" file="#includePath#" variable="templateCode">
	
		<cfset pos = findNoCase('@@description:', templateCode)>
		<cfif pos GT 0>
			<cfset pos = pos + 14>
			<cfset count = findNoCase('--->', templateCode, pos)-pos>
			<cfset result = trim(listLast(mid(templateCode,  pos, count), ":"))>
		</cfif>	

		
		<cfreturn result />
	</cffunction>

	<cffunction name="findType" access="public" output="false" returntype="string" hint="Determine the typename for an objectID.">
		<cfargument name="objectid"  required="true">
		<cfargument name="dsn" type="string" required="false" default="">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		
		<cfset var result = application.coapi.coapiUtilities.findType(argumentCollection=arguments) />

		<cfreturn result />
	</cffunction>


	<cffunction name="getFormtoolDefaults" access="public" output="false" returntype="any" hint="Returns the default value of metadata applicable to a formtool passed in. Omitting the md name, defaults for all metadata for the formtool will be returned.">
		<cfargument name="formtool" required="true" type="string" hint="The formtool containing the property" />
		
		<cfset var stResult = structNew() />
		<cfset var stFormtool = structNew() />
		<cfset var i = "" />
		
		<cfif not structKeyExists(application.formtools, arguments.formtool)>
			<cfset arguments.formtool = "string" />
		</cfif>	
		
		<cfset stFormtool = application.formtools[arguments.formtool] />
		<cfif structKeyExists(stFormtool, "stProps")>
			<cfloop collection="#stFormtool.stProps#" item="i">
				<cfset stResult[i] = stFormtool.stProps[i].METADATA.default />
			</cfloop>
		</cfif>
		
		<cfreturn stResult />
	</cffunction>
	
</cfcomponent>