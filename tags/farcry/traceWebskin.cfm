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
<!--- @@displayname: html div --->
<!--- @@description: A standard HTML div tag usefull when coding so that opening and closing cfoutput tags are not required thereby cleaning up output.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.objectid" /><!--- The objectid of the object being traced --->
	<cfparam name="attributes.typename" /><!--- The typename of the object being traced --->
	<cfparam name="attributes.template" default="" /><!--- The webskin name --->
	<cfparam name="attributes.bAllowTrace" default="true" /><!--- Is the outputting of the wrapping trace div allowed? --->
	
	

	<cfif structKeyExists(request,"mode") AND request.mode.traceWebskins EQ true AND not request.mode.ajax>				
		<cfset stTrace = structNew() />
		<cfset stTrace.traceID = application.fapi.getUUID() />
		<cfset stTrace.objectid = attributes.objectid />
		<cfset stTrace.typename = attributes.typename />
		<cfset stTrace.template = attributes.template />
		<cfset stTrace.path = application.coapi.coapiadmin.getWebskinPath(typename=attributes.typename, template=attributes.template) />
		<cfset stTrace.cacheStatus = application.coapi.coapiadmin.getWebskinCacheStatus(typename=attributes.typename, template=attributes.template) />
		<cfset stTrace.cacheByVars = application.coapi.coapiadmin.getWebskinCacheByVars(typename=attributes.typename, template=attributes.template) />
		<cfset stTrace.cacheByRoles = application.coapi.coapiadmin.getWebskinCacheByRoles(typename=attributes.typename, template=attributes.template) />
		<cfset stTrace.level = arrayLen(request.aAncestorWebskins) />
		<cfset stTrace.bAllowTrace = attributes.bAllowTrace />
		<cfset arrayAppend(request.aAncestorWebskinsTrace, stTrace) />	
		
		<cfif attributes.bAllowTrace>
			<cfoutput>
			<div id="#stTrace.traceID#" class="webskin-tracer" style="display:none;">
				<a name="#stTrace.traceID#">&nbsp;</a>
				<div class="webskin-tracer-bubble">
					<div class="webskin-tracer-bubble-inner">
						<span style="font-weight:bold;">#stTrace.objectid#</span><br />
						<span style="font-weight:bold;">Type</span>: #stTrace.typename#<br />
						<span style="font-weight:bold;">Webskin</span>: #stTrace.template#<br />
						<span style="font-weight:bold;">Path</span>: #stTrace.path#<br />
						<span style="font-weight:bold;">Caching</span>: #stTrace.cacheStatus#<br />
						<cfif len(stTrace.cacheByVars)>
							<span style="font-weight:bold;">Cache by vars</span>: #stTrace.cacheByVars#<br />
						</cfif>
						<cfif stTrace.cacheByRoles>
							<span style="font-weight:bold;">Cache by roles</span>: #yesNoFormat(stTrace.cacheByRoles)#<br />
						</cfif>
						<div class="webskin-tracer-close" onclick="$j('###stTrace.traceID#').css('display', 'none');$j('###stTrace.traceID#-webskin-border').css('display', 'none');">CLOSE</div>
					</div>
				</div>
			</div>
			<webskin id="#stTrace.traceID#-webskin">
				<div id="#stTrace.traceID#-webskin-border" style="display:none;"></div>
			</cfoutput>
		</cfif>
	</cfif>
</cfif>

<cfif thistag.executionMode eq "End">
	<cfif structKeyExists(request,"mode") AND request.mode.traceWebskins EQ true AND not request.mode.ajax>			
		<cfif attributes.bAllowTrace>
			<cfoutput></webskin></cfoutput>
		</cfif>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false">

