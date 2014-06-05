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


<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft">


<skin:loadJS id="fc-jquery" />
<skin:loadJS id="fc-jquery-ui" />
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

<cfif structkeyexists(url,"rollback") and isvalid("uuid",url.rollback)>
	<!--- rollback archive --->
	<cfset stRollback = archiveRollback(objectID=stObj.objectid,archiveId=url.rollback,typename=stObj.typename) />
	<skin:bubble message="Rolled back to previous version" tags="types,archive,info" />
	<skin:location url="#application.fapi.fixURL(removevalues='rollback')#" addtoken="false" />
</cfif>


<ft:form>

	<cfoutput>
	<table class="layout" style="width:100%;">
		<tr>
			<td id="webtopOverviewActions" style="vertical-align:top;width:190px;padding:5px;">
				</cfoutput>
				<skin:view stObject="#stObj#" webskin="webtopOverviewActionsPrimary" />	
				<cfoutput>
			</td>
			<td style="vertical-align:top;padding:5px;">
				</cfoutput>
				<skin:view stObject="#stObj#" webskin="webtopOverviewTab" />
				<cfoutput>
			</td>
		</tr>
	</table>
	</cfoutput>

</ft:form>


<cfsetting enablecfoutputonly="false">