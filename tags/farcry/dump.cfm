<!--- 
 // DEPRECATED
	farcry:dump is no longer in use and will be removed from the code base. 
	There is no replacement.
--------------------------------------------------------------------------------------------------->
<!--- @@bDeprecated: true --->
<cfset application.fapi.deprecated("farcry:dump is no longer in use and will be removed from the code base. There is no replacement.") />



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
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/farcry/dump.cfm,v 1.3 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: Displays a dump of object data$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfparam name="url.lObjectIds" default="#attributes.lObjectIDs#">
<cfoutput>
<HTML>

<link rel="stylesheet" type="text/css" href="navajo_popup.css">

<BODY>

<table cellpadding=0 cellspacing=0 border=0 bgcolor="##444444"><TR><td>

<table cellpadding=0 cellspacing=0 border=1 bgcolor="##aaaaaa"><TR>
<cfloop index="objId" list="#url.lObjectIds#">
<q4:contentobjectGet objectId="#objId#" r_stObject="stobj">
<cfif len(stobj.label) gt 20><cfset stobj.label=left(stobj.label,20)&"..."></cfif>
<Td onclick="hideAll('#objId#')" style="cursor:hand;"><nobr>
<span style="padding: 10px 10px 10px 10px;background-color:##<cfif objId neq listGetAt(url.lObjectIds,1)>aaaaaa<cfelse>dddddd</cfif>" id="#objId#tab">
#stobj.label#</span></nobr></td>
</cfloop><Cfset l = listLen(url.lObjectIds)+1>
<td width=100%></td></tr><tr><td colspan=#l#>

</cfoutput>
<cfloop index="objId" list="#url.lObjectIds#">
	
	<q4:contentobjectGet objectId="#objId#" r_stObject="stobj">
	
	<cfoutput>
	<table cellpadding=0 cellspacing=0 border=0 bgcolor="##dddddd"><tr>
	<Td><div style="padding: 16px 16px 16px 16px;<cfif objId neq listGetAt(url.lObjectIds,1)>display:none;</cfif>" id="#objId#"></cfoutput>x
	
	<cfoutput><h3 style="display:inline;">#stobj.label#</h3> <h6 style="display:inline">( #stobj.objectId# )</h6></cfoutput>x
	<cfdump var="#stobj#">
	
	<cfoutput></div>
	</td></tr></table>
	
	</cfoutput>
</cfloop>

<cfoutput>
</td></tr></table>
</td></tr></table>

<script>
function hideAll(id)
{
	var lIds = "#url.lObjectIds#";
	var aIds = lIds.split(",");
	
	for( var i=0; i<aIds.length; i++ )
	{
		document.getElementById(aIds[i]).style.display='none';
		document.getElementById(aIds[i]+"tab").style.backgroundColor='##aaaaaa';
	}
	
	document.getElementById(id).style.display='inline';
	document.getElementById(id+"tab").style.backgroundColor='##dddddd';
}
</script>

</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="No">