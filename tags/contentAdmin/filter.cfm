
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
<!--- @@displayname: Content Admin Filter --->
<!--- @@description: Used to define a content administration filter option.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


	
<cfif not thistag.HasEndTag>
	<cfabort showerror="ca:filter must have an end tag...">
</cfif>

<!--- ATTRIBUTES --->
<cfparam name="attributes.title" /><!--- The title of the filter to render --->
	
		


<cfif thistag.executionMode eq "Start">
	<!--- ENVIRONMENT VARIABLES --->
	<cfset stList = getbasetagdata("cf_list").stList />
	<cfset stFilter = structNew() />

	<cfset stFilter.title = attributes.title>	
	<cfset stFilter.id = hash(attributes.title)>	
	<cfset stFilter.aProperties = arrayNew(1)>	

</cfif>



<cfif thistag.executionMode eq "End">
	<cfset arrayAppend(stList.aFilters, duplicate(stFilter)) />
</cfif>