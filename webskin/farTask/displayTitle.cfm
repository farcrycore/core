
<cfif stobj.bComplete>
	<cfoutput><span style="text-decoration:line-through">#stobj.title#</span></cfoutput>
<cfelse>
	<cfoutput>#stobj.title#</cfoutput>
</cfif>