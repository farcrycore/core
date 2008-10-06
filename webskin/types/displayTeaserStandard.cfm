<cfsetting enablecfoutputonly="true" />
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry CMS Plugin.

    FarCry CMS Plugin is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry CMS Plugin is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with FarCry CMS Plugin.  If not, see <http://www.gnu.org/licenses/>.
--->

<!--- @@displayname: Title and teaser and thumbnail --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au)--->


<!--- IMPORT TAG LIBRARIES --->
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">


<cfif structKeyExists(stobj, "title")>
	<cfoutput><h4>#stObj.Title#</h4></cfoutput>
<cfelse>
	<cfoutput><h4>#stobj.label#</h4></cfoutput>
</cfif>

<cfoutput>
<p>
<cfif structKeyExists(stobj, "Teaser")>
	#stObj.Teaser#	
	<skin:buildLink objectid="#stobj.objectID#" class="morelink">More<span>about:#stObj.Title#</span></skin:buildLink>
</cfif>
</p>
</cfoutput>


<cfsetting enablecfoutputonly="false" />