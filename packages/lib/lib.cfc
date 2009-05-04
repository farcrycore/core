<cfcomponent displayname="FarCry API" hint="The API for all things FarCry" output="false" bDocument="true" scopelocation="application.fapi">

	<cffunction name="init" access="public" returntype="lib" output="false" hint="FAPI Constructor">
		
		<!--- INITIALISE LIBRARIES --->
		<cfset var libraries = application.fapi.getComponents("lib") />
		
		<cfloop list="#libraries#" index="libraryname">
			<cfif not refindnocase("(^|,)#libraryname#(,|$)","fapi,lib")>
				<cfset this[libraryname] = createobject("component",application.fapi.getPackagePath("lib",libraryname)) />
				<cfif structkeyexists(this[libraryname],"init")>
					<cfset this[libraryname].init() />
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn this />
	</cffunction>
	
</cfcomponent>