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
<cfoutput>
	<div class="developer-actions">
		<div class="objectid" style="display:none;">#stObj.objectid#</div>
		<a onclick="var oid = $j(this).siblings('.objectid').toggle();selectText(oid[0]);return false;" title="See objectid" class="ui-icon ui-icon-tag">&nbsp;</a>
		<a onclick="$fc.openDialog('Property Dump', '#application.url.farcry#/object_dump.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#');return false;" title="Open a window containing all the raw data of this content item" class="ui-icon ui-icon-calculator">&nbsp;</a>
	</div>
</cfoutput>

<ft:fieldset legend="#application.fapi.getContentTypeMetadata(stobj.typename,'displayname',stobj.typename)# Information">
	
	

	<ft:field label="Title" bMultiField="true">
		<cfoutput>#stobj.title#</cfoutput>
	</ft:field>	
	<ft:field label="Alternate Text" bMultiField="true">
		<cfoutput>#stobj.alt#</cfoutput>
	</ft:field>	
	<ft:field label="Thumbnail" bMultiField="true">
		<cfif len(stobj.ThumbnailImage)>
			<cfoutput><img src="#application.fapi.getimagewebroot()##stobj.thumbnailImage#" /></cfoutput>
		<cfelse>
			<cfoutput>-- no thumbnail --</cfoutput>
		</cfif>
	</ft:field>	
	
	
	<cfif structKeyExists(stobj, "teaser")>
		<ft:field label="Teaser" bMultiField="true">
			<cfoutput><cfif len(stobj.teaser)>#stobj.teaser#<cfelse>-- none --</cfif></cfoutput>
		</ft:field>
	</cfif>
	<cfif structKeyExists(stobj, "displayMethod")>
		<ft:field label="Webskin">
			<cfoutput>#application.fapi.getWebskinDisplayName(stobj.typename, stobj.displayMethod)# (#stobj.displayMethod#)</cfoutput>
		</ft:field>
	</cfif>
</ft:fieldset>



<cfsetting enablecfoutputonly="false">