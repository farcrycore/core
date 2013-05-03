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
<!--- @@displayname:  --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>


<!------------------ 
START TAG
 ------------------>
<cfset baseTagData = getBaseTagData("cf_tabs")>

<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.id">
	<cfparam name="attributes.title" default="">
	<cfparam name="attributes.href" default="">
	<cfparam name="attributes.panelStyle" default="">
	

	<cfset stTab = structNew() />
	<cfset stTab.id = attributes.id />
	<cfif len(attributes.title)>
		<cfset stTab.title = attributes.title />
	<cfelse>
		<cfset stTab.title = attributes.id />
	</cfif>
	<cfset stTab.href = attributes.href />
	<cfset stTab.panelStyle = attributes.panelStyle />
	<cfset stTab.HTML = "" />
	<cfset stTab.bCurrent = false />
	
	<cfif not len( request.fc['#baseTagData.attributes.id#-tab'] )>
		<cfset request.fc['#baseTagData.attributes.id#-tab'] = attributes.id>

		<cfif baseTagData.attributes.bSticky>
			<cfset session.fc['#attributes.id#-tab'] = attributes.id>
		</cfif>
				
	</cfif>
	
	
	<cfif request.fc['#baseTagData.attributes.id#-tab'] NEQ attributes.id>
		<cfset arrayAppend(baseTagData.attributes.aTabs, stTab) />
		<cfexit>
	</cfif>
</cfif>

<cfif thistag.executionMode eq "End">

	<cfset stTab.bCurrent = true>
	<cfset stTab.HTML = "#stTab.HTML##thisTag.GeneratedContent#" />
	<cfset arrayAppend(baseTagData.attributes.aTabs, stTab) />
	
	<cfset thisTag.GeneratedContent = "" />
	
</cfif>

<cfsetting enablecfoutputonly="false">

