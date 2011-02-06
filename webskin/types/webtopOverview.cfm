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
<!--- @@displayname: Render Webtop Overview --->
<!--- @@description: Renders the Tabs for each status of the object for the Webtop Overview Page  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">
<cfimport taglib="/farcry/core/tags/grid/" prefix="grid">

<!------------------ 
START WEBSKIN
 ------------------>



<skin:loadJS id="jquery" />
<skin:loadJS id="jquery-ui" />
<skin:loadCSS id="jquery-ui" />


<!--- 
Its been notoriously difficult to continually pass ref around on the url string. 
This will save it to the session.overviewRef to avoid having to do so.
TO: A refactor is required of all this now that we have webskin goodness.
--->
<cfif not structKeyExists(url, "ref")>
	<cfif structKeyExists(session, "overviewRef")>
		<cfset url.ref = session.overviewRef />
	<cfelse>
		<cfset url.ref = "overview" />
	</cfif>
</cfif>
<cfset session.overviewRef = url.ref />


<ft:form>

	<cfoutput>
	<table class="layout" style="width:100%;">
	<tr>
		<td id="webtopOverviewActions" style="vertical-align:top;width:190px;padding:5px;">
	</cfoutput>
			<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="webtopOverviewActionsPrimary" />	
	<cfoutput>
		</td><td style="vertical-align:top;padding:5px;">		
    </cfoutput>	
			<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="webtopOverviewTab" />	
	<cfoutput>

	</tr>
	</table>		
    </cfoutput>

			
			

</ft:form>


<cfsetting enablecfoutputonly="false">

