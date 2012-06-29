<cfcomponent name="sysinfo" displayname="System Information" hint="Provides read only system information about the active FarCry installation">

<cffunction name="getEngine" returntype="string" output="false" access="public" hint="Returns the CFML engine name">
	
	<cfif structkeyexists(server,"railo")>
		<cfreturn "railo" />
	<cfelseif structkeyexists(server,"coldfusion")>
		<cfreturn "coldfusion" />
	<cfelse>
		<cfreturn "unknown" />
	</cfif>
</cffunction>

<cffunction name="getContainerType" returntype="string" output="false" access="public" hint="Returns the servlet container type (JRun4 or J2EE)">
	<cfif IsDefined("server.coldfusion.appserver")>
		<cfreturn server.coldfusion.appserver />
	<cfelse>
		<cfreturn "unknown" />
	</cfif>
</cffunction>

<cffunction name="getMachineName" returntype="string" output="false" access="public" hint="Returns the active machine name.">
	<cfset var machineName=createObject("java", "java.net.InetAddress").localhost.getHostName()>
	<cfreturn machinename>
</cffunction>

<cffunction name="getInstanceName" returntype="string" output="false" access="public" hint="Returns the active server instance name.">
	<cfset var instanceName="" />
	
	<cftry>
		<cfset instancename=createObject("java", "jrunx.kernel.JRun").getServerName() />
		<cfcatch type="any"><!--- Ignore Error. Means the Server is not running on JRun ---></cfcatch>
	</cftry>
	
	<cfreturn instanceName>
</cffunction>

<cffunction name="getVersionTagline" access="public" output="false" hint="Returns a string detailing the current FarCry CMS build details." returntype="string">
	<cfreturn "You are currently running version <strong>#getMajorVersion()#-#getMinorVersion()#-#getPatchVersion()#</strong> of <a href='http://www.farcrycore.org' target='_blank'>Farcry Core</a>." />
</cffunction>

<cffunction name="getBuildNumber" access="public" output="false" hint="Returns the contents of the build file if it exists, otherwise assumes it to be under subversion" returntype="string">
	<cfset var returnBuild = "SVN" /><!--- Return --->
	<cfset var buildInfo = "" />
	<cfset var pos = 0 />
	
	<cfif fileExists("#application.path.core#/build.info")>
		<cffile action="read" file="#application.path.core#/build.info" variable="buildInfo">
		<cfset pos = findNoCase('Revision:', buildInfo)>
		<cfif pos GT 0>
			<cfset pos = pos + 10>
			<cfset count = find(Chr(10), buildInfo, pos) - pos>
			<cfset returnBuild = mid(buildInfo,  pos, count)>
		</cfif>	
	</cfif>
	
	<cfreturn returnBuild />
</cffunction>

<cffunction name="getMajorVersion" access="public" output="false" hint="Returns the contents of the major version file if it exists" returntype="string">
	<cfset var returnVersion = "UNKNOWN" /><!--- Return --->
	
	<cfif fileExists("#application.path.core#/major.version")>
		<cffile action="read" file="#application.path.core#/major.version" variable="returnVersion">
	</cfif>
	
	<cfreturn returnVersion />
</cffunction>

<cffunction name="getMinorVersion" access="public" output="false" hint="Returns the contents of the minor version file if it exists" returntype="string">
	<cfset var returnVersion = "0" /><!--- Return --->
	
	<cfif fileExists("#application.path.core#/minor.version")>
		<cffile action="read" file="#application.path.core#/minor.version" variable="returnVersion">
	</cfif>
	
	<cfreturn returnVersion />
</cffunction>


<cffunction name="getPatchVersion" access="public" output="false" hint="Returns the contents of the patch version file if it exists" returntype="string">
	<cfset var returnVersion = "0" /><!--- Return --->
	
	<cfif fileExists("#application.path.core#/patch.version")>
		<cffile action="read" file="#application.path.core#/patch.version" variable="returnVersion">
	</cfif>
	
	<cfreturn returnVersion />
</cffunction>

<cffunction name="getSVNDate" access="public" output="false" hint="Returns the contents of the SVN version file date if it exists" returntype="string">
	<cfargument name="dir" type="string" required="false" default="#application.path.core#" />
	
	<cfset var svnDate = "" /><!--- Return --->
	
	<cfif directoryExists('#arguments.dir#/.svn')>
		<cfdirectory action="list" recurse="false" directory="#arguments.dir#/" type="dir" filter=".svn" name="svnDate">
		<cfset svnDate = LSDateFormat(svnDate.dateLastModified, "dd mmmm yyyy")>
	</cfif>
	
	<cfreturn svnDate />
</cffunction>

<cffunction name="getServerVersion" access="public" output="false" hint="Returns the server (Railo or ColdFusion) version">
	<cfset var stVersion = structnew() />
	
	<cfset stVersion["engine"] = getEngine() />
	
	<cfswitch expression="#stVersion.engine#">
		<cfcase value="coldfusion">
			<cfset stVersion["containertype"] = getContainerType() />
			<cfset stVersion["productlevel"] = SERVER.ColdFusion.ProductLevel />
			<cfset stVersion["productversion"] = SERVER.ColdFusion.ProductVersion />
			<cfset stVersion["string"] = "ColdFusion " & SERVER.ColdFusion.ProductLevel & " " & SERVER.ColdFusion.ProductVersion />
		</cfcase>
		
		<cfcase value="railo">
			<cfset stVersion["productversion"] = Server.Railo.Version />
			<cfset stVersion["string"] = "Railo " & Server.Railo.Version />
		</cfcase>
	</cfswitch>
	
	<cfreturn stVersion />
</cffunction>

<cffunction name="getCoreVersion" access="public" returntype="struct" hint="returns a structure containing the major, minor, patch and build version of farcry.">
	
	<cfset var coreVersion = structNew() />
	
	<cfset coreVersion["major"] = getMajorVersion() />
	<cfset coreVersion["minor"] = getMinorVersion() />
	<cfset coreVersion["patch"] = getPatchVersion() />
	<cfset coreVersion["build"] = getBuildNumber() />
	<cfset coreVersion["svndate"] = getSVNDate() />
	<cfset coreVersion["string"] = coreVersion.major & "." & coreVersion.minor & "." & coreVersion.patch />

	<cfreturn coreVersion>
</cffunction>

</cfcomponent>



