<cfsetting enablecfoutputonly="true">

<cfset environment = getEnvironment()>
<cfset color = getColor()>
<cfset label = getLabel()>

<cfoutput>
	<div class="farcry-header-environment env-#environment#" style="background: #color#">
		#label# (#cgi.http_host#)
	</div>
</cfoutput>

<cfsetting enablecfoutputonly="false">