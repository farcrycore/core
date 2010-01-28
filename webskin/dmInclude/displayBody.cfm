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
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!--- @@displayname: Standard dmInclude body display --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!--- INCLUDE TAG LIBRARIES --->
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<cfif structKeyExists(stobj, "webskinTypename") AND structKeyExists(stobj, "webskin") AND len(stobj.webskinTypename) AND len(stobj.webskin)>	
	<skin:view typename="#stobj.webskinTypename#" webskin="#stobj.webskin#" stInclude="#stobj#" />
<cfelseif len(stobj.include)>
	<!--- USE skin:include tag to include the file. --->
	<skin:include template="#stObj.include#" />
</cfif>

<cfsetting enablecfoutputonly="false" /> 