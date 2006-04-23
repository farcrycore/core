<cfsetting enablecfoutputonly="Yes">
	<cfif stObj.imageFile neq "">
		<cfoutput><div style="margin-left:20px;margin-top:20px;"><img src="/images/#stObj.imageFile#" alt="#stObj.alt#" border="0"></div></cfoutput>
	<cfelse>
		<cfoutput><div style="margin-left:20px;margin-top:20px;">File does not exist.</div></cfoutput>
	</cfif>
	
<cfsetting enablecfoutputonly="No">