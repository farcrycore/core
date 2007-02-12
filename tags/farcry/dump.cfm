<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/dump.cfm,v 1.3 2005/08/09 03:54:39 geoff Exp $
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
<cfimport taglib="/farcry/farcry_core/fourq/tags/" prefix="q4">
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