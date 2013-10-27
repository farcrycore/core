<cfsetting enablecfoutputonly="true">

<cfif thistag.executionmode eq "start">
	
	<cfparam name="attributes.template" default="">
	<cfset filename = expandPath("/farcry/core/webtop/templates/#attributes.template#.hbs")>

	<cfif len(attributes.template) AND fileExists(filename)>
		
		<!--- read the template file --->
		<cffile action="read" file="#filename#" variable="content">
		<!--- output the handlebars template inline --->
		<cfoutput>
			<script id="#attributes.template#" type="text/x-handlebars-template">
				#content#
			</script>
		</cfoutput>

	</cfif>

</cfif>

<cfsetting enablecfoutputonly="false">