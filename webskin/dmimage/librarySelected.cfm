<!--- @@displayname: Thumbnail Image for Library Select --->
<!--- @@author: Matthew Bryant --->

<cfif len(stobj.thumbnailImage)>
	<cfoutput><img src="#stobj.thumbnailImage#"></cfoutput>
<cfelseif len(stobj.label)>
	<cfoutput>#stobj.label#</cfoutput>
<cfelse>
	<cfoutput>#stobj.objectid#</cfoutput>
</cfif>
