<cfcomponent name="FlightCheck" output="false" displayname="FlightCheck" hint="Returns an array of errors during installation flight check">
	
	<!---
	PROPERTIES
	--->
	<cfset variables.instance = structNew() />
	<!--- array to track any flight check errors --->
	<cfset variables.instance.aErrors = arrayNew(1) />



	<!---
	PUBLIC FUNCTIONS
	--->
	<cffunction name="checkColdFusionVersion" access="public" returntype="boolean" output="false" hint="Users must be running CFMX7+ to install Farcry">
		
		<cfset var bSuccess = 1 />
		<cfset var stCFVersion = structNew() />
		<cfset var iVersionNeeded = "7.0.2" />
		<cfset var iCurrentCFVersion = replace(Server.ColdFusion.ProductVersion, ",", ".", "All") />
		
		<!--- check cfmx version details --->
		<cfif iCurrentCFVersion LT iVersionNeeded><!--- Not a valid mathematical comparison, instead we are relying on an ASCII comparison --->
			<cfset bSuccess = 0 />
			<cfset stCFVersion.title = "Invalid ColdFusion version" />
			<cfset stCFVersion.description = "<p>You are currently running ColdFusion version #iCurrentCFVersion# and need to upgrade to CFMX #iVersionNeeded# before trying to install FarCry</p>" />
			<cfset setErrors(stCFVersion) />
		</cfif>
		
		<cfreturn bSuccess />
		
	</cffunction>
	


	<cffunction name="checkDirectoryExists" access="public" returntype="boolean" output="false" hint="Check to see whether a directory exists">
		<cfargument name="location" required="true" type="string" hint="Location (path) to look for" />
		
		<cfset var bSuccess = 1 />
		
		<cftry>
			
			<cfset bSuccess = numberFormat(directoryExists(arguments.location)) />
			
			<cfcatch type="any">
				<!--- TODO: exception handling here! --->
			</cfcatch>
		</cftry>
	
		<cfreturn bSuccess />
	
	</cffunction>



	<cffunction name="checkDSN" access="public" returntype="struct" output="false" hint="Check to see whether the DSN entered by the user is valid">
		<cfargument name="DSN" type="string" required="true" hint="DSN to check" />

		<cfset var qCheckDSN = queryNew("blah") />
		<cfset var stResult = structNew() />
		<cfset stResult.bSuccess = true />
		<cfset stResult.errorTitle = "" />
		<cfset stResult.errorDescription = "" />
		

		<cftry>
		
			<!--- run any query to see if the DSN is valid --->
			<cfquery name="qCheckDSN" datasource="#arguments.DSN#">
				SELECT 'patrick' AS theMAN
			</cfquery>
			
			<cfcatch type="database">
				<cftry>						
					<!--- 
					First check for oracle will fail. This is the oracle check.
					Run any query to see if the DSN is valid --->
					<cfquery name="qCheckDSN" datasource="#arguments.DSN#">
						SELECT 'patrick' AS theMAN from dual
					</cfquery>
					
					<cfcatch type="database">
						<cfset stResult.bSuccess = false />
						<cfset stResult.errorTitle = "Invalid DSN" />
						<cfsavecontent variable="stResult.errorDescription">
							<cfoutput>
							<p>Your DSN (#arguments.DSN#) is invalid.</p>
							<p>Please check it is setup and verifies ColdFusion Administrator</p>
							</cfoutput>			
						</cfsavecontent>
					</cfcatch>
					
				</cftry>
			</cfcatch>
			
		</cftry>
		
		<cfif stResult.bSuccess>
			<cfset stResult = checkExistingDatabase(arguments.DSN) />
		</cfif>
		
		<cfreturn stResult />
	
	</cffunction>
	
	
	
	<cffunction name="checkExistingDatabase" access="public" returntype="struct" output="false" hint="Check to see whether a farcry database exists">
		<cfargument name="DSN" type="string" required="true" hint="DSN to check" />

		<cfset var qCheckDSN = queryNew("blah") />
		<cfset var bExists = true />
		<cfset var stResult = structNew() />
		<cfset stResult.bSuccess = true />
		<cfset stResult.errorTitle = "" />
		<cfset stResult.errorDescription = "" />

		<cftry>
		
			<!--- run any query to see if there is an existing farcry project in the database --->
			<cfquery name="qCheckDSN" datasource="#arguments.DSN#">
				SELECT	count(objectId) AS theCount
				FROM	refObjects
			</cfquery>
			
			<cfcatch type="database">
				<cfset bExists = false />
			</cfcatch>
			
		</cftry>
		
		<cfif bExists>
			
			<cfset stResult.bSuccess = false />
			<cfset stResult.errorTitle = "Existing Farcry database found" />
			<cfsavecontent variable="stResult.errorDescription">
				<cfoutput>
				<p>Your database contains an existing Farcry application</p>
				<p>You must install into an empty database</p>
				</cfoutput>			
			</cfsavecontent>
		
		</cfif>		
		
		<cfreturn stResult />
	
	</cffunction>	
	

	
	<cffunction name="checkDBType" access="public" returntype="struct" output="false" hint="Check to see whether the database is Oracle">
		<cfargument name="DSN" type="string" required="true" hint="DSN to check" />
		<cfargument name="DBType" type="string" required="true" hint="Type of DB to check" />
		<cfargument name="DBOwner" type="string" required="true" hint="Database owner" />

		<cfset var qCheckDSN = queryNew("blah") />
		<cfset var bCorrectDB = true />
		<cfset var databaseTypeName = "" />
		<cfset var stResult = structNew() />
		<cfset stResult.bSuccess = true />
		<cfset stResult.errorTitle = "" />
		<cfset stResult.errorDescription = "" />

			<cfswitch expression="#arguments.DBType#">
			<cfcase value="ora">
				<cfset databaseTypeName = "Oracle" />
				<!--- run an oracle specific query --->
				<cfquery name="qCheckDSN" datasource="#arguments.DSN#">
				SELECT 'patrick' AS theMAN from dual
				</cfquery>
			</cfcase>
			<cfcase value="MSSQL">
				<cfset databaseTypeName = "MSSQL" />
				<!--- run an MSSQL specific query --->
				<cfquery name="qCheckDSN" datasource="#arguments.DSN#">
				SELECT	count(*) AS theCount
				FROM	#arguments.DBOwner#sysobjects
				</cfquery>
			</cfcase>
			</cfswitch>

		
		<cfif not bCorrectDB>
			
			<cfset stResult.bSuccess = false />
			<cfset stResult.errorTitle = "Not a valid #databaseTypeName# Database" />
			<cfsavecontent variable="stResult.errorDescription">
				<cfoutput>
				<p>Your database does not seem to be #databaseTypeName#</p>
				<p>Please check the database type and try again.</p>
				</cfoutput>			
			</cfsavecontent>
		
		</cfif>		
		
		<cfreturn stResult />
	
	</cffunction>	
		
	
	


	<cffunction name="checkFarcryCore" access="public" returntype="boolean" output="false" hint="Check for the core directory">
		
		<cfset var bSuccess = 1 />
		<cfset var sDescription = "" />
		<cfset var bFarcryMapping = 1 />
		<cfset var stFarcryCore = structNew() />
		
		<cftry>
			
			<cfinclude template="/farcry/core/admin/ping/index.cfm" />
			
			<cfcatch type="missingInclude">
				<cfset bSuccess = 0 />
				<cfset stFarcryCore.title = "Missing ""/farcry"" ColdFusion mapping" />			
				<cfsavecontent variable="sDescription">
					<cfoutput>
					<p>You must be able to access the directory which contains "core", "plugins" and "projects".</p>
					<p class="errorDescription">To achieve this you need to setup a ColdFusion mapping of '/farcry' ^, e.g.</p>
					<table cellpadding="2" cellspacing="2" class="errorDescription" summary="Displaying examples of how to setup a /farcry mapping">
						<tr>
							<th>ColdFusion mapping</th>
							<th>Local path</th>
						</tr>
						<tr>
							<td>/farcry</td>
							<td>C:\farcry<br />(which contains core, plugins and projects)</td>
						</tr>
					</table>
					<p>Note that while the ColdFusion mapping must be '/farcry', the parent directory does not have to be called 'farcry', e.g.</p>
					<table cellpadding="2" cellspacing="2" class="errorDescription" summary="Displaying examples of how to setup a /farcry mapping">
						<tr>
							<th>ColdFusion mapping</th>
							<th>Local path</th>
						</tr>
						<tr>
							<td>/farcry</td>
							<td>C:\sampleDirectory<br />(which contains core, plugins and projects)</td>
						</tr>
					</table>
					<cfset bFarcryMapping = getFarcryMapping() />
					<cfif bFarcryMapping>
						<p>^ We note that while you do currently have a '/farcry' ColdFusion mapping (or core is in the server root), it could be pointing to the wrong location. Remember that /farcry must point to the <em>parent</em> directory of core, plugins and fouq.</p>
					</cfif>
					<br />
					</cfoutput>			
				</cfsavecontent>
				<cfset stFarcryCore.description = sDescription />
				<cfset setErrors(stFarcryCore) />
			</cfcatch>
		</cftry>
		
		<cfreturn bSuccess />
		
	</cffunction>
	


	<cffunction name="checkFarcryPlugin" access="public" returntype="boolean" output="false" hint="Check for the plugins directory">
		
		<cfset var bSuccess = 1 />
		<cfset var sDescription = "" />
		<cfset var bFarcryMapping = 1 />
		<cfset var stFarcryLib = structNew() />
		
		<cftry>
			
			<!--- set false error handling here to be used in catch as well --->
			<cfset stFarcryLib.title = """/plugins"" not found" />			
			<cfsavecontent variable="sDescription">
				<cfoutput>
				<p>You must have the "plugins" directory which comes as part of the install package. This should reside in the same directory as core and projects.</p>
				<p>For example:</p>
				<dl>
					<dt>/farcry</dt>
					<dd>
						/core<br /> 
						/plugins
					</dd>
				</dl>
				<p>To achieve this you need to setup a ColdFusion mapping of '/farcry' ^, e.g.</p>
				<table cellpadding="2" cellspacing="2" class="errorDescription" summary="Displaying examples of how to setup farcry mappings">
					<tr>
						<th>ColdFusion mapping</th>
						<th>Local path</th>
					</tr>
					<tr>
						<td>/farcry</td>
						<td>C:\farcry<br />(which contains core, plugins and projects)</td>
					</tr>
				</table>
				<cfset bFarcryMapping = getFarcryMapping() />
				<cfif bFarcryMapping>
					<p>^ We note that while you do currently have a '/farcry' ColdFusion mapping (or core is in the server root), it could be pointing to the wrong location. Remember that /farcry must point to the <em>parent</em> directory of core, plugins and projects.</p>
				</cfif>
				<br />
				</cfoutput>			
			</cfsavecontent>
			
			<cfset bFarcryMapping = directoryExists(expandPath("/farcry/plugins")) />
			
			<cfif NOT bFarcryMapping>
				
				<cfset bSuccess = 0 />
				
				<cfset stFarcryLib.description = sDescription />
				<cfset setErrors(stFarcryLib) />
				
			</cfif>
			
			<cfcatch>
				<cfset bSuccess = 0 />
				
				<cfset stFarcryLib.description = sDescription />
				<cfset setErrors(stFarcryLib) />				
			</cfcatch>
			
		</cftry>
		
		<cfreturn bSuccess />
		
	</cffunction>
	
	

	<cffunction name="checkFarcryProject" access="public" returntype="boolean" output="false" hint="Check for the project directory using the '/farcry' ColdFusion mapping and the ##applicationName## from the install form. If the project directory resides in the same location as core or is in a separate location, this mapping ('/farcry/farcry_project') should find the directory.">
		<cfargument name="siteName" required="true" type="string" hint="Project site name, should be the same as the project directory name" />
		
		<!--- check for default controller to make sure project is located correctly --->
		<cfset var bSuccess = FileExists(expandPath("/farcry/projects/#arguments.siteName#/www/index.cfm")) />
		<cfset var sDescription = "" />
		<cfset var bProjectMapping = 1 />	
		<cfset var bProjectDirExists = 0 />
		<cfset var stProject = structNew() />

		<cfif NOT bSuccess>
			<cfset bProjectDirExists = checkDirectoryExists(expandPath("/farcry/projects/#arguments.siteName#")) />						
			<cfset stProject.title = "Project (website) ColdFusion mapping" />
			<cfsavecontent variable="sDescription">
				<cfoutput>
					<p>ColdFusion must be able to access your new project directory. There are 2 ways to achieve this:</p>
					<ol>
						<li>Store your project directory in the same location as core, plugins and projects. Using this method you will only need 1 ColdFusion mapping (/farcry)</li>
						<li>If your project is located in a directory other than the one containing core, plugins and projects you will need a 2nd ColdFusion mapping pointing to your project directory. (/farcry/farcry_xxxx)</li>
					</ol>
					<p>Example for scenario 1:</p>
					<table cellpadding="2" cellspacing="2" class="errorDescription" summary="Displaying examples of how to setup a /farcry mapping">
						<tr>
							<th>ColdFusion mapping</th>
							<th>Local path</th>
						</tr>
						<tr>
							<td>/farcry</td>
							<td>
								C:\farcry
								<ul>
									<li>core</li>
									<li>plugins</li>
									<li>projects</li>
								</ul>
							</td>
						</tr>
					</table>
					<p><strong>Remember</strong> that your project (site name) entered from the installation form will be used as the 'name' attribute in cfapplication and should be the same name as your project directory, i.e. farcry_xxxx</p>
					<p>Example for scenario 2:</p>
					<table cellpadding="2" cellspacing="2" class="errorDescription" summary="Displaying examples of how to setup a /farcry mapping">
						<tr>
							<th>ColdFusion mapping</th>
							<th>Local path</th>
						</tr>
						<tr>
							<td>/farcry/projects/farcry_xxxx</td>
							<td>C:\webapps\farcry_xxxx</td>
						</tr>
					</table>		
					<p>You have have entered <em>#arguments.siteName#</em> as your site name but we cannot access your project folder using '/farcry/projects/#arguments.siteName#'</p>
					<cfif NOT bProjectDirExists>
						<p>It appears as though you are using scenario 2 (project directory is in a separate location to core) because we cannot find <em>#arguments.siteName#</em> in the same location as core. Please create a ColdFusion mapping before proceeding or verify that your site name (<em>#arguments.siteName#</em>) is correct.</p>
					</cfif>
					<p><a href="##" onclick="history.back();"><-- Back to the installation form</a></p>
				</cfoutput>
			</cfsavecontent>
		
			<cfset stProject.description = sDescription />
			<cfset setErrors(stProject) />
		
		</cfif>
		
		<cfreturn bSuccess />
		
	</cffunction>


	
	<cffunction name="checkPlugins" access="public" returntype="query" output="false" hint="Check for any plugins to be installation">
		<cfargument name="dir" required="true" type="string" hint="Absolute path to list directories from" />
	
		<cfset var bSuccess = 1 />
		<cfset var bDirectoryExists = arguments.dir & "/plugins" />
		<cfset var qPlugins = queryNew("type") />
		
		<cftry>
			
			<cfif directoryExists(bDirectoryExists)>
			
				<cfdirectory 
					action="list"
				   	directory="#bDirectoryExists#" 
				   	name="qPlugins" 
				   	sort="type"
				 />
				 
				<cfif NOT qPlugins.recordCount>
					<cfset bSuccess = 0 />
				</cfif>
				
			</cfif>

			<cfcatch type="any">
				
				<cfset bSuccess = 0 />
				
			</cfcatch>
		
		</cftry>
		
		<cfreturn qPlugins />
		
	</cffunction>
	
	
	
	<cffunction name="checkMapping" access="public" returntype="boolean" output="false" hint="Check for a particular mapping in CFAM">
		<cfargument name="mapping" required="false" default="/farcry" type="string" hint="The mapping name to check for, default to /farcry" />
		<cfargument name="bThrowError" required="false" default="1" type="boolean" hint="Whether or not to send an error to setErrors()" />
		
		<cfset var bSuccess = 1 />
		<cfset var oMappings = "" />
		<cfset var sDescription = "" />
		<cfset var stFarcryMapping = structNew() />
		<cfset var bMappingPath = 1 />
		
		<cftry>
			
			<cfset bMappingPath = numberFormat(directoryExists(expandPath("/farcry/#arguments.mapping#"))) />

			<cfif NOT bMappingPath>
				<!--- no /farcry mapping found --->

				<cfset bSuccess = 0 />
				
				<cfif arguments.bThrowError>
					<cfset stFarcryMapping.title = """#arguments.mapping#"" mapping not found" />
					<cfsavecontent variable="sDescription">
						<cfoutput>
						<p>You must have a "/farcry" mapping in ColdFusion Administrator. This mapping should point to the directory which contains core, plugins and projects.</p>
						<p>To proceed please setup a ColdFusion mapping of '/farcry', e.g.</p>
						<table cellpadding="2" cellspacing="2" class="errorDescription" summary="Displaying examples of how to setup mappings">
							<tr>
								<th>ColdFusion mapping</th>
								<th>Local path</th>
							</tr>
							<tr>
								<td>/farcry</td>
								<td>C:\farcry<br />(which contains core, plugins and projects)</td>
							</tr>
						</table>
						<p><a href="index.cfm">Run installation</a> after creating a ColdFusion mapping</p>
						</cfoutput>
						<br />		
					</cfsavecontent>
					<cfset stFarcryMapping.description = sDescription />
					<cfset setErrors(stFarcryMapping) />
				</cfif>
				
			</cfif>
			
			<cfcatch type="any">
				<cfset bSuccess = 0 />
			</cfcatch>
		</cftry>
		
		<cfreturn bSuccess />
		
	</cffunction>	
	
	
	
	<cffunction name="checkPhyDirName" access="public" returntype="boolean" output="false" hint="Check that the physical directory of your project is the same as the virtual directory (if there is one)">
		<cfargument name="dirName" required="true" type="string" hint="The project directory name" />
		<cfargument name="vdName" required="true" type="string" hint="The virtual directory name" />
		
		<cfset var bSuccess = 1 />
		<cfset var stError = structNew() />
		<cfset var tempDirName = arguments.dirName />
		<cfset var tempVDirName = arguments.vdName />
		
		<cfset tempDirName = replace(tempDirName, "/", "", "All") />
		<cfset tempDirName = replace(tempDirName, "\", "", "All") />
		<cfset tempVDirName = replace(tempVDirName, "/", "", "All") />
		<cfset tempVDirName = replace(tempVDirName, "\", "", "All") />
		
		<cfif len(tempVDirName) AND (tempDirName NEQ tempVDirName)>
			
			<cfset bSuccess = 0 />
			<cfset stError.title = "Project Directory Name" />
			<cfsavecontent variable="stError.description">
				<cfoutput>
				<p>Your project virtual directory name must be identical to your physical directory name.</p>
				<p>Your current Virtual Directory is <strong>#tempVDirName#</strong></p>
				<p>Your current Directory name is <strong>#tempDirName#</strong></p>
				</cfoutput>
			</cfsavecontent>
			<cfset setErrors(stError) />
			
		</cfif>
		
		<cfreturn bSuccess />
	
	</cffunction>
	
	
	
	<cffunction name="checkProjectName" access="public" returntype="boolean" output="false" hint="Check the project directory for invalid (reserved) names">
		<cfargument name="siteName" required="true" type="string" hint="The project directory name a user is attempting to install" />
		
		<cfset var bSuccess = 1 />
		<cfset var stSiteName = structNew() />
		
		<!--- site name --->
		<cfset lAmnesty = "farcry,core,fourq,farcry_pliant,farcry_mollio,mollio,pliant,plugins,themes" />
		<cfif listFindNoCase(lAmnesty, arguments.siteName)>
			<cfset bSuccess = 0 />
			<cfset stSiteName.title = "Project Name" />
			<cfsavecontent variable="stSiteName.description">
				<cfoutput>
				<p>Your project directory name cannot be one of the following:</p>
				<ul>
				<cfloop list="#lAmnesty#" index="sItem">
					<li style="list-style:disc;margin-left:20px;padding-left:0px;">#sItem#</li>
				</cfloop>
				</ul>
				<p>Please rename your project directory (which is currently <strong>#arguments.siteName#</strong>) to another name</p>			
				</cfoutput>
			</cfsavecontent>
			<cfset setErrors(stSiteName) />	
		<cfelseif reFind("[^_\-[:alnum:]]", arguments.siteName)>
			
			<!--- 
				Check for invalid characters in the project folder name. Names should follow a similar convention for variables;
					- Start with an alpha
					- Containt only alphanumeric characters
					- Only exclusion is the underscore and the dash
				So the following ranges are ok:
					a-zA-Z_-
			 --->
			<cfset bSuccess = 0 />
			<cfset stSiteName.title = "Project Name" />
			<cfsavecontent variable="stSiteName.description">
				<cfoutput>
				<p>Your project directory name contains invalid characters:</p>
				<p>Please rename your project directory (which is currently <strong>#arguments.siteName#</strong>) to another name using the following conventions:</p>
				<!--- TODO: remove these embedded styles :( --->
				<ul>
					<li style="list-style:disc;margin-left:20px;padding-left:0px;">Start with an alpha</li>
					<li style="list-style:disc;margin-left:20px;padding-left:0px;">Contain only alphanumeric characters</li>
					<li style="list-style:disc;margin-left:20px;padding-left:0px;">Can also include the underscore or dash</li>
				</ul>			
				</cfoutput>
			</cfsavecontent>
			<cfset setErrors(stSiteName) />		
			
		</cfif>
			
		<cfreturn bSuccess />
		
	</cffunction>	
			
			
	
	<cffunction name="checkWebMapping" access="public" returntype="boolean" output="false" hint="Check for the Web Mapping pointing to the project (website)">
		<cfargument name="serverName" type="string" required="true" hint="The server name you are running off (e.g. localhost)" />
		<cfargument name="projectMapping" type="string" required="true" hint="The web mapping as entered in the installation form, used to access the project. Defaults to /" />
		<cfargument name="protocol" type="string" required="false" default="http://" hint="Protocol used to access URL" />		
		
		<cfset var bSuccess = 1 />		
		<cfset var sDescription = "" />
		<cfset var stWebMapping = structNew() />
				
		<cftry>
			
			<!--- make sure user has entered a prepending '/' --->
			<cfif left(arguments.projectMapping, 1) NEQ "/">
				<cfset arguments.projectMapping = "/" & arguments.projectMapping />
			</cfif>
			
			<cfhttp url="#arguments.protocol##arguments.serverName#:#cgi.server_port##arguments.projectMapping#/install/ping/" method="head" throwonerror="true" timeout="10" port="#cgi.server_port#" />
			
			<cfcatch type="any">
				<cfset bSuccess = 0 />
				<cfset stWebMapping.title = "Project web mapping" />
				<cfsavecontent variable="sDescription">
					<cfoutput>
						<p>The installer cannot seem to access your project. Make sure that the Installer Domain Name option (currently: #arguments.serverName#) is correct. <em>This is the 1st field on the install form.</em>
						</p>
						<cfif arguments.projectMapping NEQ "/">
							<p>
								We note that you seem to be  using "#arguments.projectMapping#". 
								Please make sure your web mapping (#arguments.projectMapping#) is pointing to the [projectname/www] directory
							</p>														
						</cfif>
						<p>Note that if you currently have network security in place, this may prevent Farcry from validating an installation. Please check your security settings.</p>
						<p>See the installation guide for further information, or try the following for online documentation:</p>
						<ul>
							<li><a href="http://www.farcrycms.org/" title="farcrycms.org" target="_blank">farcrycms.org</a></li>
							<li><a href="http://docs.farcrycms.org:8080/confluence/" title="FarcryCMS developer WIKI" target="_blank">Developer WIKI</a></li>
						</ul>
						<p><a href="##" onclick="history.back();"><-- Back to the installation form</a></p>
					</cfoutput>
				</cfsavecontent>
				<cfset stWebMapping.description = sDescription />
				<cfset setErrors(stWebMapping) />
			</cfcatch>
		</cftry>
		
		<cfreturn bSuccess />		
		
	</cffunction>	
	
	
	
	<cffunction name="checkWebtop" access="public" returntype="boolean" output="false" hint="Check for the Web Mapping pointing to the webtop (core/admin)">
		<cfargument name="serverName" type="string" required="true" hint="The server name you are running off (e.g. localhost)" />
		<cfargument name="farcryMapping" type="string" required="true" hint="The web mapping as entered in the installation form, used to access core/admin" />
		<cfargument name="appMapping" type="string" required="true" hint="The application mapping as entered in the installation form, used to access a project" />
		<cfargument name="protocol" type="string" required="false" default="http://" hint="Protocol used to access URL" />		
		
		<cfset var bSuccess = 1 />		
		<cfset var sDescription = "" />
		<cfset var stWebtop = structNew() />
				
		<cftry>
			
			<!--- make sure user has entered a prepending '/' --->
			<cfif left(arguments.farcryMapping, 1) NEQ "/">
				<cfset arguments.farcryMapping = "/" & arguments.farcryMapping />
			</cfif>
			
			<cfhttp url="#arguments.protocol##arguments.serverName#:#cgi.server_port##arguments.farcryMapping#/ping/" method="head" throwonerror="true" timeout="10" port="#cgi.server_port#" />
			
			<cfcatch type="any">
				<cfset bSuccess = 0 />
				<cfset stWebtop.title = "Missing ""/farcry"" web mapping" />
				<cfsavecontent variable="sDescription">
					<cfoutput>
						<h3>The 'farcry' web mapping/virtual directory must point to <strong>#getTranslatedPath(expandPath("/farcry/core/admin"))#</strong></h3>
						<p>
							You must be able to access the Farcry Administration (webtop) using a web mapping/virtual directory in your web server 
							config (Apache or IIS) of 'farcry'. 
						</p>
						<p>
							Note that your farcry web mapping/virtual directory should appear <em>under</em>
							your project, not at the same level as it. For example:
						</p>
						<p>
							<dl>
								<dt style="font-weight:normal;font-size:12px;">
									<cfif NOT len(getProjectSubDirectory())>
										/Project Web Root
									<cfelse>
										#getProjectSubDirectory()#
									</cfif>
								</dt>
								<dd>/farcry (<strong>virtual directory</strong> pointing to <strong>#getTranslatedPath(expandPath("/farcry/core/admin"))#</strong>)</dd>
								<dd>/css</dd>	
								<dd>/files</dd>
								<dd>/images</dd>
								<dd>etc...</dd>
							</dl>
						</p>
						<cfif arguments.appMapping EQ "/">
							<p>
								It is noted that you haven't set a value for 'Project Web Mapping', if you are running off a sub-directory
								this value will most likely need to be #getProjectName()#
							</p>
						</cfif>
						<p>Note that if you currently have network security in place, this may prevent Farcry from validating an installation. Please check your security settings.</p>
						<p>See the installation guide for further information, or try the following for online documentation:</p>
						<ul>
							<li><a href="http://www.farcrycms.org/" title="farcrycms.org" target="_blank">farcrycms.org</a></li>
							<li><a href="http://docs.farcrycms.org:8080/confluence/" title="FarcryCMS developer WIKI" target="_blank">Developer WIKI</a></li>
						</ul>
						<p><a href="##" onclick="history.back();"><-- Back to the installation form</a></p>
					</cfoutput>
				</cfsavecontent>
				<cfset stWebtop.description = sDescription />
				<cfset setErrors(stWebtop) />
			</cfcatch>
		</cftry>
		
		<cfreturn bSuccess />		
		
	</cffunction>	
	
		
	
	<!--- display for any errors generated during the flight check --->
	<cffunction name="displayErrors" access="public" returntype="string" output="false" hint="Returns HTML output for error display">
		<cfargument name="aErrors" required="false" type="array" hint="You may pass in your own array for display, needs to be single dimension holding a struct in each element" />
		
		<cfset sErrors = "" />
		
		<cfif NOT isDefined("arguments.aErrors")>
			<cfset arguments.aErrors = getErrors() />
		</cfif>
		
		<cfsavecontent variable="sErrors">
			<cfoutput>
			<dl class="error">
				<cfloop from="1" to="#arrayLen(arguments.aErrors)#" index="i">
					<dt>#arguments.aErrors[i].title#</dt>
					<dd>#arguments.aErrors[i].description#</dd>
				</cfloop>
			</dl>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn sErrors />
	
	</cffunction>		
	
	
	
	<cffunction name="getFarcryMapping" access="public" returntype="boolean" output="false" hint="Get the /farcry mapping path in CFAM, return empty string if not found">
		
		<cfset var bFarcryMapping = 1 />
		
		<cftry>
			<cfinclude template="/farcry/core/admin/ping/index.cfm" />
			
			<cfcatch type="missingInclude">
				<!--- /farcry mapping not found or incorrect --->
				<cfset bFarcryMapping = 0 />
			</cfcatch>
		</cftry>
			
		<cfreturn bFarcryMapping />
		
	</cffunction>
	
	
	
	<cffunction name="preFlightCheck" access="public" returntype="boolean" output="false" hint="Check for all relevant directories before accessing the installation form">
		
		<cfset var bSuccess = 0 />
		<cfset var a = 1 />
		<cfset var b = 1 />
		<cfset var c = 1 />
		<cfset var d = 1 />
		<cfset var e = 1 />
		<cfset var f = 1 />

		<cfscript>
			a = checkFarcryCore();
			
			if (a)
			{
				b = checkColdFusionVersion();
			}
				
			if (a AND b)
			{
				c = checkFarcryPlugin();
			}
			
			if (a AND b AND c)
			{
				d = checkProjectName(getProjectName());
			}	
			
			// CANT CHECK FOR cgi.server_name as this doesnt work on some machines.
			//if (a AND b AND c AND d)
			//{
			//	e = checkWebtop(serverName=cgi.server_name, farcryMapping="#getProjectSubDirectory()#/farcry", appMapping=getProjectSubDirectory());
				
			//}
			
			if (a AND b AND c AND d)
			{
				f = checkPhyDirName(getProjectName(), getProjectSubDirectory());
			}					
			
			//check whether an error was thrown
			bSuccess = a AND b AND c AND d AND e AND f;
			
			return bSuccess;
		</cfscript>
	
	</cffunction>
	
	
	
	<cffunction name="postFlightCheck" access="public" returntype="boolean" output="false" hint="Check for all post install form entries and paths">
		<cfargument name="args" type="struct" required="true" hint="Structure of arguments, should default to form" />
		
		<cfset var bSuccess = 0 />
		<cfset var a = 1 />
		<cfset var b = 1 />
		<cfset var c = 1 />
		<cfset var d = 1 />
		<cfset var e = 1 />
		
		<cfscript>
			a = checkFarcryProject(arguments.args.siteName, arguments.args.appMapping);
			
			if (a)
			{
				b = checkWebMapping("#arguments.args.domain#", "#arguments.args.appMapping#");
			}
			
			if (a AND b)
			{
				c = checkWebtop(serverName=arguments.args.domain, farcryMapping=arguments.args.farcryMapping, appMapping=arguments.args.appMapping);
			}
			
			if (a AND b AND c)
			{
				d = checkDSN(arguments.args.appDSN);
			}
			
			if (a AND b AND c AND d)
			{
				e = checkExistingDatabase(arguments.args.appDSN);	
			}				
			
			//check whether an error was thrown
			bSuccess = a AND b AND c AND d AND e;
		</cfscript>

		<cfreturn bSuccess />
	
	</cffunction>	



	<cffunction name="validate" access="public" returntype="boolean" output="false" hint="Validate for all post install form entries.">
		<cfargument name="args" type="struct" required="true" hint="Structure of arguments to validate, should default to form" />
		
		<cfset var bSuccess = 1 />
		<cfset var stSiteName = structNew() />
		<cfset var stDSN = structNew() />
		<cfset var stDBType = structNew() />
		<cfset var stAppMapping = structNew() />
		<cfset var stFarcryMapping = structNew() />


		<cfif isDefined("arguments.args")>
			<!--- make sure an args struct was passed --->
		
			<!--- short cut, perform all validation in this method instead of having a method for each validation requirement :( --->
			
			<!--- dsn --->
			<cfif NOT len(trim(arguments.args.appDSN))>
				<cfset bSuccess = 0 />
				<cfset stDSN.title = "DSN" />
				<cfset stDSN.description = "<p>Please enter a DSN</p>" />
				<cfset setErrors(stDSN) />
			<cfelseif (REFind("[^a-zA-Z0-9\_]", arguments.args.appDSN)) OR isNumeric(left(arguments.args.appDSN, 1))>
				<cfset bSuccess = 0 />
				<cfset stDSN.title = "DSN naming" />
				<cfset stDSN.description = "<p>Your DSN <em>#arguments.args.appDSN#</em> must be [a-zA-Z0-9_] (no hypen).</p><p>Note that the DSN cannot start with an integer.</p>" />
				<cfset setErrors(stDSN) />
			</cfif>
			<!--- DBType --->
			<cfif NOT len(trim(arguments.args.dbType))>
				<cfset bSuccess = 0 />
				<cfset stDBType.title = "Database Type" />
				<cfset stDBType.description = "<p>Please select a database type</p>" />
				<cfset setErrors(stDBType) />
			<cfelseif arguments.args.dbType EQ "odbc" AND arguments.args.dbOwner NEQ "dbo.">
				<cfset bSuccess = 0 />
				<cfset stDBType.title = "Database Type" />
				<cfset stDBType.description = "<p>For MSSQL please make sure the database owner is 'dbo.'</p>" />
				<cfset setErrors(stDBType) />
			</cfif>
			<!--- if mysql, run further validation if the DSN is already valid --->
			<cfif bSuccess AND arguments.args.dbType EQ "mysql">
				<cfif NOT validateMySQL(arguments.args.appDSN)>
					<cfset bSuccess = 0 />
				</cfif>
			</cfif>
			<!--- farcry web mapping --->
			<cfif NOT len(trim(arguments.args.farcryMapping))>
				<cfset bSuccess = 0 />
				<cfset stFarcryMapping.title = "Farcry Web Mapping" />
				<cfset stFarcryMapping.description = "<p>Please enter a farcry web mapping</p>" />
				<cfset setErrors(stFarcryMapping) />
			</cfif>
		
		<cfelse>
		
			<cfset bSuccess = 0 />
		
		</cfif>
		
		<cfreturn bSuccess />
		
	</cffunction>
	
	
	
	<cffunction name="validateMySQL" access="public" returntype="boolean" output="false" hint="Check if mysql check privledges are set correctly">
		<cfargument name="dsn" required="true" type="string" hint="DSN to test MySQL permissions" />
	
		<cfset var bSuccess = 1 />
		<cfset var stMySQL = structNew() />
		<cfset var sDescription = "" />
		
		<cftry>
			
			<!--- delete temp table --->
			<cfquery name="qDeleteTemp" datasource="#arguments.dsn#">
				DROP TABLE IF EXISTS tblTemp1
			</cfquery>
			
			<cfcatch type="database">
				<cfset bSuccess = 0 />
				<cfset stMySQL.title = "MySQL access" />
				<cfsavecontent variable="sDescription">
					<cfoutput>
					<p>Error in accessing your MySQL database, please check your datasource (#arguments.dsn#)</p>
					<p>Are you sure:</p>
					<ul>
						<li>Verified your DSN in ColdFusion administrator?</li>
						<li>You are using a MySQL database?</li>
						<li>Have you checked your database owner?</li>
						<li>Selected the correct DSN on the Farcry installation form?</li>
					</ul>
					</cfoutput>
				</cfsavecontent>
				<cfset stMySQL.description = sDescription />
				<cfset setErrors(stMySQL) />
			</cfcatch>
			
		</cftry>
		
		<cfif bSuccess>
			<cftry>
				
				<!--- test temp table creation --->
				<cfquery name="qTestPrivledges" datasource="#arguments.dsn#">
					create temporary table tblTemp1
					(
					test  VARCHAR(255) NOT NULL
					)
				</cfquery>
							
				<cfcatch type="database">
					<cfset bSuccess = 0 />
					<cfset stMySQL.title = "MySQL permissions" />
					<cfset stMySQL.description = "<p>You need to have Create_tmp_table_priv privilege set to true for your MySQL user</p>" />
					<cfset setErrors(stMySQL) />
				</cfcatch>
				
			</cftry>
		</cfif>
		
		<cfreturn bSuccess />
	
	</cffunction>


	
	<!---
	ACCESSORS
	--->
	<cffunction access="public" name="setErrors" output="false" returntype="void" hint="Sets an array of error structs">
		<cfargument name="stErrors" type="struct" required="true" />
		
		<cfscript>
			arrayAppend(variables.instance.aErrors, arguments.stErrors);
		</cfscript>
				
	</cffunction>
		
	<cffunction access="public" name="getErrors" output="false" returntype="array" hint="Returns an array of error structs">
		
		<cfreturn variables.instance.aErrors />
		
	</cffunction>


	<cffunction access="public" name="getProjectName" output="false" returntype="string" hint="Returns the name of the users project">
		
		<cfset var siteName = "" />
		<cfset var iTokenPosition = 0 />
		
		<cftry>
			<!--- we want to hard code the application name (coming from the project directory name) for the user --->
			<cfset siteName = expandPath("*") />
			<cfset siteName = replaceNoCase(siteName, "\", "/", "All") /><!--- make all slashes forward to counter different OS' --->
			<cfset iTokenPosition = findNoCase("/www/install", siteName) /><!--- /www/install will always be there, find it to remove it --->
			<cfset siteName = left(siteName, iTokenPosition-1) />
			<cfset siteName = listLast(siteName, "/") /><!--- grab the project directory name to pre-populate --->

			<cfcatch>
				<!--- unable to determine sitename; may be installed from a web virtual --->
				<cfset siteName = "" />
			</cfcatch>
		</cftry>
		
		<cfreturn siteName />
		
	</cffunction>
	
	
	<cffunction access="public" name="getProjectSubDirectory" output="false" returntype="string" hint="Returns the name of the users project sub-directory">
		
		<cfset var sReturn = "" />
		<cfset var subDir = "" />
		<cfset var iTokenPosition = 0 />
		
		<!--- we want to hard code the application name (coming from the project directory name) for the user --->
		<cfset subdir =replacenocase(cgi.SCRIPT_NAME,"/index.cfm","","all") />
		<cfset subDir = replaceNoCase(subDir, "\", "/", "All") /><!--- make all slashes forward to counter different OS' --->
		<cfset iTokenPosition = findNoCase("/install", subDir) /><!--- /www/install will always be there, find it to remove it --->
		<cfif iTokenPosition GT 1>
			<cfset sReturn = left(subDir, iTokenPosition-1) />
		</cfif>		
		
		<cfreturn sReturn />
		
	</cffunction>
		

	<cffunction access="public" name="getTranslatedPath" output="false" returntype="string" hint="Returns the result of an OS specific expandPath(), with either forward or back slashed">
		<cfargument name="sPath" type="string" required="true" hint="Path to translate" /> 	
		
		<cfset var sReturn = arguments.sPath />
		
		<cfif find("\", sReturn)>
		
			<cfset sReturn = replace(sReturn, "/", "\", "All") />
		
		</cfif>

		<cfreturn sReturn />
	
	</cffunction>


</cfcomponent>