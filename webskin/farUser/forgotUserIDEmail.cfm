




<!--- Refresh stobj --->
<cfset stobj = getData(objectid="#stobj.objectid#") />


<cfset stProfile = createObject("component", application.stcoapi["dmProfile"].packagePath).getProfile(userName="#stobj.userID#", ud="CLIENTUD") />

<cfmail from="#application.config.general.adminemail#" to="#stProfile.emailAddress#" subject="User ID Retrieval." type="html">
<cfoutput>
	<p>Hello #stProfile.firstname# #stProfile.lastname#</p>
	<p>Your UserID is:</p>
	<div>username: #stobj.userID#</div>
</cfoutput>
</cfmail>
