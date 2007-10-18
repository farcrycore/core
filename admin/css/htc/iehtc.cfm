<!--- allow output only from cfoutput tags --->
<cfsetting enablecfoutputonly="yes" />

<cfif not isDefined("application.url.farcry")>
  <cfset variables.farcryRoot = "/farcry" />
<cfelse>
  <cfset variables.farcryRoot = application.url.farcry />
</cfif>

<!--- set content type of cfm to css to enable output to be parsed as css by all browsers --->
<cfcontent type="text/css; charset=UTF-8">

<!---
the following style tag enables tag insight in your IDE
and is placed before the cfoutput tag to prevent being output.
--->
<style>

<!--- output css --->
<cfoutput>/*
=================================================================================
iehtc.cfm:
=================================================================================

this stylesheet links an ie specific .htc file to the body tag to enable
psuedo classes such as :hover to behave in the same manner as in other browsers

*/
body {behavior:url("#variables.farcryRoot#/css/htc/csshover2.htc");}

</cfoutput>
<!--- end css output --->

</style>
<!--- end enable tag insight --->

<cfsetting enablecfoutputonly="no" />
<!--- end allow output only from cfoutput tags --->