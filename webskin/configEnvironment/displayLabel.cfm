<cfsetting enablecfoutputonly="true">

<cfif application.fapi.getConfig("environment", "bShowEnvironment")>
	
	<cfset environment = getEnvironment()>
	<cfset color = getColor()>
	<cfset label = getLabel()>

	<cfoutput>
		<div class="farcry-header-environment farcry-env-#environment#">
			<div class="farcry-header-environment-label" style="background: #color#">#label# (#cgi.http_host#)</div>
		</div>
	</cfoutput>

</cfif>

<cfsetting enablecfoutputonly="false">