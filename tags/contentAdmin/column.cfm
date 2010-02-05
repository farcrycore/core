
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
<!--- @@displayname: Content Admin Column --->
<!--- @@description: Used to define a content administration column.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


	
<!--- ATTRIBUTES --->
<cfparam name="attributes.property" default="" /><!--- The property property to render --->
<cfparam name="attributes.webskin" default="" /><!--- A webskin of the typename to render --->
<cfparam name="attributes.title" default="" /><!--- The title of the column --->
<cfparam name="attributes.bSortable" default="false" /><!--- Is the column sortable --->
	

<cfif thistag.executionMode eq "Start">

			
	<!--- ENVIRONMENT VARIABLES --->
	<cfset stList = getbasetagdata("cf_list").stList />
	<cfset stColumn = structNew() />
	
	<!--- INITIALISATION --->
	<cfif not len(attributes.property) AND not len(attributes.webskin)>
		<cfthrow message="attributes.property or attributes.webskin is required." />
	</cfif>
	
	<cfif len(attributes.property)>
		<cfset stColumn.property = attributes.property>
		<cfif len(attributes.title)>
			<cfset stColumn.title = attributes.title>
		<cfelseif len(stList.typename)>
			<cfset stColumn.title = application.fapi.getPropertyMetadata(typename=stList.typename, property=attributes.property, md="ftLabel", default=attributes.property)>
		<cfelse>
			<cfset stColumn.title = attributes.property />
		</cfif>
	</cfif>
	
	<cfif len(attributes.webskin)>
		<cfset stColumn.webskin = attributes.webskin>
		<cfif len(attributes.title)>
			<cfset stColumn.title = attributes.title>
		<cfelseif len(stList.typename)>
			<cfset stColumn.title = application.fapi.getWebskinDisplayName(typename=stList.typename, template=attributes.webskin)>
		<cfelse>
			<cfset stColumn.title = attributes.webskin />
		</cfif>
	</cfif>
	
	<cfset stColumn.bSortable = attributes.bSortable>
	
	<cfset arrayAppend(stList.aColumns, duplicate(stColumn)) />

</cfif>



<cfif thistag.executionMode eq "End">
	<!--- Do Nothing --->
</cfif>