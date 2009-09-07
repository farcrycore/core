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
				<cfdirectory directory="#packagepath#" name="qComps" filter="*.cfc" sort="name" />
				<!--- <cfdump var="#qcomps#" label="project: #packagepath#../../packages/#arguments.package#"> --->
			</cfif>
		<cfelseif packagedir eq "corepackage">
			<cfset packagepath=expandpath("/farcry/core/packages/#arguments.package#") />
			<cfset typepath="farcry.core.packages.#arguments.package#" />
			<cfif directoryExists(packagepath)>
				<cfdirectory directory="#packagepath#" name="qComps" filter="*.cfc" sort="name" />
				<!--- <cfdump var="#qcomps#" label="core: #packagepath##arguments.package#"> --->
			</cfif>
		<cfelse>
			<cfset packagepath=ExpandPath("/farcry/plugins/#packagedir#/packages/#arguments.package#") />
			<cfset typepath="farcry.plugins.#packagedir#.packages.#arguments.package#" />
			<cfif directoryExists(packagepath)>
				<cfdirectory action="list" directory="#packagepath#" filter="*.cfc" name="qComps" sort="name" />
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
	
	<cfif structKeyExists(md, "extends")>
		
		<cfset extendedMD = md.extends>
		<cfset extendedTypeName = extendedMD.name />
		
		<!--- Loop through the type extends heirachy until we hit fourq --->
		<cfloop condition="extendedTypeName NEQ 'farcry.core.packages.fourq.fourq'">
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


	<cffunction name="getWebskins" returntype="query" access="public" output="false" hint="Returns a query of all available webskins. Search through project first, then any library's that have been included.">
		<cfargument name="typename" type="string" default="#gettablename()#" hint="Typename of instance." />
		<cfargument name="prefix" type="string" required="false" default="" hint="Prefix to filter template results." />
		<cfargument name="bForceRefresh" type="boolean" required="false" default="false" hint="Force to reload and not use application scope." />
		<cfargument name="excludeWebskins" type="string" required="false" default="" hint="Allows developers to exclude webskins that might be contained in plugins." />
		<cfargument name="packagePath" type="string" required="false" hint="The path to the type." />
		<cfargument name="aExtends" type="array" required="false" hint="The components this type extends" />
		
		<cfset var qResult="" />
		<cfset var qLibResult="" />
		<cfset var qCoreResult="" />
		<cfset var webskinPath = "#application.path.project#/webskin/#arguments.typename#" />
		<cfset var library="" />
		<cfset var col="" />
		<cfset var WebskinDisplayName = "" />
		<cfset var WebskinAuthor = "" />
		<cfset var WebskinDescription = "" />
		<cfset var WebskinCacheByURL = "" />
		<cfset var WebskinFilePath = "" />
		<cfset var sortedPlugins = "" />
		<cfset var stWebskinDetails = structNew() />
		<cfset var webskinRelativePath = "" />
		<cfset var webskinID = 0 />
		<cfset var ids = "" />
		<cfset var webskins = "" />
		
		<cfif not bForceRefresh AND isdefined("application.stcoapi.#arguments.typename#.qWebskins")>
			
			<cfset qResult = application.stcoapi[arguments.typename].qWebskins />
			
			<cfif len(arguments.prefix)>
				<cfquery dbtype="query" name="qResult">
				SELECT *
				FROM qResult
				WHERE lower(qResult.name) LIKE '#lCase(arguments.prefix)#%'
				</cfquery>
			</cfif>
		
			<cfreturn qResult />
		</cfif>
				
		<!--- 
		CACHING IN THE REQUEST SCOPE
		WE ONLY WANT THIS TO BE RUN ONCE PER TYPE PER REQUEST AT THE MOST.		
		THIS IS OFTEN THE CASE FOR ABSTRACT TYPES THAT ARE EXTENDED BY MULTIPLE TYPES
		 --->		
		<cfparam name="request.fc.stcoapiWebskins" default="#structNew()#" />
		<cfparam name="request.fc.stcoapiWebskins[arguments.typename]" default="#structNew()#" />
		
		<cfif structKeyExists(request.fc.stcoapiWebskins[arguments.typename], "qWebskins")>				

			<cfset qResult = request.fc.stcoapiWebskins[arguments.typename].qWebskins />
			
			<cfif len(arguments.prefix)>
				<cfquery dbtype="query" name="qResult">
				SELECT *
				FROM qResult
				WHERE lower(qResult.name) LIKE '#lCase(arguments.prefix)#%'
				</cfquery>
			</cfif>
		
			<cfreturn qResult />
		</cfif>
		
		
		<cfif not structkeyexists(arguments,"aExtends") and structkeyexists(arguments,"packagepath")>
			<cfset arguments.aExtends = getExtendedTypeArray(packagePath=arguments.packagepath) />
		</cfif>
		
		
		<cfif not structKeyExists(request.fc, "stProjectDirectorys")>
			<cftimer label="setup: stProjectDirectorys">
			<cfset request.fc.stProjectDirectorys = structNew() />
			
			<cfdirectory action="list" directory="#expandPath('/farcry/projects/#application.projectDirectoryName#/webskin')#" filter="*.cfm" name="request.fc.stProjectDirectorys.qProject" recurse="true" />
			<cfquery dbtype="query" name="request.fc.stProjectDirectorys.qProject">
			SELECT *, '' as typename, '' as webskin, cast(0 as integer) as id, '' as path
			FROM request.fc.stProjectDirectorys.qProject
			</cfquery>

			<cfloop query="request.fc.stProjectDirectorys.qProject">
				<cfset webskinID = webskinID + 1 />
				<cfset querysetcell(request.fc.stProjectDirectorys.qProject, 'id', webskinID, request.fc.stProjectDirectorys.qProject.currentRow) />		
				<cfset querysetcell(request.fc.stProjectDirectorys.qProject, 'directory', replaceNoCase(request.fc.stProjectDirectorys.qProject.directory,"\","/","all"), request.fc.stProjectDirectorys.qProject.currentRow) />		
				<cfset querysetcell(request.fc.stProjectDirectorys.qProject, 'typename', "#listLast(request.fc.stProjectDirectorys.qProject.directory,"/")#", request.fc.stProjectDirectorys.qProject.currentRow) />		
				<cfset querysetcell(request.fc.stProjectDirectorys.qProject, 'webskin', "/#request.fc.stProjectDirectorys.qProject.typename#/#request.fc.stProjectDirectorys.qProject.name#", request.fc.stProjectDirectorys.qProject.currentRow) />		
				<cfset querysetcell(request.fc.stProjectDirectorys.qProject, 'path', "/farcry/projects/#application.projectDirectoryName#/webskin/#request.fc.stProjectDirectorys.qProject.typename#", request.fc.stProjectDirectorys.qProject.currentRow) />			
			</cfloop>
			
			<cfset request.fc.stProjectDirectorys.qAll = request.fc.stProjectDirectorys.qProject />
			
			
			<cfif structKeyExists(application, "plugins") and Len(application.plugins)>
				<cfset request.stPluginDirectorys = structNew() />
				<cfset pluginCounter = 1 />
				<cfloop list="#application.fapi.listReverse(list='#application.plugins#')#" index="pluginName">
					
					<cfset pluginCounter = pluginCounter + 1 />
					
					<cfdirectory action="list" directory="#expandPath('/farcry/plugins/#pluginName#/webskin')#" filter="*.cfm" name="request.fc.stProjectDirectorys.#pluginName#" recurse="true" />
					<cfquery dbtype="query" name="request.fc.stProjectDirectorys.#pluginName#">
					SELECT *, '' as typename, '' as webskin, cast(0 as integer) as id, '' as path
					FROM request.fc.stProjectDirectorys.#pluginName#
					</cfquery>

					<cfloop query="request.fc.stProjectDirectorys.#pluginName#">
						<cfset webskinID = webskinID + 1 />
						<cfset querysetcell(request.fc.stProjectDirectorys[pluginName], 'id', webskinID, request.fc.stProjectDirectorys[pluginName].currentRow) />		
						<cfset querysetcell(request.fc.stProjectDirectorys[pluginName], 'directory', replaceNoCase(request.fc.stProjectDirectorys[pluginName].directory,"\","/","all"), request.fc.stProjectDirectorys[pluginName].currentRow) />	
						<cfset querysetcell(request.fc.stProjectDirectorys[pluginName], 'typename', "#listLast(request.fc.stProjectDirectorys[pluginName].directory,"/")#", request.fc.stProjectDirectorys[pluginName].currentRow) />		
						<cfset querysetcell(request.fc.stProjectDirectorys[pluginName], 'webskin', "/#request.fc.stProjectDirectorys[pluginName].typename#/#request.fc.stProjectDirectorys[pluginName].name#", request.fc.stProjectDirectorys[pluginName].currentRow) />		
						<cfset querysetcell(request.fc.stProjectDirectorys[pluginName], 'path', "/farcry/plugins/#pluginName#/webskin/#request.fc.stProjectDirectorys[pluginName].typename#", request.fc.stProjectDirectorys[pluginName].currentRow) />	
					</cfloop>
					
					<cfif request.fc.stProjectDirectorys.qAll.recordcount>
						<cfquery dbtype="query" name="request.fc.stProjectDirectorys.qAll">
							SELECT * FROM request.fc.stProjectDirectorys.qAll
							UNION
							SELECT * FROM request.fc.stProjectDirectorys.#pluginName#
							WHERE	not webskin in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#valuelist(request.fc.stProjectDirectorys.qAll.webskin)#" />)
						</cfquery>
					<cfelse>
						<cfset request.fc.stProjectDirectorys.qAll = request.fc.stProjectDirectorys[pluginName] />
					</cfif>
				</cfloop>
				
				
			</cfif>
			

			<cfdirectory action="list" directory="#expandPath('/farcry/core/webskin')#" name="request.fc.stProjectDirectorys.qCore" filter="*.cfm" recurse="true" />
			<cfquery dbtype="query" name="request.fc.stProjectDirectorys.qCore">
			SELECT *, '' as typename, '' as webskin, cast(0 as integer) as id, '' as path
			FROM request.fc.stProjectDirectorys.qCore
			</cfquery>

			<cfloop query="request.fc.stProjectDirectorys.qCore">
				<cfset webskinID = webskinID + 1 />
				<cfset querysetcell(request.fc.stProjectDirectorys.qCore, 'id', webskinID, request.fc.stProjectDirectorys.qCore.currentRow) />		
				<cfset querysetcell(request.fc.stProjectDirectorys.qCore, 'directory', replaceNoCase(request.fc.stProjectDirectorys.qCore.directory,"\","/","all"), request.fc.stProjectDirectorys.qCore.currentRow) />		
				<cfset querysetcell(request.fc.stProjectDirectorys.qCore, 'typename', "#listLast(request.fc.stProjectDirectorys.qCore.directory,"/")#", request.fc.stProjectDirectorys.qCore.currentRow) />	
				<cfset querysetcell(request.fc.stProjectDirectorys.qCore, 'webskin', "/#request.fc.stProjectDirectorys.qCore.typename#/#request.fc.stProjectDirectorys.qCore.name#", request.fc.stProjectDirectorys.qCore.currentRow) />	
				<cfset querysetcell(request.fc.stProjectDirectorys.qCore, 'path', "/farcry/core/webskin/#request.fc.stProjectDirectorys.qCore.typename#", request.fc.stProjectDirectorys.qCore.currentRow) />	
			
			
			</cfloop>
						
			
			<cfquery dbtype="query" name="request.fc.stProjectDirectorys.qAll">
			SELECT * FROM request.fc.stProjectDirectorys.qAll
			UNION
			SELECT * FROM request.fc.stProjectDirectorys.qCore
			WHERE	webskin not in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#valuelist(request.fc.stProjectDirectorys.qAll.webskin)#" />)
			</cfquery>
			
			
			<cfset request.pluginPath=replaceNoCase(ExpandPath('/farcry/plugins'),"\","/","all") />	
			<cfset request.corePath=replaceNoCase(ExpandPath('/farcry/core'),"\","/","all") />	
			<cfset request.projectPath=replaceNoCase(ExpandPath('/farcry/projects'),"\","/","all") />	
			<cfset request.sortedPlugins = application.fapi.listReverse(list='#application.plugins#') />
			
			<!--- ORDER AND SET DISPLAYNAME FOR COMBINED WEBSKIN RESULTS --->		
	 		<cfquery dbtype="query" name="request.fc.stProjectDirectorys.qAll">
			SELECT *, 'anonymous' as author, datelastmodified, '' as description, name as displayname, 0 as cacheStatus, 0 as cacheTimeout, 0 as cacheByURL, 0 as cacheByForm, 0 as cacheByRoles, '' as cacheByVars, name as methodname
			FROM request.fc.stProjectDirectorys.qAll
			</cfquery>
			
			
			<cfoutput query="request.fc.stProjectDirectorys.qAll">				
				
				<!--- SETUP THE METADATA INFO --->
				<cfset stWebskinDetails = structNew() />
				<cfset stWebskinDetails.path = "#request.fc.stProjectDirectorys.qAll.path#/#request.fc.stProjectDirectorys.qAll.name#" />
				<cfset stWebskinDetails.methodname = ReplaceNoCase(request.fc.stProjectDirectorys.qAll.name, '.cfm', '','ALL') />
				
				<!--- Parse the webskin for the metadata --->
				<cfset stWebskinMetadata = parseWebskinMetadata(typename="#arguments.typename#", template="#stWebskinDetails.methodname#", path="#stWebskinDetails.path#", 
						lProperties="displayname,author,description,cacheStatus,cacheTimeout,cacheByURL,cacheByForm,cacheByRoles,cacheByVars") />
				
				<!--- Assign the metadata --->
				<cfset stWebskinDetails.displayname = stWebskinMetadata.displayname />
				
				<cfset stWebskinDetails.author = stWebskinMetadata.author />
				
				<cfset stWebskinDetails.description = stWebskinMetadata.description />
				
				<cfif isNumeric(stWebskinMetadata.cacheStatus)>
					<cfset stWebskinDetails.cacheStatus = stWebskinMetadata.cacheStatus />
				<cfelse>
					<cfset stWebskinDetails.cacheStatus = 0 />
				</cfif>
				
				<cfif isNumeric(stWebskinMetadata.cacheTimeout)>
			 		<cfset stWebskinDetails.cacheTimeout = stWebskinMetadata.cacheTimeout />
			 	<cfelse>
			 		<cfset stWebskinDetails.cacheTimeout = 1440 />
				</cfif>
				
				<cfif isBoolean(stWebskinMetadata.cacheByURL)>
			 		<cfset stWebskinDetails.cacheByURL = stWebskinMetadata.cacheByURL />
			 	<cfelse>
			 		<cfset stWebskinDetails.cacheByURL = false />
				</cfif>
				
				<cfif isBoolean(stWebskinMetadata.cacheByForm)>
			 		<cfset stWebskinDetails.cacheByForm = stWebskinMetadata.cacheByForm />
			 	<cfelse>
			 		<cfset stWebskinDetails.cacheByForm = false />
				</cfif>
				
				<cfif isBoolean(stWebskinMetadata.cacheByRoles)>
			 		<cfset stWebskinDetails.cacheByRoles = stWebskinMetadata.cacheByRoles />
			 	<cfelse>
			 		<cfset stWebskinDetails.cacheByRoles = false />
				</cfif>
				
				<cfset stWebskinDetails.cacheByVars = stWebskinMetadata.cacheByVars />
	
				
				<!--- UPDATE THE METADATA QUERY --->				
				<cfset querysetcell(request.fc.stProjectDirectorys.qAll, 'path', stWebskinDetails.path, request.fc.stProjectDirectorys.qAll.currentRow) />	
				<cfset querysetcell(request.fc.stProjectDirectorys.qAll, 'methodname', stWebskinDetails.methodname, request.fc.stProjectDirectorys.qAll.currentRow) />	
				<cfif len(stWebskinDetails.displayname)>
					<cfset querysetcell(request.fc.stProjectDirectorys.qAll, 'displayname', stWebskinDetails.displayname, request.fc.stProjectDirectorys.qAll.currentRow) />			
				</cfif>	
				<cfif len(stWebskinDetails.author)>
					<cfset querysetcell(request.fc.stProjectDirectorys.qAll, 'author', stWebskinDetails.author, request.fc.stProjectDirectorys.qAll.currentRow) />			
				</cfif>	
				<cfif len(stWebskinDetails.description)>
					<cfset querysetcell(request.fc.stProjectDirectorys.qAll, 'description', stWebskinDetails.description, request.fc.stProjectDirectorys.qAll.currentRow) />			
				</cfif>	
				<cfif isNumeric(stWebskinDetails.cacheStatus)>
					<cfset querysetcell(request.fc.stProjectDirectorys.qAll, 'cacheStatus', stWebskinDetails.cacheStatus, request.fc.stProjectDirectorys.qAll.currentRow) />								
				</cfif>	
				<cfif isNumeric(stWebskinDetails.cacheTimeout)>
					<cfset querysetcell(request.fc.stProjectDirectorys.qAll, 'cacheTimeout', stWebskinDetails.cacheTimeout, request.fc.stProjectDirectorys.qAll.currentRow) />								
				</cfif>	
				<cfif isBoolean(stWebskinDetails.cacheByURL)>
					<cfset querysetcell(request.fc.stProjectDirectorys.qAll, 'cacheByURL', stWebskinDetails.cacheByURL, request.fc.stProjectDirectorys.qAll.currentRow) />								
				</cfif>	
				<cfif isBoolean(stWebskinDetails.cacheByForm)>
					<cfset querysetcell(request.fc.stProjectDirectorys.qAll, 'cacheByForm', stWebskinDetails.cacheByForm, request.fc.stProjectDirectorys.qAll.currentRow) />								
				</cfif>	
				<cfif isBoolean(stWebskinDetails.cacheByRoles)>
					<cfset querysetcell(request.fc.stProjectDirectorys.qAll, 'cacheByRoles', stWebskinDetails.cacheByRoles, request.fc.stProjectDirectorys.qAll.currentRow) />								
				</cfif>	
				<cfset querysetcell(request.fc.stProjectDirectorys.qAll, 'cacheByVars', stWebskinDetails.cacheByVars, request.fc.stProjectDirectorys.qAll.currentRow) />
					
			</cfoutput>
						
			
			</cftimer>
		</cfif>

		<cfset arrayPrepend(aExtends, arguments.typename) />

		<cfloop from="1" to="#arrayLen(aExtends)#" index="i">
			
			<cfquery dbtype="query" name="qTypeSpecific">
			SELECT min(id) as id, name
			FROM request.fc.stProjectDirectorys.qAll
			WHERE typename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#aExtends[i]#">
			<cfif listLen(webskins)>
				AND name NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#webskins#">)
			</cfif>
			GROUP BY name		
			</cfquery>
			<cfset ids = listAppend(ids,valueList(qTypeSpecific.id)) />
			<cfset webskins = listAppend(webskins,valueList(qTypeSpecific.name)) />
		</cfloop>
		
		<cfif listLen(ids)>
			<cfquery dbtype="query" name="qResult">
			SELECT *
			FROM request.fc.stProjectDirectorys.qAll
			WHERE id IN (<cfqueryparam cfsqltype="cf_sql_integer" list="true" value="#ids#">)	
			<cfif listLen(arguments.excludeWebskins)>
				AND lower(methodname) NOT IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lCase(arguments.excludeWebskins)#">)
			</cfif>		
			ORDER BY displayname	
			</cfquery>
		</cfif>

		<!--- 
		PLACE IT IN THE REQUEST SCOPE JUST INCASE WE NEED THIS AGAIN THIS REQUEST.
		 --->
		<cfset request.fc.stcoapiWebskins[arguments.typename].qWebskins = qresult />

		<cfreturn qresult />
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
				
			</cfif>
		</cfif>
		
		<cfreturn webskinPath>
		
	</cffunction>
	

	<cffunction name="parseWebskinMetadata" returntype="struct" access="public" output="false" hint="Returns a struct of the metadata for all requested property metadata in a webskin">
		<cfargument name="typename" type="string" required="false" />
		<cfargument name="template" type="string" required="false" />
		<cfargument name="path" type="string" required="false" />
		<cfargument name="lProperties" type="string" required="true" />
	
		<cfset var result = "" />
		<cfset var templateCode = "" />
		<cfset var pos = "" />	
		<cfset var count = "" />		
		<cfset var i = "" />		
		<cfset var stResult = structNew() />		
		
		<cfloop list="#arguments.lProperties#" index="i">
			<cfif structKeyExists(application.stcoapi, typename)
				AND structKeyExists(application.stcoapi[typename], "stWebskins") 
				AND structKeyExists(application.stcoapi[typename].stWebskins, template) 
				AND structKeyExists(application.stcoapi[typename].stWebskins[template], i)>
				<cfset stResult[i] = application.stcoapi['#typename#'].stWebskins['#template#'][i] />
			<cfelse>	
				<cfif not len(templateCode)>
					<cfif NOT structKeyExists(arguments, "path")>
						<cfif len(arguments.typename) AND len(arguments.template)>
							<cfset arguments.path = getWebskinPath(typename=arguments.typename, template=arguments.template) />
						<cfelse>
							<cfthrow type="Application" detail="Error: [getWebskinDisplayname] You must pass in a path or both the typename and template" />	
						</cfif>
					</cfif>
					
					<cfif len(arguments.path) and fileExists(Expandpath(arguments.path))>
						<cffile action="READ" file="#Expandpath(arguments.path)#" variable="templateCode">
					</cfif>
				</cfif>
				
				<cfset pos = findNoCase('@@#i#:', templateCode)>
				<cfif pos GT 0>
					<cfset pos = pos + len(i) + 3>
					<cfset count = refindNoCase('(--->|@@)', templateCode, pos)-pos>
					<cfset stResult[i] = trim(listLast(mid(templateCode,  pos, count), ":"))>
				</cfif>	
				
				
			</cfif>
			<cfif not structKeyExists(stResult, i)>
				<cfset stResult[i] = "" />
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
		<cfargument name="defaultTimeOut" type="numeric" default="1440" required="false" />
		
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
			AND structKeyExists(application.stcoapi[typename].stWebskins[template], "displayname")>
			<cfset result = application.stcoapi['#typename#'].stWebskins['#template#'].displayname />
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
	
				<cfloop list="#application.plugins#" index="library">
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
								<cfquery dbtype="query" name="qFindDupe">
								SELECT name
								FROM qResult
								</cfquery>
								<cfset recordNum = listFindNoCase(valueList(qFindDupe.name),qDupe.name) />
								<cfloop list="#qLibResult.columnList#" index="col">
									<cfset querySetCell(qResult, col, qLibResult[col][qLibResult.currentRow],recordNum) />
								</cfloop>
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
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		
		<cfset var result = application.coapi.coapiUtilities.findType(argumentCollection=arguments) />

		<cfreturn result />
	</cffunction>


</cfcomponent>