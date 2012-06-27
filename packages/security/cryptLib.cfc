<cfcomponent hint="Facade for Java crypto libraries" output="false">

	<cffunction access="public" name="init" returntype="cryptLib" output="false" hint="Constructor">
		
		<cfset variables.loadPaths = arrayNew(1) />
		
		<!--- Add paths to .jar and .class files --->
		<cfset arrayappend(variables.loadPaths, expandPath("/farcry/core/packages/security/crypt/jbcrypt-0.3m.jar")) />
		<cfset arrayappend(variables.loadPaths, expandPath("/farcry/core/packages/security/crypt/scrypt-1.3.1.jar")) />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction access="private" name="getJavaLoader" returntype="any" output="false">
		
		<!--- Lazy-loading the JavaLoader makes it easier for plugins/projects to add custom crypto libraries --->
		<cfif not structKeyExists(variables,"loader")>
			<cfset variables.loader = createObject("component", "farcry.core.packages.farcry.javaloader.JavaLoader"
														).init(variables.loadPaths) />
		</cfif>
		<cfreturn variables.loader />
	</cffunction>

	<cffunction access="public" name="create" returntype="any" output="false" hint="Return a java class from the crypto libraries">
		<cfargument name="className" type="string" required="true" />
		
		<cfreturn getJavaLoader().create(arguments.className) />
	</cffunction>


</cfcomponent>