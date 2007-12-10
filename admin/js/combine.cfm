<cfsetting showdebugoutput="false" />
<cfcontent type="text/javascript; charset=UTF-8">

<cfset hashedURL = hash(cgi.QUERY_STRING) />

<cfparam name="application.stCombinedFarcryJS" default="#structNew()#" />

<cfif not structKeyExists(application.stCombinedFarcryJS, hashedURL)>

	<cfsavecontent variable="stCombinedFarcryJS">
		<cfif structKeyExists(url, "library") AND  structKeyExists(url, "files") AND len(url.files)>
			<cfloop list="#url.files#" index="i" >
				<cfoutput>//-------------#i#-------------//</cfoutput>
				<cfinclude template="/farcry/core/admin/js/#url.library##i#" />			
			</cfloop>
		</cfif>
	</cfsavecontent>
	
	<cfset application.stCombinedFarcryJS[hashedURL] = stCombinedFarcryJS />
</cfif>

<cfoutput>#application.stCombinedFarcryJS[hashedURL]#</cfoutput>
