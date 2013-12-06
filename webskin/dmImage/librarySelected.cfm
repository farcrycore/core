<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Thumbnail Image for Library Select --->
<!--- @@author: Matthew Bryant --->

<cfif StructKeyExists(stObj,"thumbnailImage") AND len(stobj.thumbnailImage)>
	<cfoutput>
		<table class="layout" style="width:99%;table-layout:fixed;background:transparent;">
		<col style="width: 100px; min-width: 100px" />
		<col style="width: 90%" />
		<tr class="nowrap" style="background:transparent;">
			<td style="background:transparent;padding-right:15px;"><img src="#getFileLocation(stObject=stObj,fieldname='thumbnailImage',admin=true).path#" title="#application.fc.lib.esapi.encodeForHTMLAttribute(stObj.title)#" /></td>
			<td style="background:transparent;max-width:80%">
				#stObj.title#
				<cfif len(stobj.alt)><br /><em title="#application.fc.lib.esapi.encodeForHTMLAttribute(stobj.alt)#">(#application.fc.lib.esapi.encodeForHTML(stobj.alt)#)</em></cfif>
			</td>
		</tr>
		</table>
	</cfoutput>
<cfelseif len(stobj.label)>
	<cfoutput>#application.fc.lib.esapi.encodeForHTML(stobj.label)#</cfoutput>
<cfelse>
	<cfoutput>#stobj.objectid#</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">