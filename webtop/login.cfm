<cfsetting enablecfoutputonly="true" />
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
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
	
	
	<cfif structKeyExists(url, "farcryProject") AND len(url.farcryProject) AND structKeyExists(server, "stFarcryProjects") AND structKeyExists(cookie, "currentFarcryProject") AND structKeyExists(server.stFarcryProjects, url.farcryProject) AND cookie.currentFarcryProject NEQ url.farcryProject>
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