<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Library Selection View --->
<!--- @@description: Summary of profile for use in uuid and array library selection --->

<cfoutput><cfif len(trim(stObj.firstname)) or len(stObj.lastName)>#stObj.firstName# #stObj.lastName#<cfelse>-</cfif> (<cfif len(stObj.emailAddress)>#stObj.emailAddress#<cfelse>-</cfif>)</cfoutput>

		
<cfsetting enablecfoutputonly="false" />