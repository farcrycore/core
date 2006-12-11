<!--- allow output only from cfoutput tags --->
<cfsetting enablecfoutputonly="yes" />

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
customstuff.cfm:
=================================================================================

This stylesheet contains non-standard, browser specific custom css.
Cute safe stuff like coloured scroll bars.

No important standards were harmed in the making of this stylesheet.

*/
body {overflow:auto;scrollbar-base-color: ##7476a6; scrollbar-arrow-color: ##FFFFFF; scrollbar-3dlight-color: ##eaebf1; scrollbar-darkshadow-color: ##61638b; scrollbar-face-color: ##8e8fb1; scrollbar-highlight-color: ##8e8fb1; scrollbar-shadow-color: ##8e8fb1;scrollbar-track-color: ##aeafc7;}

</cfoutput>
<!--- end css output --->

</style>
<!--- end enable tag insight --->

<cfsetting enablecfoutputonly="no" />
<!--- end allow output only from cfoutput tags --->