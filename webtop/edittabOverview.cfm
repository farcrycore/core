<cfsetting enablecfoutputonly="true" />
<cfprocessingDirective pageencoding="utf-8" />
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
<!---
|| DESCRIPTION || 
$DESCRIPTION: Displays summary and options for editing/approving/previewing etc for selected object $
$TODO:
- Remove inline styles
- Remove remote references to YUI files
- basically rewrite.. this is horrible
GB 20071015 $

|| DEVELOPER ||
$DEVELOPER: Mat Bryant (mbryant@daemon.com.au)$
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<!--- 
DETERMINE THE VERSION OF THE OBJECT TO RENDER.
If an objectid is passed then attempt to render its draft as the overview.
If a versionid is passed then that is the one we wish to render as the overview.
 --->
<cfif structKeyExists(url, "versionID")>
	<cfset variables.overviewID = url.versionID />
<cfelseif structKeyExists(url, "objectID")>

	<!--- Default to the objectid --->
	<cfset variables.overviewID = url.objectID />
	
	<!--- Try and find a version of this object --->
	<cfset variables.stObject = application.fapi.getContentObject(url.objectID) />
	<cfif structKeyExists(variables.stObject,"versionID") AND structKeyExists(variables.stObject,"status") AND variables.stObject.status EQ "approved">
		<cfset variables.qDraft = application.factory.oVersioning.checkIsDraft(objectid=variables.stObject.objectid,type=variables.stObject.typename)>
		<cfif variables.qDraft.recordcount>		
			<cfset variables.overviewID = variables.qDraft.objectID />
		</cfif>
	</cfif>	
<cfelse>
	<cfthrow message="overview: You must pass an objectid or versionid" />
</cfif>

<cfif not structkeyexists(url,"typename")>
	<cfset url.typename = application.fapi.findType(variables.overviewID) />
</cfif>

<!--- get the content object from storage, not object broker --->
<cfset stObject = application.fapi.getContentType(typename=url.typename).getData(objectid=variables.overviewID, bUseInstanceCache=false)>


<skin:view typename="dmHTML" webskin="webtopHeaderModal" />

<sec:CheckPermission error="true" permission="ObjectOverviewTab">
	<skin:view stObject="#stObject#" webskin="webtopOverview" />
</sec:CheckPermission>

<!--- setup footer --->
<skin:view typename="dmHTML" webskin="webtopFooterModal" />

<cfsetting enablecfoutputonly="false" />
