<cfcomponent name="coapiadmin">

<cffunction name="init" access="public" output="false" hint="Initialise component." returntype="coapiadmin">
	<cfreturn this />
</cffunction>

<cffunction name="getCOAPIComponents" access="public" output="false" returntype="query" hint="Get query of COAPI components by package directory.">
	<cfargument name="project" required="true" type="string" />
	<cfargument name="package" required="true" type="string" />
	<cfargument name="plugins" default="" type="string" />
	
	<cfset var qResult=queryNew("ATTRIBUTES, DATELASTMODIFIED, DIRECTORY, MODE, NAME, SIZE, TYPE, typepath") />
	<cfset var lDir=arguments.plugins />
	
	<!--- 
	must go in reverse order
	- project
	- reverse library
	- core
	--->
	
	<cfset ldir=listprepend(ldir, "projectpackage") />
	<cfset ldir=listappend(ldir, "corepackage") />
	
	<cfdump var="#arguments#" />
	
	<cfloop list="#lDir#" index="packagedir">

		<!--- get directory listing of components --->
		<cfif packagedir eq "projectpackage">
			<cfset packagepath=GetDirectoryFromPath(GetBaseTemplatePath()) />
			<cfset typepath="farcry.projects.#arguments.project#.packages.#arguments.package#" />
			<cfif directoryExists(packagepath)>
				<cfdirectory directory="#packagepath#../../packages/#arguments.package#" name="qComps" filter="*.cfc" sort="name" />
				<!--- <cfdump var="#qcomps#" label="project: #packagepath#../../packages/#arguments.package#"> --->
			</cfif>
		<cfelseif packagedir eq "corepackage">
			<cfset packagepath=GetDirectoryFromPath(expandpath("/farcry/core/packages/#arguments.package#")) />
			<cfset typepath="farcry.core.packages.#arguments.package#" />
			<cfif directoryExists(packagepath)>
				<cfdirectory directory="#packagepath##arguments.package#" name="qComps" filter="*.cfc" sort="name" />
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
		
		<cfset var qResult=queryNew("name,directory,size,type,datelastmodified,attributes,mode") />
		<cfset var qLibResult=queryNew("name,directory,size,type,datelastmodified,attributes,mode") />
		<cfset var qCoreResult=queryNew("name,directory,size,type,datelastmodified,attributes,mode") />
		<cfset var qDupe=queryNew("name,directory,size,type,datelastmodified,attributes,mode") />
		<cfset var webskinPath = "#application.path.project#/webskin/#arguments.typename#" />
		<cfset var library="" />
		<cfset var col="" />
		<cfset var WebskinDisplayName = "" />
		<cfset var WebskinAuthor = "" />
		<cfset var WebskinDescription = "" />
		<cfset var WebskinHashURL = "" />
		<cfset var WebskinFilePath = "" />


		<cfif not bForceRefresh AND isdefined("application.stcoapi.#arguments.typename#.qWebskins")>
			<cfreturn application.stcoapi[arguments.typename].qWebskins />
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
			SELECT *, name as displayname,  name as methodname, 'anonymous' as author, '' as description, '0' as HashURL, '' as path
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
		
		<cfreturn qresult />
	</cffunction>

		
	<cffunction name="getWebskinPath" returntype="string" access="public" output="false" hint="Returns the path to a webskin. Search through project first, then any library's that have been included.">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="template" type="string" required="true" />
		
		<cfset var webskinPath = "" />
	
		<!--- If the webskin is in the application.stcoapi then just use it --->
		<cfif isdefined("application.stcoapi.#arguments.typename#.qWebskins")>
			<cfset qWebskinMetadata = application.stcoapi[arguments.typename].qWebskins />
		
			<cfquery dbtype="query" name="qWebskinPath">
			SELECT * 
			FROM qWebskinMetadata
			WHERE methodname = '#arguments.template#'
			</cfquery>
			
			<cfif qWebskinPath.recordCount>
				<cfreturn qWebskinPath.path />
			</cfif>
		</cfif>
	
		<cfif fileExists("#application.path.project#/webskin/#arguments.typename#/#arguments.template#.cfm")>
			
			<cfset webskinPath = "/farcry/projects/#application.applicationname#/webskin/#arguments.typename#/#arguments.template#.cfm" />
			
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
		<cfif NOT structKeyExists(arguments, "path")>
			<cfif len(arguments.typename) AND len(arguments.template)>
				<cfset arguments.path = getWebskinPath(typename=arguments.typename, template=arguments.template) />
			<cfelse>
				<cfthrow type="Application" detail="Error: [getWebskinHashURL] You must pass in a path or both the typename and template" />	
			</cfif>
		</cfif>
		
		<cfif len(arguments.path) and fileExists(Expandpath(arguments.path))>
			<cffile action="READ" file="#Expandpath(arguments.path)#" variable="template">
		
			<cfset pos = findNoCase('@@hashURL:', template)>
			<cfif pos GT 0>
				<cfset pos = pos + 10>
				<cfset count = findNoCase('--->', template, pos)-pos>
				<cfset result = trim(listLast(mid(template,  pos, count), ":"))>
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
		<cfif NOT structKeyExists(arguments, "path")>
			<cfif len(arguments.typename) AND len(arguments.template)>
				<cfset arguments.path = getWebskinPath(typename=arguments.typename, template=arguments.template) />
			<cfelse>
				<cfthrow type="Application" detail="Error: [getWebskinDisplayname] You must pass in a path or both the typename and template" />	
			</cfif>
		</cfif>
		
		<cfif len(arguments.path) and fileExists(Expandpath(arguments.path))>
			<cffile action="READ" file="#Expandpath(arguments.path)#" variable="template">
		
			<cfset pos = findNoCase('@@displayname:', template)>
			<cfif pos GT 0>
				<cfset pos = pos + 14>
				<cfset count = findNoCase('--->', template, pos)-pos>
				<cfset result = trim(listLast(mid(template,  pos, count), ":"))>
			</cfif>	
		</cfif>
		
		<cfreturn result />
	</cffunction>	
	<cffunction name="getWebskinAuthor" returntype="string" access="public" output="false" hint="">
		<cfargument name="typename" type="string" required="false" />
		<cfargument name="template" type="string" required="false" />
		<cfargument name="path" type="string" required="false" />
	
		<cfset var result = "" />
		<cfif NOT structKeyExists(arguments, "path")>
			<cfif len(arguments.typename) AND len(arguments.template)>
				<cfset arguments.path = getWebskinPath(typename=arguments.typename, template=arguments.template) />
			<cfelse>
				<cfthrow type="Application" detail="Error: [getWebskinAuthor] You must pass in a path or both the typename and template" />	
			</cfif>
		</cfif>
		
		<cfif len(arguments.path) and fileExists(Expandpath(arguments.path))>
			<cffile action="READ" file="#Expandpath(arguments.path)#" variable="template">
		
			<cfset pos = findNoCase('@@author:', template)>
			<cfif pos GT 0>
				<cfset pos = pos + 9>
				<cfset count = findNoCase('--->', template, pos)-pos>
				<cfset result = trim(listLast(mid(template,  pos, count), ":"))>
			</cfif>	
		</cfif>
		
		<cfreturn result />
	</cffunction>
	<cffunction name="getWebskinDescription" returntype="string" access="public" output="false" hint="">
		<cfargument name="typename" type="string" required="false" />
		<cfargument name="template" type="string" required="false" />
		<cfargument name="path" type="string" required="false" />
	
		<cfset var result = "" />
		<cfif NOT structKeyExists(arguments, "path")>
			<cfif len(arguments.typename) AND len(arguments.template)>
				<cfset arguments.path = getWebskinPath(typename=arguments.typename, template=arguments.template) />
			<cfelse>
				<cfthrow type="Application" detail="Error: [getWebskinDescription] You must pass in a path or both the typename and template" />	
			</cfif>
		</cfif>
		
		<cfif len(arguments.path) and fileExists(Expandpath(arguments.path))>
			<cffile action="READ" file="#Expandpath(arguments.path)#" variable="template">
		
			<cfset pos = findNoCase('@@description:', template)>
			<cfif pos GT 0>
				<cfset pos = pos + 14>
				<cfset count = findNoCase('--->', template, pos)-pos>
				<cfset result = trim(listLast(mid(template,  pos, count), ":"))>
			</cfif>	
		</cfif>
		
		<cfreturn result />
	</cffunction>

</cfcomponent>