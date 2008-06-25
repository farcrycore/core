<!--- @@timeout: 0 --->
<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
<extjs:bubble title="Security" message="You do not have permission to access this part of the website" />
<cflocation url="#application.url.farcry#/login.cfm?returnUrl=#URLEncodedFormat(cgi.script_name&'?'&cgi.query_string)#&error=restricted" addtoken="No" />