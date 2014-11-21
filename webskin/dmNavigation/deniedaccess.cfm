<!--- @@timeout: 0 --->
<cfparam name="ARGUMENTS.STPARAM.loginpath" default="#application.fapi.getLink(href=application.url.publiclogin,urlParameters='returnUrl='&application.fc.lib.esapi.encodeForURL(cgi.script_name&'?'&cgi.query_string))#" type="string">
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cflocation url="#ARGUMENTS.STPARAM.loginpath#&error=restricted" addtoken="No" />