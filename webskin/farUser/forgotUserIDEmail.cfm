<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<!--- Refresh stobj --->
<cfset stobj = getData(objectid="#stobj.objectid#") />


<cfset stProfile = createObject("component", application.stcoapi["dmProfile"].packagePath).getProfile(userName="#stobj.userID#", ud="CLIENTUD") />

<cfmail from="#application.config.general.adminemail#" to="#stProfile.emailAddress#" subject="#application.fapi.getResource('coapi.farLogin.clientidreminder@subject','User ID Retrieval')#" type="html">
	<admin:resource key="coapi.farLogin.clientidreminder@html" var1="#stProfile.firstname#" var2="#stProfile.lastname#" var3="#stobj.userID#"><cfoutput>
		<p>Hello {1} {2}</p>
		<p>Your UserID is:</p>
		<div>username: {3}</div>
	</cfoutput></admin:resource>
</cfmail>
