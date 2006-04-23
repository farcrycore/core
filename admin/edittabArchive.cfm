<!--- set up page header --->
<cfimport taglib="/farcry/tags/admin/" prefix="admin">
<admin:header>

<br>
<span class="FormTitle">Archive</span>
<p></p>

<cfinvoke 
 component="farcry.packages.farcry.versioning"
 method="getArchives"
 returnvariable="getArchivesRet">
	<cfinvokeargument name="objectID" value="#url.objectid#"/>
</cfinvoke>

<p></p>
<table cellpadding="5" cellspacing="0" border="0" style="margin-left:30px;">
<cfif getArchivesRet.recordcount gt 0>
	<tr>
		<td align="center"><strong>Date</strong></td>
		<td align="center"><strong>Label</strong></td>
		<td align="center"><strong>User</strong></td>
		<td>&nbsp;</td>
	</tr>
	<cfoutput query="getArchivesRet">
	<tr>
		<td>#dateformat(DATETIMELASTUPDATED, "dd-mmm-yyyy")# #timeformat(DATETIMELASTUPDATED)#</td>
		<td>#label#</td>
		<td>#lastupdatedby#</td>
		<td><a href="edittabArchiveDetail.cfm?objectid=#url.objectid#&archiveid=#archiveid#">More Detail</a></td>
	</tr>
	</cfoutput>
<cfelse>
	<tr>
		<td colspan="5">No archive recorded.</td>
	</tr>
</cfif>
</table>

<!--- setup footer --->
<admin:footer>