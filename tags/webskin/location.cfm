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

	<cfparam name="attributes.url" default=""><!--- the actual href to link to --->
	<cfparam name="attributes.href" default=""><!--- the actual href to link to --->
	<cfparam name="attributes.objectid" default=""><!--- Added to url parameters; navigation obj id --->
	<cfparam name="attributes.type" default=""><!--- Added to url parameters: Typename used with type webskin views --->
	<cfparam name="attributes.view" default=""><!--- Added to url parameters: Webskin name used with type webskin views --->
	<cfparam name="attributes.externallink" default="">
	<cfparam name="attributes.stParameters" default="#StructNew()#">
	<cfparam name="attributes.urlParameters" default="">
	<cfparam name="attributes.includeDomain" default="false">
	<cfparam name="attributes.Domain" default="#cgi.http_host#">
	<cfparam name="attributes.addToken" default="false" />
	
	<cfif not len(attributes.url)>
		<skin:buildLink href="#attributes.href#" 
			objectid="#attributes.objectid#" 
			type="#attributes.type#" 
			view="#attributes.view#" 
			externallink="#attributes.externallink#" 
			stParameters="#attributes.stParameters#" 
			urlParameters="#attributes.urlParameters#" 
			includeDomain="#attributes.includeDomain#" 
			Domain="#attributes.Domain#" 
			r_url="attributes.url" />
	</cfif>				
	<cflocation url="#attributes.url#" addtoken="#attributes.addToken#" />
	
</cfif>
	
</cfsilent>