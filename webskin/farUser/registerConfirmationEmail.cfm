
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />


<cfset stProfile = createObject("component", application.stcoapi["dmProfile"].packagePath).getProfile(userName="#stobj.userid#", ud="CLIENTUD") />

<cfmail from="#application.fapi.getConfig("general","adminemail")#" to="#stProfile.emailAddress#" subject="#application.fapi.getResource('coapi.farLogin.register.confirmationemail@subject','New User Confirmation Email')#" type="html">
	<admin:resource key="coapi.farLogin.register.confirmationemail@html" var1="#stProfile.firstname#" var2="#stProfile.lastname#" var3="#application.fapi.getLink(objectid=stObj.objectid,view='registerConfirmationAccepted',includeDomain=true)#"><cfoutput>
		<p>Hello {1} {2}</p>
		<a href="{3}">Click here to confirm your confirmation</a>
	</cfoutput></admin:resource>
</cfmail>

<skin:location objectid="#stobj.objectid#" type="farUser" view="registerConfirmation" /> 
