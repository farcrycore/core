
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<cfset stProfile = createObject("component", application.stcoapi["dmProfile"].packagePath).getProfile(userName="#stobj.userid#", ud="CLIENTUD") />

<cfmail from="#application.config.general.adminemail#" to="#stProfile.emailAddress#" subject="New User Confirmation Email" type="html">
	<cfoutput><p>Hello #stProfile.firstname# #stProfile.lastname#</p></cfoutput>
	<skin:buildlink objectid="#stobj.objectid#" urlParameters="view=registerConfirmationAccepted" includeDomain="true">CLICK HERE</skin:buildlink> TO CONFIRM YOUR REGISTRATION
</cfmail>

<skin:location objectid="#stobj.objectid#" type="farUser" view="registerConfirmation" /> 
