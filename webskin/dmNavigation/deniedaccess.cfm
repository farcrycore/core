<!--- @@timeout: 0 --->
<cfparam name="ARGUMENTS.STPARAM.loginpath" default="#application.fapi.getLink(href=application.url.publiclogin,urlParameters='returnUrl='&application.fc.lib.esapi.encodeForURL(cgi.script_name&'?'&cgi.query_string))#" type="string">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<skin:bubble title="Security" message="You do not have permission to access this part of the website" tags="security,warning" />
<cflocation url="#ARGUMENTS.STPARAM.loginpath#&error=restricted" addtoken="No" />