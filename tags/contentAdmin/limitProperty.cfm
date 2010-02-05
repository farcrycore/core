
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
	<cfabort showerror="ca:limitProperty must have an end tag...">
</cfif>
	
<!--- ATTRIBUTES --->
<cfparam name="attributes.name" /><!--- The name of the limit property --->
<cfparam name="attributes.type" default="contains" /><!--- the render type of the limit that will use the stProps passed in --->
<cfparam name="attributes.stProps" default="#structNew()#" /><!--- The default value of the limit. --->
	
		

<cfif thistag.executionMode eq "Start">
	<!--- ENVIRONMENT VARIABLES --->
	<cfset stLimit = getbasetagdata("cf_limit").stLimit />
	<cfset stLimitProperty = structNew() />

	<cfset stLimitProperty.name = attributes.name>		
	<cfset stLimitProperty.type = attributes.type>	
	<cfset stLimitProperty.stProps = attributes.stProps>	
	
	<cfset lReservedAttributes = "name,type,stProps" />
	
	<cfloop collection="#attributes#" item="attr">
		<cfif not listFindNoCase(lReservedAttributes, attr)>
			<cfset stLimitProperty.stProps[attr] = attributes[attr] />
		</cfif>
	</cfloop>	

</cfif>



<cfif thistag.executionMode eq "End">
	<cfset arrayAppend(stLimit.aProperties, duplicate(stLimitProperty)) />
</cfif>