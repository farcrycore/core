<cfsetting enablecfoutputonly="true">
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
<!--- @@description: Forces the user to login --->


<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<cfif thistag.executionMode eq "Start">

	<!--- --------------------------------------------------------------------------------------- --->
	<!--- THE FOLLOWING ATTRIBUTES SETUP THE SECURITY REQUIRED TO BE ASSIGNED TO A LOGGED IN USER --->
	<!--- --------------------------------------------------------------------------------------- --->
	<cfparam name="attributes.lRoles" default=""><!--- A list of roles the current user must have assigned. --->
	<cfparam name="attributes.lPermissions" default=""><!--- A list of permissions the current user must have assigned. --->
	<cfparam name="attributes.message" default=""><!--- A message that will be passed to the login if the security is not met. --->
	
	<!--- -------------------------------------------------------------------------------------- --->
	<!--- THE FOLLOWING ATTRIBUTES ALLOWS THE USER TO SET THE RETURNURL AFTER A SUCCESSFUL LOGIN --->
	<!--- -------------------------------------------------------------------------------------- --->
	<cfparam name="attributes.url" default=""><!--- the actual href to link to. This is to provide similar syntax to <cflocation /> however attributes.href should be used. --->
	<cfparam name="attributes.href" default="#attributes.url#"><!--- the actual href to link to. Defaults to attributes.url --->
	<cfparam name="attributes.alias" default=""><!--- Navigation alias to use to find the objectid --->
	<cfparam name="attributes.objectid" default=""><!--- Added to url parameters; navigation obj id --->
	<cfparam name="attributes.type" default=""><!--- Added to url parameters: Typename used with type webskin views --->
	<cfparam name="attributes.view" default=""><!--- Added to url parameters: Webskin name used with type webskin views --->
	<cfparam name="attributes.bodyView" default=""><!--- Added to url parameters: Webskin name used with type webskin views --->
	<cfparam name="attributes.externallink" default="">
	<cfparam name="attributes.stParameters" default="#StructNew()#">
	<cfparam name="attributes.urlParameters" default="">
	<cfparam name="attributes.includeDomain" default="false">
	<cfparam name="attributes.Domain" default="#cgi.http_host#">
	<cfparam name="attributes.addToken" default="false" />
	<cfparam name="attributes.ampDelim" default="&">	
	<cfparam name="attributes.loginurl" default="">	
	
	<cfset bValidUser = application.fapi.isLoggedIn() />
	
	<cfif bValidUser>
		<cfif len(attributes.lRoles)>
			<cfset bValidUser = application.fapi.hasRole(attributes.lRoles) />
		</cfif>	
	</cfif>
	
	<cfif bValidUser>
		<cfif len(attributes.lPermissions)>
			<cfset bValidUser = application.fapi.hasPermission(attributes.lPermissions) />
		</cfif>	
	</cfif>
	
	<cfif not bValidUser>
		
		<cfif len(attributes.loginurl)>
			<cfset loginURL = "#attributes.loginurl#" />
		<cfelseif not findNoCase( "/webtop", cgi.script_name )>
			<cfset loginURL = application.url.webtoplogin />
		<cfelse>
			<cfset loginURL = application.url.webtoplogin />
		</cfif>
		
		
		<cfif len(attributes.message)>
			<skin:bubble title="Security" message="#attributes.message#" tags="security,warning" />
		</cfif>
		
		<!--- SETUP THE RETURN URL. --->
		<cfset returnURL = application.fapi.getLink(argumentCollection="#attributes#") />		
		
		<cfset stParams = structNew() />
		<cfset stParams.returnURL = returnURL />
		
		<cfif structKeyExists(request.mode, "ajax") AND request.mode.ajax eq 1
				AND structKeyExists(url, "responsetype") AND url.responsetype eq "json">

			<cfset stResponse = structNew()>
			<cfset stResponse["success"] = false>
			<cfset stResponse["message"] = "You are not currently logged in.">
			<cfset stResponse["returnURL"] = returnURL>
			
			<cfcontent reset="true">
			<cfheader statuscode="403" statustext="Not logged in">
			<cfoutput>#serializeJSON(stResponse)#</cfoutput>
			<cfabort>

		<cfelse>
			<skin:location href="#loginURL#" stparameters="#stParams#" />
		</cfif>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false">