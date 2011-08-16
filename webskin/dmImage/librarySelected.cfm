<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Thumbnail Image for Library Select --->
<!--- @@author: Matthew Bryant --->

<cfif StructKeyExists(stObj,"thumbnailImage") AND len(stobj.thumbnailImage)>
	<cfoutput>
		<table class="layout" style="width:99%;table-layout:fixed;background:transparent;">
		<col style="width:100px;" />
		<col style="width:10px;" />
		<col style="" />
		<tr class="nowrap" style="background:transparent;">
			<td style="background:transparent;"><img src="#application.fapi.getImageWebRoot()##stobj.thumbnailImage#" title="#HTMLEditFormat(stObj.title)#" /></td>
			<td style="background:transparent;">&nbsp;</td>
			<td style="background:transparent;">
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