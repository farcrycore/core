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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/admin/menu.cfm,v 1.6 2005/10/07 04:06:17 daniela Exp $
$Author: daniela $
$Date: 2005/10/07 04:06:17 $
$Name:  $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: Sidebar menu custom tag. 
Generates sidebar subsection menu and permissions 
based on webtop xml for subsection.$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
$Developer: Guy Phanvongsa (guy@daemon.com.au)$
--->

<cfswitch expression="#thistag.executionmode#">
	<cfcase value="start">
		<!--- optional attributes --->
		<cfparam name="attributes.sectionid" default="" type="string" />
		<cfparam name="attributes.subsectionid" default="" type="string" />
		<cfparam name="attributes.webTop" default="" type="any" />
		
		<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
		
		<!--- Root url for webtop links --->
		<cfset rooturl = "#application.url.farcry#/index.cfm?sec=#attributes.sectionid#" />
		
		<!--- Get subsection --->
		<cfset subsection = application.factory.oWebtop.getItem("#attributes.sectionid#.#attributes.subsectionid#") />
		
		<!--- Subsection content --->
		<cfoutput><h1>#subsection.label#</h1></cfoutput>
		<cfif len(subsection.description)>
			<cfoutput><p>#subsection.description#</p></cfoutput>
		</cfif>
		<cfoutput><ul class="inlinedocs"></cfoutput>
		
		<!--- Loop through sections --->
		<cfset count = 0 />
		<admin:loopwebtop parent="#subsection#" item="menu">
			<!--- Menu content --->
			<!--- <cfoutput><h3>#menu.label#</h3></cfoutput>
			<cfif len(menu.description)>
				<cfoutput><p>#menu.description#</p></cfoutput>
			</cfif>
			<cfoutput><ul class="overviewlist"></cfoutput> --->
			
			<admin:loopwebtop parent="#menu#" item="menuitem">
				<!--- If an icon was specified, convert it to the icon facade --->
				<cfif len(menuitem.icon)>
					<cfset menuitem.icon="#application.url.webroot##application.url.farcry#/facade/icon.cfm?icon=#menuitem.icon#" />
				</cfif>
			
				<!--- If a related type is specified, use that to fill description and icon attributes --->
				<cfif len(menuitem.relatedType)>
					<cfif structkeyexists(application.stCOAPI,menuitem.relatedtype)>
						<cfset o = createobject("component",application.stCOAPI[menuitem.relatedType].packagepath) />
						<cfif structkeyexists(application.stCOAPI[menuitem.relatedType],"description")>
							<cfset menuitem.description = application.rb.getResource("coapi.#menuitem.relatedtype#@description",application.stCOAPI[menuitem.relatedType].description) />
						<cfelseif structkeyexists(application.stCOAPI[menuitem.relatedType],"hint")>
							<cfset menuitem.description = application.rb.getResource("coapi.#menuitem.relatedtype#@description",application.stCOAPI[menuitem.relatedType].hint) />
						</cfif>
						<cfset menuitem.icon="#application.url.webroot##application.url.farcry#/facade/icon.cfm?type=#menuitem.relatedType#&usecustom=true" />
					<cfelse>
						<cfthrow message="Related type attribute for '#menuitem.id#' menu item does not specify a valid type" />
					</cfif>
				</cfif>
			
				<cfif len(menuitem.description)>
					<cfset count = count + 1 />
					
					<cfif not menuitem.linkType eq "External">
						<cfset menuitem.link = "#application.url.farcry##ReplaceNoCase(menuitem.link,'#application.url.farcry#','')#" />
					</cfif>
	
					<cfoutput><li></cfoutput>
					
					<cfif len(menuitem.icon)>
						<cfoutput>
							<a href="#menuitem.link#" target="content">
								<img src="#menuitem.icon#" class="overviewicon" border="0" style="float:left;" />
							</a>
						</cfoutput>
					</cfif>
					
					<cfoutput>
							<a href="#menuitem.link#" target="content">#menuitem.label#</a><br/>
							<p>#menuitem.description#</p>
						</li>
					</cfoutput>
				</cfif>
			</admin:loopwebtop>
		</admin:loopwebtop>
			
		<cfoutput></ul></cfoutput>
		
		<cfif not count><!--- No docs --->
			<cfset thisitem = subsection.children[listfirst(subsection.childorder)] />
			<cfset thisitem = thisitem.children[listfirst(thisitem.childorder)] />
			<cfif not thisitem.linkType eq "External">
				<cfset thisitem.link = "#application.url.farcry##ReplaceNoCase(thisitem.link,'#application.url.farcry#','')#" />
			</cfif>
			<cflocation url="#thisitem.link#" />
		</cfif>
	</cfcase>
</cfswitch>

<cfsetting enablecfoutputonly="false" />