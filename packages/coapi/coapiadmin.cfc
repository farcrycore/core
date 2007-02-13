<cfcomponent name="coapiadmin">

<cffunction name="init" access="public" output="false" hint="Initialise component." returntype="coapiadmin">
	<cfreturn this />
</cffunction>

<cffunction name="getCOAPIComponents" access="public" output="false" returntype="query" hint="Get query of COAPI components by package directory.">
	<cfargument name="project" required="true" type="string" />
	<cfargument name="package" required="true" type="string" />
	<cfargument name="lfarcrylib" default="" type="string" />
	
	<cfset var qResult=queryNew("ATTRIBUTES, DATELASTMODIFIED, DIRECTORY, MODE, NAME, SIZE, TYPE, typepath") />
	<cfset var lDir=arguments.lfarcrylib />
	
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
			<cfset typepath="farcry.#arguments.project#.packages.#arguments.package#" />
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
			<cfset packagepath=ExpandPath("/farcry/farcry_lib/#packagedir#/packages/#arguments.package#") />
			<cfset typepath="farcry.farcry_lib.#packagedir#.packages.#arguments.package#" />
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


<cffunction name="getLibraryInstallers" access="public" output="false" returntype="query" hint="Get query of library install files. Install files limitd to CFM includes.">
	<cfargument name="lfarcrylib" required="true" type="string" hint="List of farcry libraries to process." />

	<cfset var qResult=querynew("ATTRIBUTES, DATELASTMODIFIED, DIRECTORY, MODE, NAME, SIZE, TYPE, library") />
	<cfset var qInstalls=querynew("ATTRIBUTES, DATELASTMODIFIED, DIRECTORY, MODE, NAME, SIZE, TYPE, library") />
	<cfset var installdir="" />
	<cfset var aCol=arrayNew(1) />

	<cfloop list="#arguments.lfarcrylib#" index="lib">
		<cfset installdir=expandpath("/farcry/farcry_lib/#lib#/config/install") />
		<cfif directoryexists(installdir)>
			<cfdirectory action="list" directory="#installdir#" filter="*.cfm" name="qInstalls" sort="asc" />
			
			<cfif qinstalls.recordcount>
				<cfset aCol=arrayNew(1) />
				<cfloop from="1" to="#qinstalls.recordcount#" index="i">
					<cfset arrayAppend(acol, lib) />
				</cfloop>
				<cfset queryAddColumn(qinstalls, "library", aCol) />
				
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


	<cffunction name="getWebskins" returntype="query" access="public" output="false" hint="Returns a query of all available webskins. Search through project first, then any library's that have been included.">
		<cfargument name="typename" type="string" default="#gettablename()#" hint="Typename of instance." />
		<cfargument name="prefix" type="string" required="false" default="" hint="Prefix to filter template results." />
		
		<cfset var qResult=queryNew("name,directory,size,type,datelastmodified,attributes,mode,displayname,methodname") />
		<cfset var qLibResult=queryNew("name,directory,size,type,datelastmodified,attributes,mode") />
		<cfset var qCoreResult=queryNew("name,directory,size,type,datelastmodified,attributes,mode") />
		<cfset var qDupe=queryNew("name,directory,size,type,datelastmodified,attributes,mode") />
		<cfset var webskinPath = ExpandPath("/farcry/#application.applicationname#/webskin/#arguments.typename#") />
		<cfset var library="" />
		<cfset var col="" />
		<cfset var WebskinDisplayName = "" />

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
		<cfif structKeyExists(application, "lFarcryLib") and Len(application.lFarcryLib)>

			<cfloop list="#application.lFarcryLib#" index="library">
				<cfset webskinpath=ExpandPath("/farcry/farcry_lib/#library#/webskin/#arguments.typename#") />
				
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
						<cfset querysetcell(qresult, col, qCoreResult[col][qCoreResult.currentRow]) />
					</cfloop>
				</cfif>
				
			</cfloop>
		</cfif>	
		
		
		<!--- ORDER AND SET DISPLAYNAME FOR COMBINED WEBSKIN RESULTS --->		
 		<cfquery dbtype="query" name="qResult">
		SELECT *,  name as displayname,  name as methodname
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
		</cfoutput>
		
		<cfreturn qresult />
	</cffunction>

		
	<cffunction name="getWebskinPath" returntype="string" access="public" output="false" hint="Returns the path to a webskin. Search through project first, then any library's that have been included.">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="template" type="string" required="true" />
		
		<cfset var webskinPath = "" />
	
		<cfif fileExists(ExpandPath("/farcry/#application.applicationname#/webskin/#arguments.typename#/#arguments.template#.cfm"))>
			
			<cfset webskinPath = "/farcry/#application.applicationname#/webskin/#arguments.typename#/#arguments.template#.cfm" />
			
		<cfelseif structKeyExists(application, "lFarcryLib") and listLen(application.lFarcryLib)>

			<cfloop list="#application.lFarcryLib#" index="library">
				
				<cfif fileExists(ExpandPath("/farcry/farcry_lib/#library#/webskin/#arguments.typename#/#arguments.template#.cfm"))>
				
					<cfset webskinPath = "/farcry/farcry_lib/#library#/webskin/#arguments.typename#/#arguments.template#.cfm" />
				</cfif>	
				
			</cfloop>
			
		</cfif>
		
		<!--- If it hasnt been found yet, check in core. --->
		<cfif not len(webskinPath) AND fileExists(ExpandPath("/farcry/core/webskin/#arguments.typename#/#arguments.template#.cfm"))>
			
			<cfset webskinPath = "/farcry/core/webskin/#arguments.typename#/#arguments.template#.cfm" />
			
		</cfif>
		
		<cfreturn webskinPath>
		
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
				<cfset result = listLast(mid(template,  pos, count), ":")>
			</cfif>	
		</cfif>
		
		<cfreturn result />
	</cffunction>

</cfcomponent>