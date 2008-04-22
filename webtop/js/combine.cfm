<cfsetting enablecfoutputonly="true" />
<cfsetting showdebugoutput="false" />
<cfcontent type="application/x-javascript">

<cfset offset = 315360000 />
<cfset expires = dateAdd('s', offset, now()) />	
<cfheader name="expires" value="#dateFormat(expires, 'ddd, d mmm yyyy')# #timeFormat(expires, 'HH:mm:ss')# GMT "> 
<cfheader name="cache-control" value="max-age=#offset#"> 

<cfparam name="url.library" default="" />

<!---  type="text/javascript; charset=UTF-8" --->
<cfset hashedURL = hash(cgi.QUERY_STRING) />

<cfparam name="application.stCombinedFarcryJS" default="#structNew()#" />

<cfif not structKeyExists(application.stCombinedFarcryJS, hashedURL)>

	<cfsavecontent variable="stCombinedFarcryJS">
		<cfif structKeyExists(url, "library") AND  structKeyExists(url, "files") AND len(url.files)>
			<cfloop list="#url.files#" index="i" >
				<cfoutput>
					//-------------#i#-------------//
					<cfinclude template="/farcry/core/webtop/js/#url.library##i#" />
				</cfoutput>	
			</cfloop>
		</cfif>
	</cfsavecontent>
	
	<cfset application.stCombinedFarcryJS[hashedURL] = stCombinedFarcryJS />
</cfif>
<cfcontent reset="yes" />
<cfoutput>#application.stCombinedFarcryJS[hashedURL]#</cfoutput>
<cfabort>
<cfsetting enablecfoutputonly="false" />