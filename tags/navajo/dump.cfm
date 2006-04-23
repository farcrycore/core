<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/fourq/tags" prefix="q4">
<cfparam name="attributes.lObjectIds">

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