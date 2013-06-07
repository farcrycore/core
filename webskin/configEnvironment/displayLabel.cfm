<cfsetting enablecfoutputonly="true">

<cfif application.fapi.getConfig("environment", "bShowEnvironment")>
	
	<cfset environment = getEnvironment()>
	<cfset color = getColor()>
	<cfset label = getLabel()>

	<cfoutput>
		<div class="farcry-header-environment env-#environment#" style="background: #color#">
			#label# (#cgi.http_host#)
		</div>
	</cfoutput>

</cfif>

<cfsetting enablecfoutputonly="false">