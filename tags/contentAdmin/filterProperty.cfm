
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
	<cfabort showerror="ca:filterProperty must have an end tag...">
</cfif>
	
<!--- ATTRIBUTES --->
<cfparam name="attributes.name" /><!--- The name of the filter property --->
<cfparam name="attributes.label" default="" /><!--- The label of the filter property --->
<cfparam name="attributes.type" default="contains" /><!--- the render type of the filter that will use the stProps passed in --->
<cfparam name="attributes.stProps" default="#structNew()#" /><!--- The default value of the filter. --->
	
		

<cfif thistag.executionMode eq "Start">
	<!--- ENVIRONMENT VARIABLES --->
	<cfset stFilter = getbasetagdata("cf_filter").stFilter />
	<cfset stFilterProperty = structNew() />

	<cfset stFilterProperty.label = attributes.label>	
	<cfset stFilterProperty.name = attributes.name>		
	<cfset stFilterProperty.type = attributes.type>	
	<cfset stFilterProperty.stProps = attributes.stProps>	
	
	<cfif not len(stFilterProperty.label) AND len(stFilterProperty.name)>
		<cfset stFilterProperty.label = attributes.name>	
	</cfif>
	
	<cfset lReservedAttributes = "name,label,type,stProps" />
	
	<cfloop collection="#attributes#" item="attr">
		<cfif not listFindNoCase(lReservedAttributes, attr)>
			<cfset stFilterProperty.stProps[attr] = attributes[attr] />
		</cfif>
	</cfloop>

</cfif>



<cfif thistag.executionMode eq "End">
	<cfset arrayAppend(stFilter.aProperties, duplicate(stFilterProperty)) />
</cfif>