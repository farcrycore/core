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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
<!--- @@displayname:  --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>


<!------------------ 
START TAG
 ------------------>
<cfset baseTagData = getBaseTagData("cf_accordion")>

<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.id" default="#createUUID()#">
	<cfparam name="attributes.title" default="">
	<cfparam name="attributes.icon" default="">
	<cfparam name="attributes.collapsed" default="true">
	<cfparam name="attributes.html" default="">


	<cfset stPanel = structNew() />
	<cfset stPanel.id = attributes.id />
	<cfset stPanel.title = attributes.title />
	<cfset stPanel.icon = attributes.icon />
	<cfset stPanel.collapsed = attributes.collapsed />
	<cfset stPanel.html = attributes.html />
	
</cfif>

<cfif thistag.executionMode eq "End">

	<cfset stPanel.html = "#stPanel.html##thisTag.GeneratedContent#" />
	<cfset arrayAppend(baseTagData.attributes.aPanels, stPanel) />
	
	<cfset thisTag.GeneratedContent = "" />
	
</cfif>

<cfsetting enablecfoutputonly="false">

