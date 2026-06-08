
<cfif stobj.bComplete>
	<cfoutput><span style="text-decoration:line-through">#encodeForHTML(stobj.title)#</span></cfoutput>
<cfelse>
	<cfoutput>#encodeForHTML(stobj.title)#</cfoutput>
</cfif>