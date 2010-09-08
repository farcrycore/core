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

	<cfset stResult = application.security.processLogin() />

	<cfif stResult.authenticated>
		<cflocation url="#stResult.loginReturnURL#" addtoken="false" />
	<cfelse>
		<skin:view typename="#stResult.loginTypename#" template="#stResult.loginWebskin#" stParam="#stResult#" />
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false" />