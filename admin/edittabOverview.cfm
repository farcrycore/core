<!--- set up page header --->
<cfimport taglib="/farcry/tags/admin/" prefix="admin">
<admin:header>

<cfimport taglib="/fourq/tags/" prefix="q4">

<!--- get object details --->
<q4:contentobjectget objectid="#url.objectid#" r_stobject="stobj">


<div class="FormTitle"><Cfoutput>#stobj.title#</Cfoutput></div>

<table cellpadding="5" cellspacing="0" border="0" style="margin-left:30px;">
<tr>
	<td width="100"><strong>Object Title:</strong></td>
	<td>
		<cfif stobj.title neq "">
			<Cfoutput>#stobj.title#</Cfoutput>
		<cfelse>
			<i>undefined</i>		
		</cfif></td>
</tr>
<tr>
	<td><strong>Created by:</strong></td>
	<td><Cfoutput>#stobj.createdby#</Cfoutput></td>
</tr>
<tr>
	<td><strong>Date Created:</strong></td>
	<td><Cfoutput>#dateformat(stobj.datetimecreated)#</Cfoutput></td>
</tr>
<cfif IsDefined("stobj.displaymethod")>
<tr>
	<td><strong>Last Updated:</strong></td>
	<td><Cfoutput>#dateformat(stobj.datetimelastupdated)#</Cfoutput></td>
</tr>
</cfif>
<cfif IsDefined("stobj.displaymethod")>
<tr>
	<td><strong>Last Updated By:</strong></td>
	<td><Cfoutput>#stobj.lastupdatedby#</Cfoutput></td>
</tr>
</cfif>
<cfif IsDefined("stobj.displaymethod")>
<tr>
	<td><strong>Current Status:</strong></td>
	<td><Cfoutput>#stobj.status#</Cfoutput></td>
</tr>
</cfif>
<cfif IsDefined("stobj.displaymethod")>
<tr>
	<td><strong>Template:</strong></td>
	<td><cfoutput>#stobj.displaymethod#</cfoutput></td>
</tr>
</cfif>
<cfif IsDefined("stobj.teaser")>
<tr>
	<td valign="top"><strong>Teaser:</strong></td>
	<td><cfoutput>#stobj.teaser#</Cfoutput></td>
</tr>
</cfif>
<cfif IsDefined("stobj.thumbnailimagepath") and stobj.thumbnailimagepath neq "">
<tr>
	<td valign="top"><strong>Thumbnail:</strong></td>
	<td><cfoutput><img src="#stobj.thumbnailimagepath#/#stobj.thumbnail#" border="0"></Cfoutput></td>
</tr>
</cfif>

</table>

<!--- setup footer --->
<admin:footer>