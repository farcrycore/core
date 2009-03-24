<cfsetting enablecfoutputonly="true" />
<cfsetting showdebugoutput="false" />
<cfcontent type="application/x-javascript">

<cfset offset = 315360000 />
<cfset expires = dateAdd('s', offset, "01/01/2008") />	
<cfheader name="Cache-Control" value="private,max-age=#offset#"> 
<cfheader name="Expires" value="#dateFormat(expires, 'ddd, d mmm yyyy')# #timeFormat(expires, 'HH:mm:ss')# GMT">

<cfparam name="url.library" default="" />
<cfparam name="url.files" default="" />

<cfset hashedURL = hash(cgi.QUERY_STRING) />

<cfparam name="application.stCombinedFarcryJS" default="#structNew()#" />

<cfif not structKeyExists(application.stCombinedFarcryJS, hashedURL)>

	<cfsavecontent variable="hashedCombinedFarcryJS">
		<cfif listLen(url.files)>
			<cfloop list="#url.files#" index="i" >
				<cfoutput>
					<cftry>
						//-------------#i#-------------//
						<cfinclude template="/farcry/core/webtop/js#replaceNoCase(url.library, '..', '', 'all')##replaceNoCase(i, '..', '', 'all')#" />
						<cfcatch type="any">//-------------File Not Found-------------//</cfcatch>
					</cftry>
				</cfoutput>	
			</cfloop>
		</cfif>
	</cfsavecontent>
	
	<cfset application.stCombinedFarcryJS[hashedURL] = hashedCombinedFarcryJS />
</cfif>
<cfcontent reset="yes" />
<cfoutput>#application.stCombinedFarcryJS[hashedURL]#</cfoutput>
<cfsetting enablecfoutputonly="false" /> 
<cfexit>

