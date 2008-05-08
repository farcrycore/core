<cfcomponent name="sysinfo" displayname="System Information" hint="Provides read only system information about the active FarCry installation">

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
	<cfreturn "You are currently running version <strong>#getMajorVersion()#-#getMinorVersion()#-#getPatchVersion()# (#getBuildNumber()#)</strong> of <a href='http://www.farcrycore.org'>Farcry Core</a>." />
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



<cffunction name="getCoreVersion" access="public" returntype="struct" hint="returns a structure containing the major, minor, patch and build version of farcry.">
	
	<cfset var coreVersion = structNew() />
	
	<cfset coreVersion.major = getMajorVersion() />
	<cfset coreVersion.minor = getMinorVersion() />
	<cfset coreVersion.patch = getPatchVersion() />
	<cfset coreVersion.build = getBuildNumber() />

	<cfreturn coreVersion>
</cffunction>

</cfcomponent>



