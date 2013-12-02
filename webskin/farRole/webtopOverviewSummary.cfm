<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->
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
<!--- @@description: The default webskin to use to render the object's summary in the webtop overview screen  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />

<!------------------ 
START WEBSKIN
 ------------------>

<skin:view stObject="#stObj#" webskin="webtopOverviewDevActions" />

	
<ft:fieldset legend="#application.fapi.getContentTypeMetadata(stobj.typename,'displayname',stobj.typename)# Information">
	
	<ft:field label="Title">
		<cfoutput>#stobj.title#</cfoutput>
	</ft:field>	
	<ft:field label="Groups" bMultiField="true">
		<cfif arrayLen(stobj.aGroups)>
			<cfoutput>
			<ul>
			<cfloop from="1" to="#arrayLen(stobj.aGroups)#" index="i">
				<li>#stobj.aGroups[i]#</li>
			</cfloop>
			</ul>
			</cfoutput>
		<cfelse> 
			-- no connected groups --
		</cfif>
	</ft:field>	
	
</ft:fieldset>


<cfsetting enablecfoutputonly="false">