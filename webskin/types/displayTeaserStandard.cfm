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

<!--- @@displayname: Standard Teaser --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au)--->


<!--- IMPORT TAG LIBRARIES --->
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

<cfif structKeyExists(stobj, "title")>
	<cfset teaserTitle = stObj.Title />
<cfelse>
	<cfset teaserTitle = stObj.label />
</cfif>

<cfoutput>
	<h4>#teaserTitle#</h4>
	<p>
		<cfif structKeyExists(stobj, "Teaser")>
			#stObj.Teaser#			
		</cfif>
		<skin:buildLink objectid="#stobj.objectID#" class="morelink">More<span>about:#teaserTitle#</span></skin:buildLink>
	</p>
</cfoutput>


<cfsetting enablecfoutputonly="false" />