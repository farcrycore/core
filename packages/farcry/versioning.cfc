
<cfcomponent>
	<cffunction name="sendObjectLive" access="public" returntype="struct" hint="Sends a versioned object with draft live.Archives existing live object if it exists and deletes old live object">
		<cfargument name="objectID" type="uuid" required="true">
		<cfargument name="stDraftObject"  type="struct" required="true" hint="the draft stuct to be updated">
		<cfargument name="typename" type="string" required="false">
		
		<cfset stArgs = arguments>
 		<cfinclude template="_versioning/sendObjectLive.cfm">
		
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="getVersioningRules" access="public" returntype="struct" hint="Returns a structure of boolean rules concerning the editing of farcry objects">
		<cfargument name="objectID" type="uuid" required="true">
		<cfargument name="typename" type="string" required="false">
		
		<cfset stArgs = arguments>
 		<cfinclude template="_versioning/versioningRules.cfm">
						
		<cfreturn stRules>
	</cffunction>	 
	
	<cffunction name="getArchives" access="public" returntype="query" hint="returns all archives for a given object">
		<cfargument name="objectID" type="uuid" required="true">

		<cfset stArgs = arguments>
 		<cfinclude template="_versioning/getArchives.cfm">
		
		<cfreturn qArchives>
	</cffunction>
	
	<cffunction name="checkEdit" access="public" hint="See if we can edit this object">
		<cfargument name="stRules" type="struct" required="true">
		<cfargument name="stObj" type="struct" required="true">
		
		<cfset stArgs = arguments>
 		<cfinclude template="_versioning/checkEdit.cfm">
	
	</cffunction>

</cfcomponent>