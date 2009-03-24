<cfsetting enablecfoutputonly="true" />
<cfsetting showdebugoutput="false" />

<cfcontent type="text/css">

<cfset offset = 315360000 />
<cfset expires = dateAdd('s', offset, now()) />	
<cfheader name="expires" value="#dateFormat(expires, 'ddd, d mmm yyyy')# #timeFormat(expires, 'HH:mm:ss')# GMT "> 
<cfheader name="cache-control" value="max-age=#offset#"> 


<cfparam name="url.library" default="" />

<!---  type="text/javascript; charset=UTF-8" --->
<cfset hashedURL = hash(cgi.QUERY_STRING) />

<cfparam name="application.stCombinedFarcryCSS" default="#structNew()#" />

<cfif not structKeyExists(application.stCombinedFarcryCSS, hashedURL)>

	<cfsavecontent variable="stCombinedFarcryCSS">
		<cfif structKeyExists(url, "library") AND  structKeyExists(url, "files") AND len(url.files)>
			<cfloop list="#url.files#" index="i" >
				<cfoutput>
					<cftry>
						//-------------#i#-------------//
						<cfinclude template="/farcry/core/webtop/css#replaceNoCase(url.library, '..', '', 'all')##replaceNoCase(i, '..', '', 'all')#" />
						<cfcatch type="any">//-------------File Not Found-------------//</cfcatch>
					</cftry>
				</cfoutput>	
			</cfloop>
		</cfif>
	</cfsavecontent>
	
	<cfset application.stCombinedFarcryCSS[hashedURL] = stCombinedFarcryCSS />
</cfif>
<cfcontent reset="yes" />
<cfoutput>#application.stCombinedFarcryCSS[hashedURL]#</cfoutput>
<cfabort>
<cfsetting enablecfoutputonly="false" />