<cfcomponent displayname="FarCry API" hint="The API for all things FarCry" output="false" bDocument="true" scopelocation="application.fapi">

	<cffunction name="init" access="public" returntype="lib" output="false" hint="FAPI Constructor">
		
		<!--- INITIALISE LIBRARIES --->
		<cfset var oUtils = createobject("component","farcry.core.packages.farcry.utils") />
		<cfset var libraries = oUtils.getComponents("lib") />
		<cfset var libraryname	= '' />
		
		<cfloop list="#libraries#" index="libraryname">
			<cfif not refindnocase("(^|,)#libraryname#(,|$)","fapi,lib")>
				<cftry>
				<cfset this[libraryname] = createobject("component",oUtils.getPath("lib",libraryname)) />
					
					<cfcatch> 
						<cfdump var="#libraryname#"><cfdump var="#cfcatch#"><cfabort>
					
					</cfcatch>
				</cftry>
				<cfif structkeyexists(this[libraryname],"init")>
					<cfset this[libraryname].init() />
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn this />
	</cffunction>
	
</cfcomponent>