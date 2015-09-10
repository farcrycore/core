<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!--- @@description: Application initialisation. --->
<cfcomponent displayname="Application" output="false" hint="Core Application.cfc.">

	
	
	<!--- 
	IF WE HAVE RECEIVED A PING TO CHECK FOR FRIENDLY URL's SEND BACK A RESPONSE.
	THIS MUST BE DONE OUTSIDE OF THE APPLICATION AS IT MAY BE CALLED BEFORE THE APPLICATION IS INITIALISED
	 --->
	<cfif structKeyExists(url, "furl") AND url.furl EQ "/pingFU">				
		<cfcontent type="text/plain" variable="#ToBinary( ToBase64('PING FU SUCCESS') )#" reset="Yes">
	</cfif>
	
	
	<!--- run the active project's constructor --->
	<cfset this.projectConstructorLocation = getProjectConstructorLocation(plugin="webtop") />
	<cfinclude template="#this.projectConstructorLocation#" />


	<!--- set up the farcry dsn from the environment --->
	<cfif structKeyExists(THIS, "bUseEnv") AND THIS.bUseEnv eq "true">
		<cfset system = createObject("java", "java.lang.System")>

		<cfloop array="#['', '_READ', '_WRITE']#" index="key">
			<cfset FARCRY_DSN = "" & system.getEnv("FARCRY_DSN" & key)>

			<cfif len(FARCRY_DSN)>

				<!--- set the farcry dsn, dbtype and dbowner --->
				<cfset THIS["dsn" & key] = FARCRY_DSN /> 
				<cfset FARCRY_DBTYPE = system.getEnv("FARCRY_DBTYPE" & key)>
				<cfif NOT isNull(FARCRY_DBTYPE)>
					<cfset THIS["dbType" & key] = FARCRY_DBTYPE>
				</cfif>
				<cfset FARCRY_DBOWNER = system.getEnv("FARCRY_DBOWNER" & key)>
				<cfif NOT isNull(FARCRY_DBOWNER)>
					<cfset THIS["dbOwner" & key] = FARCRY_DBOWNER>
				</cfif>

				<!--- set up the datasource settings --->
				<cfset this.datasources[FARCRY_DSN] = {
					"class" = system.getEnv("FARCRY_DSN#key#_CLASS"),
					"connectionString" = system.getEnv("FARCRY_DSN#key#_CONNECTIONSTRING"),
					"database" = system.getEnv("FARCRY_DSN#key#_DATABASE"),
					"driver" = system.getEnv("FARCRY_DSN#key#_DRIVER"),
					"host" = system.getEnv("FARCRY_DSN#key#_HOST"),
					"port" = system.getEnv("FARCRY_DSN#key#_PORT"),
					"type" = system.getEnv("FARCRY_DSN#key#_TYPE"),
					"url" = system.getEnv("FARCRY_DSN#key#_URL"),
					"username" = system.getEnv("FARCRY_DSN#key#_USERNAME"),
					"password" = system.getEnv("FARCRY_DSN#key#_PASSWORD")
				}>

				<!--- set custom options when not using a connection string --->
				<cfset FARCRY_DSN_CUSTOM = system.getEnv("FARCRY_DSN#key#_CUSTOM")>
				<cfif NOT isNull(FARCRY_DSN_CUSTOM) AND len(FARCRY_DSN_CUSTOM)>
					<cfif isJSON(FARCRY_DSN_CUSTOM)>
						<cfset this.datasources[FARCRY_DSN].custom = deserializeJSON(FARCRY_DSN_CUSTOM)>
					<cfelse>
						<cfset stCustom = {}>
						<cfloop list="#FARCRY_DSN_CUSTOM#" index="item" delimiters="&">
							<cfset stCustom[listFirst(item, "=")] = listRest(item, "=")>
						</cfloop>
						<cfset this.datasources[FARCRY_DSN].custom = stCustom>
					</cfif>
				</cfif>

				<!--- set linked db hostname/port using the provided alias --->
				<cfset FARCRY_DB_LINK_ALIAS = system.getEnv("FARCRY_DB#key#_LINK_ALIAS")>
				<cfif NOT isNull(FARCRY_DB_LINK_ALIAS) AND len(FARCRY_DB_LINK_ALIAS)>
					<cfset DB_PORT = system.getEnv(ucase(FARCRY_DB_LINK_ALIAS) & "_PORT")>
					<cfif NOT isNull(DB_PORT) AND len(DB_PORT)>
						<cfset this.datasources[FARCRY_DSN].host = listFirst(listLast(DB_PORT, "/"), ":")>
						<cfset this.datasources[FARCRY_DSN].port = listLast(listLast(DB_PORT, "/"), ":")>
					</cfif>
				</cfif>

			</cfif>
		</cfloop>
	</cfif>


	<cfparam name="this.botDetection" default="true" />
	<cfif this.botDetection>
		<!--- Bot detection values --->
		<cfparam name="this.botAgents" default="*" />
		<cfparam name="this.botIPs" default="*" />
		
		
		<cfset this.defaultAgents = "bot\b,\brss,slurp,mediapartners-google,googlebot,bingbot,zyborg,emonitor,jeeves,sbider,findlinks,yahooseeker,mmcrawler,jbrowser,java,pmafind,blogbeat,converacrawler,ocelli,labhoo,validator,sproose,ia_archiver,larbin,psycheclone,arachmo" />
		<cfset this.botAgents = __plusMinusStateMachine(this.defaultAgents, this.botagents) />
		
		<cfset this.defaultIPs = "" />
		<cfset this.botIPs = __plusMinusStateMachine(this.defaultIPs, this.botIPs) />
		
		<cfparam name="cookie.sessionScopeTested" default="false" />
		<cfparam name="cookie.hasSessionScope" default="false" />
		<cfif not len(cgi.http_user_agent) or (cookie.sessionScopeTested and not cookie.hasSessionScope) or reFindAny(this.botAgents,lcase(cgi.HTTP_USER_AGENT)) or arrayFind(this.botIPs,cgi.remote_addr)>
			<cfset THIS.sessiontimeout = createTimeSpan(0,0,0,2) />
			<cfset request.fc.hasSessionScope = false />
			
			<cfif not cookie.sessionScopeTested>
				<cftry>
					<cfcookie name="sessionScopeTested" value="true" expires="never" />
					<cfcookie name="hasSessionScope" value="false" expires="never" />
					<cfcatch></cfcatch>
				</cftry>
			</cfif>
		<cfelse>
			<cfset request.fc.hasSessionScope = true />
			
			<cfif not cookie.sessionScopeTested><!--- Sessions are OK for this user, set the cookie --->
				<cftry>
					<cfcookie name="sessionScopeTested" value="true" expires="never" />
					<cfcookie name="hasSessionScope" value="true" expires="never" />
					<cfcatch></cfcatch>
				</cftry>
			</cfif>
		</cfif>
	<cfelse>
		<cfset request.fc.sessionScopeTested = true />
		<cfset request.fc.hasSessionScope = true />
	</cfif>
	
	
	<!--- ////////////////////////////////////////////// --->
	
	<!---
		This function can be used to create an array from a string (list) and
		also change the contents of that string (list).  The first parameter
		is a list of default items "one,two,three", and the second parameter
		is a command list of operations to perform on that list. The command
		list can look like the following:  "*:-one,three:+six,four"
		
		This will return the array "[two,six,four]". The command string is made
		of the following operators:
			
			*  = add everything from the first paramter
			+  = do an addition
			-  = do a subtraction
			-* = remove all of the default items
	--->
	<cffunction name="__plusMinusStateMachine" returntype="array" output="false">
		<cfargument name="asteriskDefaults" type="string" required="true" />
		<cfargument name="stateCommandString" type="string" required="true" />
		
		<cfset var z = 0 />
		<cfset var q = 0 />
		<cfset var commandString = "" />
		<cfset aStates = arrayNew(1) />
		<cfset sStates = "" />
		<cfset returnArray = arrayNew(1) />
		
		
		<cfset aStates = listToArray(arguments.stateCommandString, ":") />
		
		<!--- 
			The reason this gets a bit complicated is to be backwards compatable. 
			If they just passed a string like "+one,two,three" we'll assume they want
			the core default agents, and want to add to them. --->
		<cfif not len(stateCommandString) or left(stateCommandString, 1) eq "+">
			<cfset sStates = arguments.asteriskDefaults />
		<cfelse>
			<cfset sStates = "" />
		</cfif>
		
		<!--- Loop over the agent addition, subtraction or all commands
			and build the string of default agents --->
		<cfloop from="1" to="#arrayLen(aStates)#" index="z">
			<cfset commandString = aStates[z] />
			
			<!--- Add agents to the list --->
			<cfif left(commandString,1) eq "+">
				<cfset sStates = sStates & "," & mid(commandString,2,len(commandString)) />
			
			<!--- do and "Add all" - basically add in all the defaults
				from core (defined above as this.defaultAgents) --->
			<cfelseif commandString eq "*">
				<cfset sStates = sStates & "," & arguments.asteriskDefaults />
			
			<!--- remove either single agents or remove all the core defaults--->
			<cfelseif left(commandString,1) eq "-">
				<!--- if they do "-*" we'll remove all the default bots --->
				<cfif left(commandString,2) eq "-*">
					<cfset sStates = "" />
				<cfelse>
					<!--- otherwise they are doing a "-java,jeeves" kind of string --->
					<cfset returnArray = listToArray(sStates) />
					
					<cfset removeArray = listToArray(mid(commandString,2,len(commandString))) /> 
					<cfloop from="1" to="#arrayLen(removeArray)#" index="q">
						<cfset returnArray.remove(removeArray[q]) />
					</cfloop>
					
					<!--- put this back into a list incase they do more commands to the list --->
					<cfset sStates = arrayToList(returnArray) />
				</cfif>
			</cfif>
		</cfloop>
		
		<!--- Ok, we should have a built up string, turn it into 
			an array for later usage--->
		<cfset returnArray = listToArray(sStates) />
		
		<cfreturn returnArray />
	</cffunction>
	
	
	<cffunction name="reFindAny" access="private" output="false" returntype="boolean" hint="Looks for any of an array of regular expressions in a string">
		<cfargument name="needle" type="array" required="true" hint="The array of regular expressions to find" />
		<cfargument name="haystack" type="string" required="true" hint="The string to match against" />
		
		<cfset var i = 0 />
		
		<cfloop from="1" to="#arraylen(arguments.needle)#" index="i">
			<cfif refind(arguments.needle[i],arguments.haystack)>
				<cfreturn true />
			</cfif>
		</cfloop>
		
		<cfreturn false />
	</cffunction>
	
	
	<cffunction name="OnApplicationStart" access="public" returntype="boolean" output="false" hint="Fires when the application is first created.">

		<cfset var qServerSpecific = queryNew("blah") />
		<cfset var qServerSpecificAfterInit = queryNew("blah") />
		<cfset var machineName = "localhost" />
		<cfset var tickBegin = getTickCount() />
		<cfset var typename = "" />
		
		<cftry>
			<cfset machineName = createObject("java", "java.net.InetAddress").localhost.getHostName() />
			
			<cfcatch></cfcatch>
		</cftry>

		<!--- intialise application scope --->
		<cfset initApplicationScope() />
		
		<!----------------------------------- 
		CALL THE PROJECTS SERVER SPECIFIC VARIABLES
		 ----------------------------------->
		<cfinclude template="/farcry/projects/#application.projectDirectoryName#/config/_serverSpecificVars.cfm" />
		
		<!--- Add Server Specific Request Scope files --->
		<cfif directoryExists("#application.path.project#/config/#machineName#")>
			<cfif fileExists("#application.path.project#/config/#machineName#/_serverSpecificVars.cfm")>
				<cfinclude template="/farcry/projects/#application.projectDirectoryName#/config/#machineName#/_serverSpecificVars.cfm" />
			</cfif>
		</cfif>
		
		
		<!----------------------------------- 
		INITIALISE THE REQUESTED PLUGINS
		 ----------------------------------->
		<cfif isDefined("application.plugins")>
			<cfloop list="#application.plugins#" index="plugin">
				<cfif fileExists("#application.path.plugins#/#plugin#/config/_serverSpecificVars.cfm")>
					<cfinclude template="/farcry/plugins/#plugin#/config/_serverSpecificVars.cfm" />
				</cfif>
			</cfloop>
		</cfif>


		<!----------------------------------------
		 LOCALES
		 - Append Locales currently used in the project
		----------------------------------------->
		<cfswitch expression="#application.dbtype#">
			<cfdefaultcase>
				<cfquery datasource="#application.dsn_read#" name="qProfileLocales">
				SELECT distinct(locale) as locale
				from #application.dbowner#dmProfile
				</cfquery>
				
				<cfif qProfileLocales.recordCount>
					<cfloop query="qProfileLocales">
						<cfif not listFindNoCase(application.locales, qProfileLocales.locale)>
							<cfset application.locales = listAppend(application.locales,qProfileLocales.locale) />
						</cfif>
					</cfloop>
				</cfif>
			</cfdefaultcase>
		</cfswitch>
		

		<!---------------------------------------------- 
		INITIALISE THE COAPIADMIN SINGLETON
		----------------------------------------------->
		<cfset application.coapi.coapiadmin = createObject("component", "farcry.core.packages.coapi.coapiadmin").init() />
		
	
		<!--------------------------------- 
		FARCRY CORE INITIALISATION
		 --------------------------------->
		<cfinclude template="/farcry/core/tags/farcry/_farcryApplicationInit.cfm" />
		
		<cfset application.fc.lib.objectbroker.init() />
		<cfloop collection="#application.stcoapi#" item="typename">
			<cfif application.stcoapi[typename].bObjectBroker>
				<cfset application.fc.lib.objectbroker.configureType(typename=typename, MaxObjects=application.stcoapi[typename].ObjectBrokerMaxObjects) />
			</cfif>
		</cfloop>
		<cfset application.fc.lib.objectbroker.configureType("config", 100) />
		<cfset application.fc.lib.objectbroker.configureType("navid", 1) />
		<cfset application.fc.lib.objectbroker.configureType("catid", 1) />
		<cfset application.fc.lib.objectbroker.configureType("fuLookup", 10000) />

		<!----------------------------------- 
		SETUP CATEGORY APPLICATION STRUCTURE
		 ----------------------------------->
		<cfquery datasource="#application.dsn#" name="qCategories">
		SELECT objectid, categoryLabel
		FROM #application.dbowner#dmCategory
		</cfquery>
		
		<cfparam name="application.catid" default="#structNew()#" />
		<cfloop query="qCategories">
			<cfset application.catID[qCategories.objectid] = qCategories.categoryLabel />
		</cfloop>


		<!-------------------------------------------------------
		Scheduled Tasks
			- add missing tasks to the app server cron jobs table
			- only picks up tasks that are set to auto-start
		-------------------------------------------------------->
		<cftry>
			<cfset application.fapi.getContentType(typename="dmcron").addMissingJobs()>
			<cfcatch>
			<!--- fails if bAutoStart property has not been deployed; remove legacy entries --->
			<cfset application.fapi.getContentType(typename="dmcron").removeLegacyJobs()>			
			</cfcatch>
		</cftry>


		<!----------------------------------- 
		CALL THE PLUGINS AFTER INIT VARIABLES
		 ----------------------------------->
		<cfif isDefined("application.plugins")>
			<cfloop list="#application.plugins#" index="plugin">
				<cfif fileExists("#application.path.plugins#/#plugin#/config/_serverSpecificVarsAfterInit.cfm")>
					<cfinclude template="/farcry/plugins/#plugin#/config/_serverSpecificVarsAfterInit.cfm">
				</cfif>
			</cfloop>
		</cfif>
		
		
		<!----------------------------------- 
		CALL THE PROJECTS AFTER INIT VARIABLES
		------------------------------------>
		<cfif fileExists("#application.path.project#/config/_serverSpecificVarsAfterInit.cfm") >
			<cfinclude template="/farcry/projects/#application.projectDirectoryName#/config/_serverSpecificVarsAfterInit.cfm" >
		</cfif>


		<!----------------------------------- 
		ADD SERVER SPECIFIC AFTER INIT VARIABLES
		------------------------------------>
		<cfif directoryExists("#application.path.project#/config/#machineName#")>
			<cfif fileExists("#application.path.project#/config/#machineName#/_serverSpecificVarsAfterInit.cfm")>
				<cfinclude template="/farcry/projects/#application.projectDirectoryName#/config/#machineName#/_serverSpecificVarsAfterInit.cfm" />
			</cfif>
		</cfif>


		<!----------------------------------- 
		APPLICAION UPTIME INFO
		------------------------------------>
		<cfif not isdefined("application.fcstats.updateapp") or not isquery(application.fcstats.updateapp)>
			<cfparam name="application.fcstats" default="#structnew()#" />
			<cfset application.fcstats.updateapp = querynew("when,howlong","time,bigint") />
		</cfif>
		<cfset queryaddrow(application.fcstats.updateapp) />
		<cfset querysetcell(application.fcstats.updateapp,"when",now()) />
		<cfset querysetcell(application.fcstats.updateapp,"howlong",getTickCount()-tickBegin) />
		
		<cfset application.bInit = true />
		<cfreturn true />

	</cffunction>
 

	<cffunction name="OnSessionStart" access="public" returntype="void" output="false" hint="Fires when the session is first created.">
		
		<cfset session.fc = structNew() />
		
		<cfreturn />
	</cffunction>

 
	<cffunction name="OnRequestStart" access="public" returntype="boolean" output="false" hint="Fires at first part of page processing.">
		<cfargument name="TargetPage" type="string" required="true" />

		<!--- If a session switch was requested, do that now --->
		<cfif structKeyExists(url, "switchsession")>
			<cfset application.fc.lib.session.switchSession(url.switchsession) />
			<cfif not find(cgi.script_path, application.url.webtop) or application.security.checkPermission(permission="admin")>
				<cflocation url="#application.fapi.fixURL(removevalues='switchsession')#" addtoken="false" />
			<cfelse>
				<cflocation url="#application.url.webroot#/" addtoken="false" />
			</cfif>
		<cfelseif structKeyExists(url, "endsession")>
			<cfset application.fc.lib.session.endSession(url.endsession) />
			<cflocation url="#application.fapi.fixURL(removevalues='endsession')#" addtoken="false" />
		</cfif>

		<!--- Setup FarCry Namespace in the request scope --->
		<cfparam name="request.fc" default="#structNew()#" />

		<cfif isdefined("session")>
			<cfparam name="session.fc" default="#structNew()#" />
		</cfif>
		
		<!--- Update the farcry application if instructed --->
		<cfset farcryUpdateApp() />		
		
		<!--- Initialize the request as a farcry application --->
		<cfset farcryRequestInit() />
	
		
		<!---
		SHARED WEBTOP LOGIN 
		This sets up a cookie on the users system so that if they try and login to
		the webtop and the webtop can't determine which project it is trying to update,
		it will know what projects they will be potentially trying to edit.  
		--->
		<cfparam name="server.stFarcryProjects" default="#structNew()#" />
		<cfif not structKeyExists(server.stFarcryProjects, application.projectDirectoryName) or not isstruct(server.stFarcryProjects[application.projectDirectoryName])>
			<cfset server.stFarcryProjects[application.projectDirectoryName] = structnew() />
			<cfset server.stFarcryProjects[application.projectDirectoryName].displayname = application.displayName />
			<cfset server.stFarcryProjects[application.projectDirectoryName].domains = "" />
		</cfif>
		<cfif not listcontains(server.stFarcryProjects[application.projectDirectoryName].domains,cgi.http_host)>
			<cfset server.stFarcryProjects[application.projectDirectoryName].domains = listappend(server.stFarcryProjects[application.projectDirectoryName].domains,cgi.http_host) />
		</cfif>
		<cfset cookie.currentFarcryProject = application.projectDirectoryName />	
	
		<!--- Checks to see if the user has attempted to flick over to administrate a different project on this server. --->		
		<cfif 	structKeyExists(url, "farcryProject") 
				AND len(url.farcryProject) 
				AND structKeyExists(server, "stFarcryProjects") 
				AND structKeyExists(cookie, "currentFarcryProject") 
				AND structKeyExists(server.stFarcryProjects, url.farcryProject) 
				AND cookie.currentFarcryProject NEQ url.farcryProject>
					
					<cfset cookie.currentFarcryProject = url.farcryProject />
					<cflocation url="#cgi.SCRIPT_NAME#?#cgi.query_string#" addtoken="false" />
		</cfif>
		
		<cfif isdefined("session")>
			<cfparam name="session.loginReturnURL" default="#application.url.webroot#" />
			
			<cfif structKeyExists(url, "returnURL") AND len(url.returnURL)>
				<cfset session.loginReturnURL = application.fapi.fixURL(url.returnURL) />
			</cfif>
		</cfif>
		
		<!--- Hookup any functions here we want available to Farcry. --->
		<cfset request.__plusMinusStateMachine = this.__plusMinusStateMachine />
		
		
		<cfreturn true />
	</cffunction>
 

	<cffunction name="OnRequestEnd" access="public" returntype="void" output="false" hint="Fires after the page processing is complete.">

		<!--- if we are in the middle of a <skin:location> or we failed to init then we dont want to process onRequestEnd --->
		<cfif not structKeyExists(request.fc, "bLocating") and not structKeyExists(request,"fcInitError")>

			<!--- project and plugin request processing --->
			<cfif isdefined("application.sysinfo.aOnRequestEnd") and arraylen(application.sysinfo.aOnRequestEnd)>
				<cfloop from="1" to="#arraylen(application.sysinfo.aOnRequestEnd)#" index="i">
					<cfinclude template="#application.sysinfo.aOnRequestEnd[i]#" />
				</cfloop>
			</cfif>

			<cfinclude template="/farcry/core/tags/farcry/_farcryOnRequestEnd.cfm">

		</cfif>

		<cfreturn />
	</cffunction>

 
	<cffunction name="OnSessionEnd" access="public" returntype="void" output="false" hint="Fires when the session is terminated.">
		<cfargument name="SessionScope" type="struct" required="true" />
		<cfargument name="ApplicationScope" type="struct" required="false" default="#StructNew()#" />
 
		<cfreturn />
	</cffunction>

 
	<cffunction name="OnApplicationEnd" access="public" returntype="void" output="false" hint="Fires when the application is terminated.">
		<cfargument name="ApplicationScope" type="struct" required="false" default="#StructNew()#" />

		<cfreturn />
	</cffunction>


	<cffunction name="OnError" access="public" returntype="void" output="true" hint="Fires when an exception occures that is not caught by a try/catch.">
		<cfargument name="Exception" type="any" required="true" />
		<cfargument name="EventName" type="string" required="false" default="" />
		
		<cfset var stException = structnew() />
		<cfset var oError = "" />

		<!--- increase the request timeout a little, in case the error was caused by a request timeout --->
		<cfif structkeyexists(server,"railo")>
			<cfsetting requesttimeout="#getPageContext().getRequestTimeout() + 10000#" />
		<cfelseif structkeyexists(server,"coldfusion")>
			<cfsetting requesttimeout="#CreateObject("java", "coldfusion.runtime.RequestMonitor").GetRequestTimeout() + 10#" />
		</cfif>
		
		<cfif isdefined("application.fc.lib.error")>
			<cfset oError = application.fc.lib.error />
		<cfelse>
			<cfset oError = createobject("component","farcry.core.packages.lib.error") />
		</cfif>
		
		<cfset stException = oError.normalizeError(arguments.exception) />
		
		<cfset oError.logData(stException) />
		
		<!--- Email error --->
		<cfif isdefined("application.fapi") and application.fapi.getConfig("general","bEmailErrors",true) and len(application.fapi.getConfig("general","errorEmail","")) and len(application.fapi.getConfig("general","adminEmail",""))>
			<cfmail to="#application.fapi.getConfig("general","errorEmail","")#" from="#application.fapi.getConfig("general","adminEmail","")#" subject="#application.applicationname#: #stException.message# (#stException.bot#)" type="text/plain"><cfoutput>#oError.formatError(stException,"text")#</cfoutput></cfmail>
		</cfif>
		
		<cfset oError.showErrorPage("500 Internal Server Error",stException) />
		
		<cfreturn />
	</cffunction>
	
	
	<cffunction name="OnMissingTemplate" access="public" returntype="void" output="true" hint="Fires when a non-existent coldfusion file is requested">
		<cfargument name="thePage" type="string" required="true" />
		<cfargument name="message" type="string" required="false" default="Page does not exist" />
		
		<cfset var stException = structnew() />
		<cfset var oError = "" />
		
		<cfif isdefined("application.fc.lib.error")>
			<cfset oError = application.fc.lib.error />
		<cfelse>
			<cfset oError = createobject("component","farcry.core.packages.lib.error") />
		</cfif>
		
		<cfset oError.showErrorPage("404 Page missing",oError.create404Error(arguments.message)) />
		
		<cfreturn />
	</cffunction>
	
	
	<cffunction name="farcryUpdateApp" access="private" output="false" hint="Initialise farcry Application." returntype="void">
		<!---------------------------------------- 
		BEGIN: Application Initialise 
		----------------------------------------->
		<cfset var oError = "" />

		<cfparam name="url.updateapp" default="" />
		
		<cftry>
		<!--- TODO: this needs to be removed eventually. It is currently only in here so that users can updateapp when they upgrade without having to recycle CF --->
		<cfparam name="application.updateappKey" default="1" />
		
		<cfif structkeyexists(url,"updateall")>
			<cfset url.updateapp = url.updateall />
		</cfif>
		
		<!--- determine if user has permission to perform updateapp; blocks potential denial of service attack --->
		<cfif len(url.updateapp)>
			<cfif url.updateapp EQ application.updateappKey>
				<!--- CAN FORCE AND UPDATE IF THE USER KNOWS THE updateappKey --->
				<cfset url.updateapp = true>
			<cfelse>		
				<cfif isBoolean(url.updateapp) AND ((isDefined("session.fc.mode.bAdmin") and session.fc.mode.bAdmin) OR (isDefined("session.dmSec.Authentication.bAdmin") and session.dmSec.Authentication.bAdmin))>
					<!--- ADMINISTRATORS CAN ALWAYS UPDATE APP WITH 1 --->
				<cfelse>
					<!--- Not an adminstrator and didnt know the updateappkey --->
					<cfset url.updateapp = false>
				</cfif>			
			</cfif>
		<cfelse>
			<cfset url.updateapp = false>
		</cfif>
		
		<cfif findNoCase('updateapp/#application.updateappKey#', cgi.query_string)>
			<!--- CAN FORCE AND UPDATE IF THE USER KNOWS THE updateappKey --->
			<cfset url.updateapp = true>
		</cfif>
		
		<!--- force application start sequence to be single threaded --->
		<cfif (NOT structkeyexists(application, "bInit") OR NOT application.binit) OR url.updateapp>
			<cflock name="#application.applicationName#_init" type="exclusive" timeout="3" throwontimeout="true">
				<cfif (NOT structkeyexists(application, "bInit") OR NOT application.binit) OR url.updateapp>

					<!--- set binit to false to block users accessing on restart --->
					<cfset application.bInit =  false />
					<cfset url.updateapp = true />
					<cfset OnApplicationStart() />
					
					<!--- If the updateall flag was on, we also need to deploy default schema updates --->
					<cfif structkeyexists(url,"updateall")>
						<cfset application.fc.lib.db.deployDefaultChanges() />
						<cfset application.fapi.getContentType(typename="fixRefObjects").fixReferences()>
					</cfif>
					
					<!--- set the initialised flag --->
					<cfset application.bInit = true />

				</cfif>
			</cflock>
		</cfif>
		
		<cfcatch type="lock">
			<cfset request.fcInitError = true />
			<cfset oError = createobject("component", "farcry.core.packages.lib.error") />
			<cfset request.error = oError.collectRequestInfo() />
			<cfset request.error.message = "Application Restarting" />
			<cfset oError.showErrorPage("503 Service Unavailable", request.error) />
			<cfabort />
		</cfcatch>
		
		<cfcatch type="any">
			<!--- remove binit to force reinitialisation on next page request --->
			<cfset structdelete(application,"bInit") />
			<cfset request.fcInitError = true />

			<!--- report error to user --->
			<cfset oError = createobject("component", "farcry.core.packages.lib.error") />
			<cfset request.error = oError.normalizeError(cfcatch) />
			<cfset oError.logData(request.error) />
			<cfset oError.showErrorPage("500 Internal Server Error", request.error) />
			<cfabort>
		</cfcatch>
		
		</cftry>
		<!---------------------------------------- 
		END: Application Initialise 
		----------------------------------------->

	</cffunction>


	<cffunction name="farcryRequestInit" access="private" output="false" hint="Initialise farcry Application." returntype="void">

		<!--- set the default request.mode struct --->
		<cfset application.security.defaultRequestMode() />

		<!---------------------------------------- 
		GENERAL APPLICATION REQUEST PROCESSING
		- formally /farcry/core/tags/farcry/_farcryApplication.cfm
		----------------------------------------->
		
		<!--- project and plugin request processing --->
		<cfset application.fapi.addProfilePoint("Request initialisation","Server specific request scope") />
		<cfif application.sysInfo.bServerSpecificRequestScope>
			<cfloop from="1" to="#arraylen(application.sysinfo.aServerSpecificRequestScope)#" index="i">
				<cfinclude template="#application.sysinfo.aServerSpecificRequestScope[i]#" />
			</cfloop>
		</cfif>
		
			
		<!--- PARSE THE URL CHECKING FOR FRIENDLY URLS (url.furl) --->
		<cfset application.fapi.addProfilePoint("Request initialisation","Parse URL") />
		<cfif refindnocase("/index.cfm$",cgi.script_name) and not refindnocase("^" & application.url.webtop,cgi.script_name)>
			<cfset structAppend(url, application.fc.factory.farFU.parseURL(),true) />
		</cfif>
		

		<!--- INITIALIZE THE REQUEST.MODE struct --->
		<cfset application.fapi.addProfilePoint("Request initialisation","Request modes") />
		<cfset application.security.initRequestMode() />
		
		<!----------------------------------------
		EVENT: URL logout
		----------------------------------------->
		<cfif isDefined("url.logout") and url.logout eq 1>
			<cfset application.security.logout() />
			<cflocation url="#application.fapi.fixURL(removevalues='logout')#" addtoken="false" />
		</cfif>
		
		
		<!--- This parameter is used by _farcryOnRequestEnd.cfm to determine which javascript libraries to include in the page <head> --->
		<cfparam name="Request.inHead" default="#structNew()#">
		
		
		<!--- IF the project has been set to developer mode, we need to refresh the metadata on each page request. --->
		<cfif request.mode.bDeveloper>
			<cfset application.fapi.addProfilePoint("Request initialisation","Developer: Refresh COAPI") />
			<cfset createObject("component","#application.packagepath#.farcry.alterType").refreshAllCFCAppData() />
		</cfif>

	</cffunction>

			
	
	<cffunction name="getProjectConstructorLocation" access="public" output="false" hint="Returns the location of the active project constructor." returntype="string">
		<cfargument name="plugin" type="string" hint="The name of the plugin.">
		<cfargument name="fileExtension" type="string" default="cfm" hint="'XML' if looking for the xml constructor override file">
		
		<cfset var loc = "" />
		<cfset var virtualDirectory = "" />
		
		<!--- strip the context path first (for J2EE deployments) --->
		<cfset var script_path = right( cgi.SCRIPT_NAME, len( cgi.SCRIPT_NAME ) - len( cgi.context_path ) )>

		<!--- Get the first directory after the url if there is one (ie. if its just index.cfm then we know we are just under the webroot) --->
		<cfif listLen(script_path, "/") GT 1>
			<cfset virtualDirectory = listFirst(script_path, "/") />
				
			<!--- If the first directory name is the same name as the plugin, then we assume we are running the project from the webroot --->
			<cfif virtualDirectory EQ arguments.plugin>
				<cfset virtualDirectory = "" />
			</cfif>					
		</cfif>

		<!--- If we ended up with a virtual directory we check to see if there is a farcryConstructor --->
		<cfif len(virtualDirectory) AND fileExists(expandPath("/#virtualDirectory#/farcryConstructor.#arguments.fileExtension#"))>
			<cfset loc = trim("/#virtualDirectory#/farcryConstructor.#arguments.fileExtension#") />

		<cfelseif fileExists(expandPath("/farcryConstructor.#arguments.fileExtension#"))>
			<!--- Otherwise we check in the webroot --->
			<cfset loc = trim("/farcryConstructor.#arguments.fileExtension#") />
		<cfelse>
			<!--- If all else fails... --->
			<!--- 1. See if the user has a cookie telling us what project to look at. --->
			<cfif structKeyExists(url, "farcryProject") AND len(url.farcryProject)>
				<cfset cookie.currentFarcryProject = url.farcryProject />
			</cfif>
			<cfif arguments.plugin EQ "webtop" AND structKeyExists(cookie, "currentFarcryProject")>
				<cfif fileExists(expandPath("/#currentFarcryProject#/farcryConstructor.#arguments.fileExtension#"))>
					<cfset loc = trim("/#currentFarcryProject#/farcryConstructor.#arguments.fileExtension#") />
				</cfif>
			</cfif>
			<!--- 2. If no cookie exists, see if server.stFarcryProjects holds any project names and list the first one found --->
			<cfif loc eq "" and arguments.plugin EQ "webtop" and structKeyExists(server, "stFarcryProjects") and structcount(server.stFarcryProjects) GT 0>
				<cfloop collection="#server.stFarcryProjects#" item="thisproject">
					<cfif fileExists(expandPath("/#thisproject#/farcryConstructor.#arguments.fileExtension#"))>
						<cfset loc = trim("/#thisproject#/farcryConstructor.#arguments.fileExtension#") />
						<cfbreak />
					</cfif>
				</cfloop>
			</cfif>
		</cfif>

		<cfif not len(loc) and arguments.fileExtension eq "cfm">				
			<cfif fileExists(expandPath("#cgi.context_path#/webtop/install/index.cfm"))>
				<cfset installLink = "#cgi.context_path#/webtop/install/index.cfm" />
			<cfelse>
				<cfset installLink = "#cgi.context_path#/farcry/core/webtop/install/index.cfm" />
			</cfif>

			<cflocation url="#installLink#" addtoken="false">
			
		</cfif>
	
		<cfreturn loc />
	</cffunction>


	<cffunction name="getPluginName" access="public" output="false" hint="Returns the name of this plugin; core returns 'farcry'." returntype="string">
		<cfreturn "farcry" />
	</cffunction>


	<cffunction name="detectDBType" access="private" output="false" hint="Detect the DB type of the available datasource">
		<cfargument name="dsn" type="string" required="false" default="#this.dsn#">

		<cfset var dbType = "">
		<cfset var stInfo = structNew()>

		<cfdbinfo name="stInfo" datasource="#arguments.dsn#" type="version">

		<cfswitch expression="#stInfo.database_productname#">
			<cfcase value="MySQL">
				<cfset dbType = "mysql">
			</cfcase>
			<cfcase value="Microsoft SQL Server">
				<cfif listFirst(stInfo.database_version, ".") gte 9>
					<cfset dbType = "mssql2005">
				<cfelse>
					<cfset dbType = "mssql">
				</cfif>
			</cfcase>
			<cfcase value="H2">
				<cfset dbType = "h2">
			</cfcase>
<!--- 
			<cfcase value="Oracle">
				<cfset dbType = "oracle">
			</cfcase>
			<cfcase value="PostgreSQL">
				<cfset dbType = "oracle">
			</cfcase>
 --->
		</cfswitch>

		<cfreturn dbType>
	</cffunction>


	<cffunction name="initApplicationScope" access="private" output="false" hint="Sets up the main farcry application scope variables." returntype="void">

		<!--- REQUIRED VARIABLES SETUP IN THE FARCRYCONSTRUCTOR --->
		<cfif not isDefined("this.name")>
			<cfabort showerror="this.name not defined in your projects farcryConstructor.">
		</cfif>

		<cfparam name="this.dsn" default="#this.name#" />
		<cfif not isDefined("this.dbtype")>
			<cfset this.dbType = detectDBType()>
			<cfif NOT len(this.dbType)>
				<cfabort showerror="this.dbtype not defined in your projects farcryConstructor or could not be auto-detected.">
			</cfif>
		</cfif>
		<cfparam name="this.dbowner" default="" />

		<cfparam name="this.dsn_read" default="" />
		<cfparam name="this.dbtype_read" default="" />
		<cfparam name="this.dbowner_read" default="" />

		<cfparam name="this.dsn_write" default="" />
		<cfparam name="this.dbtype_write" default="" />
		<cfparam name="this.dbowner_write" default="" />

		<cfparam name="this.displayName" default="#this.name#" />
		
		<cfparam name="this.locales" default="en_AU,en_US" />
		
		<cfparam name="this.projectDirectoryName" default="#this.name#"  />
		<cfparam name="this.plugins" default="farcrycms"  />
		
		<cfparam name="this.projectURL" default="" />
		<cfparam name="this.webtopURL" default="" />
		
		<cfparam name="this.bObjectBroker" default="true" />
		<cfparam name="this.ObjectBrokerMaxObjectsDefault" default="1000" />
		<cfparam name="this.defaultWebskinCacheTimeout" default="1400" /><!--- Default timeout in seconds --->
		<cfparam name="this.defaultBrowserCacheTimeout" default="-1" /><!--- Default timeout in seconds. -1=no cache directives --->
		<cfparam name="this.defaultProxyCacheTimeout" default="-1" /><!--- Default timeout in seconds. -1=no cache directives --->

		<cfparam name="this.bUseDeviceDetection" default="false" /><!--- Device detection is enabled when this flag is set to true --->
		<cfparam name="this.bUseMobileWebskins" default="false" /><!--- Mobile webskins are enabled when this flag is set to true --->
		<cfparam name="this.bUseTabletWebskins" default="false" /><!--- Tablet webskins are enabled when this flag is set to true --->

		<!--- environment configuration --->
		<cfparam name="this.bUseEnv" default="false" />

		<!--- Option to archive --->
		<cfparam name="this.bUseMediaArchive" default="false" />
		
		<!--- updateapp key used to updateapp without administrator privilages. Set to your own string in the farcryConstructor --->
		<cfparam name="this.updateappKey" default="#createUUID()#" />
		
		<!--- Used to identify subsites that are available to this application --->
		<cfparam name="this.subsites" default="#structNew()#" />
		
		<cfset application.projectDirectoryName = this.projectDirectoryName />
		
		
		<!--- Project directory name can be changed from the default which is the applicationname --->
		<cfset application.projectDirectoryName =  this.projectDirectoryName />
		<cfset application.displayName =  this.displayName />
		
		<!----------------------------------------
		 SET THE DATABASE SPECIFIC INFORMATION 
		----------------------------------------->
		<cfset application.dsn = this.dsn />
		<cfset application.dbtype = this.dbtype />
		<cfset application.dbowner = this.dbowner />
		<cfset application.dsn_read = (len(this.dsn_read) ? this.dsn_read : this.dsn) />
		<cfset application.dbtype_read = (len(this.dbtype_read) ? this.dbtype_read : this.dbtype) />
		<cfset application.dbowner_read = (len(this.dbowner_read) ? this.dbowner_read : this.dbowner) />
		<cfset application.dsn_write = (len(this.dsn_write) ? this.dsn_write : this.dsn) />
		<cfset application.dbtype_write = (len(this.dbtype_write) ? this.dbtype_write : this.dbtype) />
		<cfset application.dbowner_write = (len(this.dbowner_write) ? this.dbowner_write : this.dbowner) />
		<cfset application.locales = replaceNoCase(this.locales, " ","",  "all") />
		
		<cfif findnocase("mssql",application.dbtype) AND NOT len(this.dbowner)>
			<cfset application.dbowner = "dbo." />
		</cfif>



		<!----------------------------------------
		 WEB URL PATHS
		 ---------------------------------------->
		<cfset application.url.webroot = "#cgi.context_path##this.projectURL#" />
		<cfif len(this.webtopURL)>
			<cfset application.url.webtop = "#cgi.context_path##this.webtopURL#" />
		<cfelse>
			<cfset application.url.webtop = "#cgi.context_path##application.url.webroot#/webtop" />
		</cfif>
		<cfset application.url.webtoplogin = "#application.url.webtop#/login.cfm" />
		<cfset application.url.publiclogin = application.url.webtoplogin />
		<cfset application.url.farcry = "#application.url.webtop#" /><!--- Legacy variable. Developers should use application.url.webtop --->
		<cfset application.url.imageRoot = "#application.url.webroot#">
		<cfset application.url.fileRoot = "#application.url.webroot#/files">
		<cfset application.url.cache = "#application.url.webroot#/cache">
		
		<!----------------------------------------
		 SET THE MAIN PHYSICAL PATH INFORMATION
		 ---------------------------------------->
		<cfset application.path = structNew() />
		<cfset application.path.project = expandpath("/farcry/projects/#application.projectDirectoryName#") />
		<cfset application.path.core = expandpath("/farcry/core") />
		<cfset application.path.plugins = expandpath("/farcry/plugins") />
		
		<cfif len(cgi.context_path)>
		    <!--- remove the context path before expanding the path --->
		    <cfset application.path.webroot = expandPath("#right(application.url.webroot, len(application.url.webroot)-len(cgi.context_path))#") />
		<cfelseif len(application.url.webroot)>
			<cfset application.path.webroot = expandPath("#application.url.webroot#") />
		<cfelse>
			<cfset application.path.webroot = expandPath("/") /><!--- Doesnt work if empty string. Have to set to  "/" otherwise it returns cf root --->
		</cfif>
		
		<!--- If installing in a subdirectory, the index.cfm seems to be included in the expandPath() above. Need to strip it out. --->
		<cfif right(application.path.webroot,9) EQ "index.cfm">
			<cfset application.path.webroot = left(application.path.webroot,len(application.path.webroot)-10) />
		</cfif>
		
		<!--- Strip out trailing slashes --->
		<cfif right(application.path.webroot,1) EQ "/">
			<cfset application.path.webroot = left(application.path.webroot,len(application.path.webroot)-1) />
		</cfif>		
		<cfif right(application.path.webroot,1) EQ "\">
			<cfset application.path.webroot = left(application.path.webroot,len(application.path.webroot)-1) />
		</cfif>	

		<!--- This line must appear after application.path.webroot is cleaned up --->
		<cfset application.path.cache = "#application.path.webroot#/cache" />

		<cfset application.path.defaultFilePath = "#application.path.webroot#/files">
		<cfset application.path.secureFilePath = "#application.path.project#/securefiles">		
		
		<cfset application.path.imageRoot = "#application.path.webroot#">
		
		<cfset application.path.mediaArchive = "#application.path.project#/mediaArchive">


		<!----------------------------------------
		SHORTCUT PACKAGE PATHS
		 ---------------------------------------->
		<cfset application.packagepath = "farcry.core.packages" />
		<cfset application.custompackagepath = "farcry.projects.#application.projectDirectoryName#.packages" />
		<cfset application.securitypackagepath = "farcry.core.packages.security" />


		<!----------------------------------------
		SETUP FARCRY NAMESPACE
		 ---------------------------------------->
		<cfset application.fc = structNew() /><!--- FarCry Namespace in the application scope --->
		<cfset application.fc.factory = structNew() /><!--- Struct to contain any factory classes that can be used by the application --->
		<cfset application.fc.subsites = this.subsites /><!--- Struct to contain any subsites that may be included with the application --->
		<cfset application.fc.utils = createObject("component", "farcry.core.packages.farcry.utils").init() /><!--- FarCry Utility Functions --->
		<cfset application.fc.serverTimezone = createObject("java","java.util.TimeZone").getDefault().ID />
		<cfset application.fc.container = createObject("component", "farcry.core.packages.rules.container").init() />
		<cfset application.fc.webskinAncestors = structNew() />
		<cfset application.fc.settings = structnew() /><!--- Struct to contain machine specific settings. These should only be altered after init. --->
		
		<cfset application.fc.settings.webtopheadingcolour = "##ffffff" />
		<cfset application.fc.factory['farCoapi'] = createObject("component", "farcry.core.packages.types.farCoapi") />
		
		

		
		<!--- Set an application random string that can be used to force refresh of various browser caching. Restarting application will effectively flush those browser caches --->
		<cfset application.randomID =  application.fc.utils.createJavaUUID() />
		
		
		<!----------------------------------------
		PLUGINS TO INCLUDE
		 ---------------------------------------->
		<cfset application.plugins = this.plugins />

		
		<!--- FAPI INIT --->
		<cfset application.fapi = createObject("component", application.fc.utils.getPath(package="lib", component="fapi")).init() /><!--- FarCry API Functions --->
		<cfset application.fc.lib = createObject("component", "farcry.core.packages.lib.lib").init() /><!--- FarCry libraries --->
		
		<!--- SQL Log --->
		<cfset application.fc.lib.db.setLogLocation("#application.path.project#/log/fourq.sql") />
		
		
		<!------------------------------------------ 
		USE OBJECT BROKER?
		 ------------------------------------------>
		<cfset application.bObjectBroker = this.bObjectBroker />
		<cfset application.ObjectBrokerMaxObjectsDefault = this.ObjectBrokerMaxObjectsDefault />
		<cfset application.defaultWebskinCacheTimeout = this.defaultWebskinCacheTimeout />
		<cfset application.defaultProxyCacheTimeout = this.defaultProxyCacheTimeout />
		<cfset application.defaultBrowserCacheTimeout = this.defaultBrowserCacheTimeout />


		<!------------------------------------------ 
		INITIALISE THE COMBINED JS STRUCTURE USED TO COMBINE MULTIPLE JS FILES
		 ------------------------------------------>
		<cfset application.stCombinedFarcryJS = structNew() />


		<!------------------------------------------ 
		USE DEVICE DETECTION? (i.e. mobile webskins)
		 ------------------------------------------>
		<cfset application.bUseDeviceDetection = this.bUseDeviceDetection />
		<cfset application.bUseMobileWebskins = this.bUseMobileWebskins />
		<cfset application.bUseTabletWebskins = this.bUseTabletWebskins />


		<!------------------------------------------ 
		USE MEDIA ARCHIVE?
		 ------------------------------------------>
		<cfset application.bUseMediaArchive = this.bUseMediaArchive />


		<!------------------------------------------ 
		UPDATE APP KEY
		 ------------------------------------------>
		<cfset application.updateappKey = this.updateappKey />


		<!---------------------------------------------- 
		INITIALISE THE COAPIUTILITIES SINGLETON
		----------------------------------------------->
		<cfset application.coapi = structNew() />
		<cfset application.coapi.coapiUtilities = createObject("component", "farcry.core.packages.coapi.coapiUtilities").init() />


		<!--- Initialise the stPlugins structure that will hold all the plugin specific settings. --->
		<cfset application.stPlugins = structNew() />


		<!--- ENSURE SYSINFO IS UPDATED EACH INITIALISATION --->
		<cfset application.sysInfo = structNew() />
		
		
		<!--- I18N config for Webtop --->
		<!--- TODO:	move all i18n vars into their own struct
					are these used in the new i18n framework? eg. debugRB appears to be irrelevant 
					perhaps these options should be set globally in the ./core/Application.cfc? --->
		<cfset application.shortF=3>        <!--- 3/27/25 --->
		<cfset application.mediumF=2>       <!--- Rabi' I 27, 1425 --->
		<cfset application.longF=1>         <!--- Rabi' I 27, 1425 --->
		<cfset application.fullF=0>         <!--- Monday, Rabi' I 27, 1425 --->
		<!--- /I18N config for Webtop --->

	</cffunction>

</cfcomponent>
