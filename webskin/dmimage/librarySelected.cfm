<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Thumbnail Image for Library Select --->
<!--- @@author: Matthew Bryant --->

<cfif StructKeyExists(stObj,"thumbnailImage") AND len(stobj.thumbnailImage)>
	<cfoutput>
		<table>
		<tr>
			<td><img src="#application.url.webroot##stobj.thumbnailImage#" title="#stObj.title#"></td>
			<td>&nbsp;</td>
			<td>
				#stObj.title#<br />
				<em>(#stobj.alt#)</em>
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