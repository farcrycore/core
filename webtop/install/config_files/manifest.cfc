<cfcomponent extends="farcry.core.webtop.install.manifest" name="manifest">

	<!--- IMPORT TAG LIBRARIES --->
	<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
	
	
	<cfset this.name = "@@applicationName@@" />
	<cfset this.description = "@@description@@" />
	<cfset this.lRequiredPlugins = "@@plugins@@" />
	<!--- <cfset addSupportedCore(majorVersion="5", minorVersion="0", patchVersion="0") /> --->
		
	
	<cffunction name="install" output="true">
		
		<cfset var result = "DONE" />
		
		<cfset result = createContent() />
				
		
		<cfreturn result />
	</cffunction>
	
		
	

</cfcomponent>

