<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Thumbnail Image for Library Select --->
<!--- @@author: Matthew Bryant --->

<cfif StructKeyExists(stObj,"thumbnailImage") AND len(stobj.thumbnailImage)>
	<cfoutput>
		<img src="#getFileLocation(stObject=stObj,fieldname='thumbnailImage',admin=true).path#" title="#application.fc.lib.esapi.encodeForHTMLAttribute(stObj.title)#" style="clear:both;" />
		#stObj.title#
		<cfif len(stobj.alt)><br /><em>(#application.fc.lib.esapi.encodeForHTML(stobj.alt)#)</em></cfif>
	</cfoutput>
<cfelseif len(stobj.label)>
	<cfoutput>#application.fc.lib.esapi.encodeForHTML(stobj.label)#</cfoutput>
<cfelse>
	<cfoutput>#stobj.objectid#</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false">