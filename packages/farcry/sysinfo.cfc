<cfcomponent name="sysinfo" displayname="System Information" hint="Provides read only system information about the active FarCry installation">

<cffunction name="getMachineName" returntype="string" output="false" access="public" hint="Returns the active machine name.">
	<cfset var machineName=createObject("java", "java.net.InetAddress").localhost.getHostName()>
	<cfreturn machinename>
</cffunction>

<cffunction name="getInstanceName" returntype="string" output="false" access="public" hint="Returns the active server instance name.">
	<cfset var instanceName=createObject("java", "jrunx.kernel.JRun").getServerName()>
	<cfreturn instanceName>
</cffunction>

<cffunction name="getVersionTagline" access="public" output="false" hint="Returns a string detailing the current FarCry CMS build details." returntype="string">
	<cfreturn "FarCry 3.0.2RC" />
</cffunction>

</cfcomponent>



