<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 2002-2009, http://www.daemon.com.au --->
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
<!--- @@displayname: Webtop Overview --->
<!--- @@description: The dmInclude specific webskin to use to render the object's summary in the webtop overview screen  --->

<!------------------ 
START WEBSKIN
 ------------------>
<cfoutput>
<h2>CONTENT ITEM INFORMATION</h2>


<cfif structKeyExists(stobj, "displayMethod")>
	WEBSKIN: #application.fapi.getWebskinDisplayName(stobj.typename, stobj.displayMethod)# (#stobj.displayMethod#)<br />
</cfif>

<cfif len(stobj.webskinTypename) AND len(stobj.webskin)>
	INCLUDED TYPE WEBSKIN: #application.fapi.getWebskinDisplayName(stobj.webskinTypename,stobj.webskin)# (#stobj.webskin#)<br />
<cfelseif len(stobj.include)>
	INCLUDE: #stobj.include#<br />
<cfelse>
	NO INCLUDE SELECTED<br />
</cfif>


</cfoutput>


<cfsetting enablecfoutputonly="false">