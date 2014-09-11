<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfset stProperties = structNew() />
<cfset stProperties.objectid = stobj.objectid />
<cfset stProperties.forgotPasswordHash = application.fc.utils.generateRandomString() />

<cfset stResult = setData(stProperties="#stProperties#") />

<cfset stProfile = createObject("component", application.stcoapi["dmProfile"].packagePath).getProfile(userName="#stobj.userID#", ud="CLIENTUD") />

<cfmail from="#application.fapi.getConfig("general","adminemail")#" to="#stProfile.emailAddress#" subject="#application.fapi.getResource('coapi.farLogin.resetpassword@subject','Password reset')#" type="html">
	<admin:resource key="coapi.farLogin.resetpassword@html" var1="#stProfile.firstname#" var2="#stProfile.lastname#" var3="#application.fapi.getLink(type='farUser',view='forgotPasswordReset',urlParameters='rh=#stProperties.forgotPasswordHash#',includeDomain=true)#"><cfoutput>
		<p>Hello {1} {2}</p>
		<p><a href="{3}">Click here to reset your Password</a></p>
	</cfoutput></admin:resource>
</cfmail>