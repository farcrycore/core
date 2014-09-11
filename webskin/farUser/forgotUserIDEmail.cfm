<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<!--- Refresh stobj --->
<cfset stobj = getData(objectid=stobj.objectid) />


<cfset stProfile = createObject("component", application.stcoapi["dmProfile"].packagePath).getProfile(userName="#stobj.userID#", ud="CLIENTUD") />


<cfmail from="#application.fapi.getConfig("general","adminemail")#" to="#stProfile.emailAddress#" subject="#application.fapi.getConfig("general", "sitetitle", "FarCry")# Webtop #application.fapi.getResource('coapi.farLogin.clientidreminder@subject','Username Retrieval')#" type="html">
	<admin:resource key="coapi.farLogin.clientidreminder@html" var1="#stProfile.firstname#" var2="#stProfile.lastname#" var3="#stobj.userID#"><cfoutput>
		<p>Hello {1} {2}</p>
		<p>Your Username is: {3}</p>
	</cfoutput></admin:resource>
</cfmail>
