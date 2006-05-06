<cfcomponent displayname="FormTools" hint="All the methods required to run Farcry Form Tools">

	<cffunction name="BeforeSave" access="public" output="false" returntype="struct">
		<cfargument name="stProperties" required="yes" type="struct">
		
		
		<cfreturn arguments.stProperties>
	</cffunction>
	
	

	<cffunction name="AfterSave" access="public" output="false" returntype="struct">
		<cfargument name="ObjectID" required="yes" type="UUID">
		
		<!--- Get the Object --->
		<cfset stObj = getData(arguments.ObjectID)>
		
		<cfreturn stObj>
	</cffunction>
	
	
		
</cfcomponent> 