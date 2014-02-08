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
<!--- @@displayname: Display Label --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!------------------ 
START WEBSKIN
 ------------------>
<cfset newLabel = "">

<cfloop list="#StructKeyList(application.stcoapi[stObj.typename].stProps)#" index="field">
    <cfif structKeyExists(stObj,field) AND isDefined("application.stcoapi.#stObj.typename#.stProps.#field#.Metadata.bLabel") AND application.stcoapi[stObj.typename].stProps[field].Metadata.bLabel>
        <cfset newLabel = "#newLabel# #stObj[field]#">
    </cfif>
</cfloop>

<cfif not len(newLabel)>
    <cfif structKeyExists(stObj,"Title")>
        <cfset newLabel = "#stObj.title#">
    <cfelseif structKeyExists(stObj,"Name")>
        <cfset newLabel = "#stObj.name#">
    <cfelse>
        <cfloop list="#StructKeyList(stObj)#" index="field">
            <cfif FindNoCase("Name",field) AND field NEQ "typename">
                <cfset newLabel = "#newLabel# #stObj[field]#">
            </cfif>
        </cfloop>
    </cfif>
</cfif>
<cfif not len(newLabel)>
    <cfset newLabel = "(incomplete)">
</cfif>

<cfoutput>#newLabel#</cfoutput>

<cfsetting enablecfoutputonly="false">