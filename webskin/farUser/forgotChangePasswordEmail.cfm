<cfset stProperties = structNew() />
<cfset stProperties.objectid = stobj.objectid />
<cfset stProperties.forgotPasswordHash = application.fc.utils.generateRandomString() />

<cfset stResult = setData(stProperties="#stProperties#") />

<cfset stProfile = createObject("component", application.stcoapi["dmProfile"].packagePath).getProfile(userName="#stobj.userID#", ud="CLIENTUD") />

<cfmail from="#application.config.general.adminemail#" to="#stProfile.emailAddress#" subject="Password reset" type="html">
<cfoutput>
	<p>Hello #stProfile.firstname# #stProfile.lastname#</p>

	<p><a href="#application.fapi.getLink(type="farUser",view="forgotPasswordReset",includeDomain=true,urlParameters="rh=#stProperties.forgotPasswordHash#")#">Click here to reset your Password</a></p>
</cfoutput>
</cfmail>
