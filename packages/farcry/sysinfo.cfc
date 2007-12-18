<cfcomponent name="sysinfo" displayname="System Information" hint="Provides read only system information about the active FarCry installation">

<cffunction name="getMachineName" returntype="string" output="false" access="public" hint="Returns the active machine name.">
	<cfset var machineName=createObject("java", "java.net.InetAddress").localhost.getHostName()>
	<cfreturn machinename>
</cffunction>

<cffunction name="getInstanceName" returntype="string" output="false" access="public" hint="Returns the active server instance name.">
	<cfset var instanceName="" />
	
	<cfif NOT structkeyexists(server, "bluedragon")>
		<cfset instancename=createObject("java", "jrunx.kernel.JRun").getServerName() />
	</cfif>
	
	<cfreturn instanceName>
</cffunction>

<cffunction name="getVersionTagline" access="public" output="false" hint="Returns a string detailing the current FarCry CMS build details." returntype="string">
	<cfreturn "FarCry #getMajorVersion()#-#getMinorVersion()#-#getPatchVersion()# (#getBuildNumber()#)" />
</cffunction>

<cffunction name="getBuildNumber" access="public" output="false" hint="Returns the contents of the build file if it exists, otherwise assumes it to be under subversion" returntype="string">
	<cfset var returnBuild = "SVN" /><!--- Return --->
	
	<cfif fileExists("#application.path.core#/build.number")>
		<cffile action="read" file="#application.path.core#/build.number" variable="returnbuild">
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
</cfcomponent>



