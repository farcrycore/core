<cfsetting enablecfoutputonly="Yes">
<cfsilent>
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
<!--- @@hint: A replacement for cflocation that allows you o pass in similar attributes to skin:buildlink but this tag will cflocate to that link. --->


<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfif not thisTag.HasEndTag>
	<cfabort showerror="skin:location requires an end tag." />
</cfif>

<cfif thistag.executionMode eq "Start">

	<cfparam name="attributes.url" default="" /><!--- the actual href to link to. This is to provide similar syntax to <cflocation /> however attributes.href should be used. --->
	<cfparam name="attributes.href" default="#attributes.url#" /><!--- the actual href to link to. Defaults to attributes.url --->
	<cfparam name="attributes.alias" default=""><!--- Navigation alias to use to find the objectid --->
	<cfparam name="attributes.objectid" default="" /><!--- Added to url parameters; navigation obj id --->
	<cfparam name="attributes.type" default="" /><!--- Added to url parameters: Typename used with type webskin views --->
	<cfparam name="attributes.view" default="" /><!--- Added to url parameters: Webskin name used with type webskin views --->
	<cfparam name="attributes.bodyView" default="" /><!--- Added to url parameters: Webskin name used with type webskin views --->
	<cfparam name="attributes.externallink" default="">
	<cfparam name="attributes.stParameters" default="#StructNew()#" />
	<cfparam name="attributes.urlParameters" default="" />
	<cfparam name="attributes.includeDomain" default="false" />
	<cfparam name="attributes.Domain" default="#cgi.http_host#" />
	<cfparam name="attributes.addToken" default="false" />
	<cfparam name="attributes.ampDelim" default="&" />	
	<cfparam name="attributes.statusCode" default="" /><!--- Optional: add a status code to the cflocation redirect --->
	
	<cfset attributes.url = application.fapi.getLink(argumentCollection="#attributes#") />		
	
	<cfset request.fc.bLocating = true />
	
	<cfset createobject("component","farcry.core.Application").onRequestEnd() />
	<cfif attributes.statusCode eq "">
		<cflocation url="#attributes.url#" addtoken="#attributes.addToken#" />
	<cfelse>
		<cflocation url="#attributes.url#" statusCode="#attributes.statusCode#" addtoken="#attributes.addToken#" />
	</cfif>
	
</cfif>
	
</cfsilent>