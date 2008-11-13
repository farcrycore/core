



<cfset stProperties = structNew() />
<cfset stProperties.objectid = stobj.objectid />
<cfset stProperties.password = "#right(application.fc.utils.createJavaUUID(),8)#" />

<cfset stResult = setData(stProperties="#stProperties#") />

<!--- Refresh stobj --->
<cfset stobj = getData(objectid="#stobj.objectid#") />


<cfset stProfile = createObject("component", application.stcoapi["dmProfile"].packagePath).getProfile(userName="#stobj.userID#", ud="CLIENTUD") />

<cfmail from="#application.config.general.adminemail#" to="#stProfile.emailAddress#" subject="Your Password has been changed." type="html">
<cfoutput>
	<p>Hello #stProfile.firstname# #stProfile.lastname#</p>
	<p>Your New Password is:</p>
	<div>username: #stobj.userID#</div>
	<div>password: #stProperties.password#</div><!--- Use stProperties.password incase password is hashed --->
</cfoutput>
</cfmail>
