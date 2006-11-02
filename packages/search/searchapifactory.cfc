<cfcomponent name="searchapifactory">

<cffunction name="init" access="public" output="false" returntype="any" hint="Initialisation method.">
	<cfargument name="searchtype" required="true" type="string" />
	<cfset var searchapi ="" />
	
	<cfset variables.searchtype = arguments.searchtype />

	<cfswitch expression="#arguments.searchtype#">
		
		<cfcase value="veritycf7">
			<cfset searchapi=createobject("component", "searchapi.veritycf7").init() />
		</cfcase>
		
		<cfdefaultcase>
			<cfthrow detail="Not yet implemented for #arguments.searchtype#" />
		</cfdefaultcase>
	</cfswitch>
	
	<cfreturn searchapi />
</cffunction>

</cfcomponent>