<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Thumbnail Image for Library Select --->
<!--- @@author: Matthew Bryant --->

<cfif StructKeyExists(stObj,"thumbnailImage") AND len(stobj.thumbnailImage)>
	<cfoutput>
		<table>
		<tr>
			<td><img src="#application.fapi.getImageWebRoot()##stobj.thumbnailImage#" title="#HTMLEditFormat(stObj.title)#" /></td>
			<td>&nbsp;</td>
			<td>
				#stObj.title#
				<cfif len(stobj.alt)><br /><em>(#stobj.alt#)</em></cfif>
			</td>
		</tr>
		</table>
	</cfoutput>
<cfelseif len(stobj.label)>
	<cfoutput>#stobj.label#</cfoutput>
<cfelse>
	<cfoutput>#stobj.objectid#</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">