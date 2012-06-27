<cfcomponent hint="I encode and verify password hashes. I support multiple hashing algorithms to make upgrades easier." output="false">

	<cffunction access="public" name="init" returntype="cryptLib" output="false" hint="Constructor">

		<cfset var comp = "" />
		<cfset var oHash = "" />
		
		<cfset variables.stHashes = structNew() />
		
		<cfloop list="#application.factory.oUtils.getComponents('security')#" index="comp">
			<cfif not listFindNoCase("PasswordHash",comp) and application.factory.oUtils.extends(application.factory.oUtils.getPath("security",comp),"farcry.core.packages.security.PasswordHash")>
				<cfset oHash = createobject("component",application.factory.oUtils.getPath("security",comp)).init() />
				<cfset variables.stHashes[oHash.alias] = oHash />
			</cfif>
		</cfloop>
		
		<cfset variables.lOrderedHashes = ArrayToList(structsort(variables.stHashes,"numeric","asc","seq")) />

		<cfreturn this />
	</cffunction>
	
	<cffunction name="encodePassword" access="public" returntype="string" output="false" hint="Convert a clear password to its encoded value">
		<cfargument name="password" type="string" required="true" hint="Input password"  />
		<cfargument name="hashName" type="string" default="#getDefaultHashName()#" hint="Alias of hash algorithm to encode password" />
		
		<cfreturn getHashComponent(arguments.hashName).encode(arguments.password) />
	</cffunction>

	<cffunction name="passwordMatchesHash" access="public" returntype="boolean" output="false" hint="Check if a clear password matches an encoded hash">
		<cfargument name="password" type="string" hint="Input password" required="true" />
		<cfargument name="hashedPassword" type="string" required="true" hint="Hashed password" />
		
		<cfreturn findHash(hashedPassword=arguments.hashedPassword).passwordMatch(password=arguments.password,hashedPassword=arguments.hashedPassword) />
	</cffunction>

	<cffunction name="hashedPasswordIsStale" access="public" returntype="boolean" output="false" hint="Is the hashed password stale (i.e. needs to be regenerated)?">
		<cfargument name="hashedPassword" type="string" required="true" hint="Hashed password" />
		<cfargument name="password" type="string" required="true" hint="Source password" />
		<cfargument name="hashName" type="string" default="#getDefaultHashName()#" hint="Alias of hash algorithm that hashed password should be using" />
		
		<cfset var oHash = getHashComponent(arguments.hashName) />
		
		<cfreturn not oHash.matchesHashFormat(arguments.hashedPassword) or not oHash.passwordMatch(password=arguments.password,hashedPassword=arguments.hashedPassword,bCheckHashStrength=true) />
	</cffunction>

	<cffunction name="getDefaultHashName" access="public" returntype="PasswordHash" output="false" hint="Return the alias of the default algorithm used to encoded passwords">

		<cfreturn ListFirst(variables.lOrderedHashes) />
	</cffunction>

	<cffunction name="isHashAlgorithmSupported" access="public" returntype="boolean" output="false" hint="Is this hash algorithm supported?">
		<cfargument name="hashName" type="string" required="true" hint="Alias of hash algorithm" />

		<cfreturn structKeyExists(variables.stHashes,arguments.hashName) and variables.stHashes[arguments.hashName].isAvailable() />
	</cffunction>

	<cffunction name="getHashComponent" access="public" returntype="PasswordHash" output="false" hint="Return a hash algorithm component">
		<cfargument name="hashName" type="string" default="#getDefaultHashName()#" hint="Alias of hash algorithm" />
		
		<cfreturn variables.stHashes[arguments.hashName] />
	</cffunction>
	
	<cffunction name="getOrderedHashArray" access="public" returntype="array" output="false" hint="Return an array of supported PasswordHash components in order of priority">

		<cfset var hashKey = "" />
		<cfset var oHash = "" />
		<cfset var aHashes = arrayNew(1) />
		
		<cfloop list="#variables.lOrderedHashes#" index="hashKey">
			<cfset oHash = variables.stHashes[hashKey] />
			<cfif oHash.isAvailable()>
				<cfset ArrayAppend(aHashes,oHash) />
			</cfif>
		</cfloop>
		
		<cfreturn aHashes />
	</cffunction>

	<cffunction name="findHash" access="public" output="false" returntype="PasswordHash" hint="Returns a PasswordHash component that can verify this hashed password">
		<cfargument name="hashedPassword" type="string" hint="Hashed password string" required="true" />
		
		<cfset var hashKey = "" />
		<cfset var oHash = "" />
		
		<cfloop list="#variables.lOrderedHashes#" index="hashKey">
			<cfset oHash = variables.stHashes[hashKey] />
			<cfif oHash.isAvailable() and oHash.matchesHashFormat(arguments.hashedPassword)>
				<cfreturn oHash />
			</cfif>
		</cfloop>
		<cfthrow message="Password hash does not match any available hash formats" detail="Hashed password did not match any available PasswordHash objects. Did you override or delete NullHash.cfc?" />
	</cffunction>


</cfcomponent>