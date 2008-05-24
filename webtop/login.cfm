<cfsetting enablecfoutputonly="true" />
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php ---> 
<!--- @@Description: FarCry login screen. Tries to include a custom login screen, otherwise use the default. --->

<cfprocessingDirective pageencoding="utf-8">

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<!--------------------------------------
CUSTOM LOGIN
- deprecated: Custom logins should be constructed using the login type webskins; displayHeaderLogin, displayFooterLogin.
--------------------------------------->
<cfif fileExists("#application.path.project#/customadmin/login/login.cfm")>
	<cfinclude template="/farcry/projects/#application.projectDirectoryName#/customadmin/login/login.cfm" />
	
	<!--- this approach is deprecated in 5.0 --->
	<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
	<farcry:deprecated message="Custom logins should be constructed using the login type webskins; displayHeaderLogin, displayFooterLogin." />

<!--------------------------------------
GENERIC LOGIN
--------------------------------------->
<cfelse>
	<!--- environment variables --->
	<cfparam name="url.ud" default="#application.security.getDefaultUD()#" />
	
	
	<cfif structKeyExists(url, "farcryProject") AND structKeyExists(server, "stFarcryProjects") AND structKeyExists(cookie, "currentFarcryProject") AND structKeyExists(server.stFarcryProjects, url.farcryProject) AND cookie.currentFarcryProject NEQ url.farcryProject>
		<cfset cookie.currentFarcryProject = url.farcryProject />
		<cflocation url="#cgi.SCRIPT_NAME#?#cgi.query_string#" addtoken="false" />
	</cfif>
	
	
	<cfset stResult = application.security.authenticate() />
	
	<cfif structisempty(stResult) and isdefined("url.error") and url.error eq "draft">
		<!--- TODO: i18n --->
		<cfset stResult.authenticated = false />
	    <cfset stResult.message = "This page is in draft. Please login with your details below" />
	</cfif>
	
	<!--- set message [error], if user has logged out --->
	<cfif structisempty(stResult) and session.loginReturnURL contains "logout=1">
		<cfset application.security.logout() />
		<cfset stResult.authenticated = false />
	    <cfset stResult.message = "<b>OK:</b> You have successfully logged out." />
	</cfif>
	
	<cfset session.loginReturnURL = URLDecode(session.loginReturnURL) />
	<cfset session.loginReturnURL = replace( session.loginReturnURL, "logout=1", "" ) />
	<cfset session.loginReturnURL = replace( session.loginReturnURL, "&&", "" ) />
	
	<cfif not structkeyexists(stResult,"authenticated") or not stResult.authenticated>
	
		<skin:view typename="#application.security.getLoginForm(url.ud)#" template="displayLogin" stParam="#stResult#" />

	<cfelse>
		<!--- relocate to original location --->
		<cflocation url="#session.loginReturnURL#" addtoken="false" />
		<cfabort>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false" />