<cfcomponent name="coapiadmin">


<cffunction name="init" access="public" output="false" hint="Initialise component." returntype="coapiadmin">
	
	<cfset variables.qIncludedObjects = initializeIncludes() />
	<cfset this.qIncludedObjects = variables.qIncludedObjects />
	
	<cfreturn this />
</cffunction>

<cffunction name="getCOAPIComponents" access="public" output="false" returntype="query" hint="Get query of COAPI components by package directory. Used by the installer.">
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
								
		<cfset var qResult=queryNew("attributes,author,datelastmodified,description,directory,displayname,hashurl,methodname,mode,name,path,size,type","VarChar,VarChar,date,VarChar,VarChar,VarChar,Integer,VarChar,VarChar,VarChar,VarChar,BigInt,VarChar") />
		<cfset var qLibResult=queryNew("attributes,author,datelastmodified,description,directory,displayname,hashurl,methodname,mode,name,path,size,type","VarChar,VarChar,date,VarChar,VarChar,VarChar,Integer,VarChar,VarChar,VarChar,VarChar,BigInt,VarChar") />
		<cfset var qCoreResult=queryNew("attributes,author,datelastmodified,description,directory,displayname,hashurl,methodname,mode,name,path,size,type","VarChar,VarChar,date,VarChar,VarChar,VarChar,Integer,VarChar,VarChar,VarChar,VarChar,BigInt,VarChar") />
		<cfset var qDupe=queryNew("attributes,author,datelastmodified,description,directory,displayname,hashurl,methodname,mode,name,path,size,type","VarChar,VarChar,date,VarChar,VarChar,VarChar,Integer,VarChar,VarChar,VarChar,VarChar,BigInt,VarChar") />
		<cfset var webskinPath = "#application.path.project#/webskin/#arguments.typename#" />
		<cfset var library="" />
		<cfset var col="" />
		<cfset var WebskinDisplayName = "" />
		<cfset var WebskinAuthor = "" />
		<cfset var WebskinDescription = "" />
		<cfset var WebskinHashURL = "" />
		<cfset var WebskinFilePath = "" />


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
		<cfelse>
			
			<!--- check project webskins --->
			<cfif directoryExists(webskinPath)>
				<cfdirectory action="list" directory="#webskinPath#" name="qResult" recurse="true" sort="asc" />
				
				<cfquery name="qResult" dbtype="query">
					SELECT *
					FROM qResult
					WHERE lower(qResult.name) LIKE '#lCase(arguments.prefix)#%'
					AND lower(qResult.name) LIKE '%.cfm'
				</cfquery>
				
			</cfif>
	
			<!--- check library webskins --->
			<cfif structKeyExists(application, "plugins") and Len(application.plugins)>
	
				<cfloop list="#application.plugins#" index="library">
					<cfset webskinpath=ExpandPath("/farcry/plugins/#library#/webskin/#arguments.typename#") />
					
					<cfif directoryExists(webskinpath)>
						<cfdirectory action="list" directory="#webskinPath#" name="qLibResult" sort="asc" />
	
						<cfquery name="qLibResult" dbtype="query">
							SELECT *
							FROM qLibResult
							WHERE lower(qLibResult.name) LIKE '#lCase(arguments.prefix)#%'
							AND lower(qLibResult.name) LIKE '%.cfm'
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
							</cfif>
							
						</cfloop>
					</cfif>	
					
				</cfloop>
				
			</cfif>
			
			
			<!--- CHECK CORE WEBSKINS --->		
			<cfset webskinpath=ExpandPath("/farcry/core/webskin/#arguments.typename#") />
			
			<cfif directoryExists(webskinpath)>
				<cfdirectory action="list" directory="#webskinPath#" name="qCoreResult" sort="asc" />
	
				<cfquery name="qCoreResult" dbtype="query">
					SELECT *
					FROM qCoreResult
					WHERE lower(qCoreResult.name) LIKE '#lCase(arguments.prefix)#%'
					AND lower(qCoreResult.name) LIKE '%.cfm'
				</cfquery>
				
				<cfloop query="qCoreResult">
					<cfquery dbtype="query" name="qDupe">
					SELECT *
					FROM qResult
					WHERE name = '#qCoreResult.name#'
					</cfquery>
					
					<cfif NOT qDupe.Recordcount>
						<cfset queryaddrow(qresult,1) />
						<cfloop list="#qCoreResult.columnlist#" index="col">
							<cfset querysetcell(qresult, trim(col), qCoreResult[col][qCoreResult.currentRow]) />
						</cfloop>
					</cfif>
					
				</cfloop>
			</cfif>	
			
			
			<!--- ORDER AND SET DISPLAYNAME FOR COMBINED WEBSKIN RESULTS --->		
	 		<cfquery dbtype="query" name="qResult">
			SELECT attributes,'anonymous' as author,datelastmodified,'' as description,directory,name as displayname,'0' as HashURL,name as methodname,mode,name,'' as path,size,type
			FROM qResult
			ORDER BY name
			</cfquery>

			<cfoutput query="qResult">				

				<!--- Strip the .cfm from the filename --->
				<cfset querysetcell(qresult, 'methodname', ReplaceNoCase(qResult.name, '.cfm', '','ALL'), qResult.currentRow) />	

				<!--- See if the DisplayName is defined in the webskin and if so, replace displayName field in the query. --->
				<cfset WebskinDisplayName = getWebskinDisplayname(typename="#arguments.typename#", template="#ReplaceNoCase(qResult.name, '.cfm', '','ALL')#") />
				<cfif len(WebskinDisplayName)>
					<cfset querysetcell(qresult, 'displayname', WebskinDisplayName, qResult.currentRow) />			
				</cfif>	
				
				<!--- See if the Author is defined in the webskin and if so, replace author field in the query. --->
				<cfset WebskinAuthor = getWebskinAuthor(typename="#arguments.typename#", template="#ReplaceNoCase(qResult.name, '.cfm', '','ALL')#") />
				<cfif len(WebskinAuthor)>
					<cfset querysetcell(qresult, 'author', WebskinAuthor, qResult.currentRow) />			
				</cfif>	
				
				<!--- See if the description is defined in the webskin and if so, replace author field in the query. --->
				<cfset WebskinDescription = getWebskinAuthor(typename="#arguments.typename#", template="#ReplaceNoCase(qResult.name, '.cfm', '','ALL')#") />
				<cfif len(WebskinDescription)>
					<cfset querysetcell(qresult, 'description', WebskinDescription, qResult.currentRow) />			
				</cfif>	
				
				<!--- See if the description is defined in the webskin and if so, replace author field in the query. --->
				<cfset WebskinHashURL = getWebskinHashURL(typename="#arguments.typename#", template="#ReplaceNoCase(qResult.name, '.cfm', '','ALL')#") />
				<cfif isBoolean(WebskinHashURL)>
					<cfif WebskinHashURL>
						<cfset querysetcell(qresult, 'HashURL', 1, qResult.currentRow) />
					<cfelse>
						<cfset querysetcell(qresult, 'HashURL', 0, qResult.currentRow) />
					</cfif>
								
				</cfif>	
				
				<!--- See if the description is defined in the webskin and if so, replace author field in the query. --->
				<cfset WebskinFilePath = getWebskinPath(typename="#arguments.typename#", template="#ReplaceNoCase(qResult.name, '.cfm', '','ALL')#") />
				<cfif len(WebskinFilePath)>
					<cfset querysetcell(qresult, 'Path', WebskinFilePath, qResult.currentRow) />								
				</cfif>	
			</cfoutput>
		</cfif>
		
		<cfif listLen(arguments.excludeWebskins)>
			<cfquery dbtype="query" name="qResult">
			SELECT * FROM qResult
			WHERE lower(qResult.methodname) NOT IN (#listQualify(lCase(arguments.excludeWebskins), "'")#)
			</cfquery>
		</cfif>
	
		<cfquery dbtype="query" name="qResult">
		SELECT * FROM qResult
		ORDER BY displayname
		</cfquery>	
		
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
		<cfif isdefined("application.stcoapi.#arguments.typename#.qWebskins")>
			<cfset qWebskinMetadata = application.stcoapi[arguments.typename].qWebskins />
		
			<cfquery dbtype="query" name="qWebskinPath">
			SELECT * 
			FROM qWebskinMetadata
			WHERE cast(methodname as varchar) = '#arguments.template#'
			</cfquery>
			
			<cfif qWebskinPath.recordCount>
				<cfreturn qWebskinPath.path />
			</cfif>
		</cfif>
	
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
		
		<cfreturn webskinPath>
		
	</cffunction>
	
		
	<cffunction name="getWebskinTimeOut" returntype="string" access="public" output="false" hint="Returns the objectbroker timeout value of a webskin. A result of 0 will FORCE any ancestor webskins to NEVER cache.">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="template" type="string" required="true" />
		
		<cfset var webskinTimeOut = "" />
	
		<cfif structKeyExists(application.stcoapi[arguments.typename].stObjectBrokerWebskins, arguments.template)>
			<cfset webskinTimeOut = application.stcoapi[arguments.typename].stObjectBrokerWebskins[arguments.template].timeout />
		</cfif>
		
		<cfreturn webskinTimeOut>
		
	</cffunction>
		
	
	<cffunction name="getWebskinHashURL" returntype="string" access="public" output="false" hint="Returns the objectbroker HashURL boolean value of a webskin. A result of true will HASH the cgi.QUERY_STRING on all ancestor webskins in the cache.">
		<cfargument name="typename" type="string" required="false" default="" />
		<cfargument name="template" type="string" required="false" default="" />
		<cfargument name="path" type="string" required="false" />
	
		<cfset var result = "false" />
		<cfset var templateCode = "" />
		<cfset var pos = "" />	
		<cfset var count = "" />	
		
		
		<cfif NOT structKeyExists(arguments, "path")>
			<cfif len(arguments.typename) AND len(arguments.template)>
				<cfset arguments.path = getWebskinPath(typename=arguments.typename, template=arguments.template) />
			<cfelse>
				<cfthrow type="Application" detail="Error: [getWebskinHashURL] You must pass in a path or both the typename and template" />	
			</cfif>
		</cfif>
		
		<cfif len(arguments.path) and fileExists(Expandpath(arguments.path))>
			<cffile action="READ" file="#Expandpath(arguments.path)#" variable="templateCode">
		
			<cfset pos = findNoCase('@@hashURL:', templateCode)>
			<cfif pos GT 0>
				<cfset pos = pos + 10>
				<cfset count = findNoCase('--->', templateCode, pos)-pos>
				<cfset result = trim(listLast(mid(templateCode,  pos, count), ":"))>
			</cfif>	
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
		
		<cfif NOT structKeyExists(arguments, "path")>
			<cfif len(arguments.typename) AND len(arguments.template)>
				<cfset arguments.path = getWebskinPath(typename=arguments.typename, template=arguments.template) />
			<cfelse>
				<cfthrow type="Application" detail="Error: [getWebskinDisplayname] You must pass in a path or both the typename and template" />	
			</cfif>
		</cfif>
		
		<cfif len(arguments.path) and fileExists(Expandpath(arguments.path))>
			<cffile action="READ" file="#Expandpath(arguments.path)#" variable="templateCode">
		
			<cfset pos = findNoCase('@@displayname:', templateCode)>
			<cfif pos GT 0>
				<cfset pos = pos + 14>
				<cfset count = findNoCase('--->', templateCode, pos)-pos>
				<cfset result = trim(listLast(mid(templateCode,  pos, count), ":"))>
			</cfif>	
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
		
		<cfif NOT structKeyExists(arguments, "path")>
			<cfif len(arguments.typename) AND len(arguments.template)>
				<cfset arguments.path = getWebskinPath(typename=arguments.typename, template=arguments.template) />
			<cfelse>
				<cfthrow type="Application" detail="Error: [getWebskinAuthor] You must pass in a path or both the typename and template" />	
			</cfif>
		</cfif>
		
		<cfif len(arguments.path) and fileExists(Expandpath(arguments.path))>
			<cffile action="READ" file="#Expandpath(arguments.path)#" variable="templateCode">
		
			<cfset pos = findNoCase('@@author:', templateCode)>
			<cfif pos GT 0>
				<cfset pos = pos + 9>
				<cfset count = findNoCase('--->', templateCode, pos)-pos>
				<cfset result = trim(listLast(mid(templateCode,  pos, count), ":"))>
			</cfif>	
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
		
		<cfif NOT structKeyExists(arguments, "path")>
			<cfif len(arguments.typename) AND len(arguments.template)>
				<cfset arguments.path = getWebskinPath(typename=arguments.typename, template=arguments.template) />
			<cfelse>
				<cfthrow type="Application" detail="Error: [getWebskinDescription] You must pass in a path or both the typename and template" />	
			</cfif>
		</cfif>
		
		<cfif len(arguments.path) and fileExists(Expandpath(arguments.path))>
			<cffile action="READ" file="#Expandpath(arguments.path)#" variable="templateCode">
		
			<cfset pos = findNoCase('@@description:', templateCode)>
			<cfif pos GT 0>
				<cfset pos = pos + 14>
				<cfset count = findNoCase('--->', templateCode, pos)-pos>
				<cfset result = trim(listLast(mid(templateCode,  pos, count), ":"))>
			</cfif>	
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

	<cffunction name="findType" access="public" output="false" returntype="string" hint="Determine the typename for an objectID. Returns empty string if object not found">
		<cfargument name="objectid"  required="true">
		<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
		<cfargument name="dbowner" type="string" required="false" default="#ucase(application.dbowner)#">
		
		<cfset var qFindType = queryNew("init") />

		<cfquery datasource="#arguments.dsn#" name="qFindType">
		select typename from #arguments.dbowner#refObjects
		where objectID = '#arguments.objectID#'
		</cfquery>
		
		<cfreturn qFindType.typename>
		
	</cffunction>


</cfcomponent>