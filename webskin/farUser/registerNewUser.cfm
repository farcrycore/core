<cfsetting enablecfoutputonly="true">

<!--- @@displayname: Reset password --->
<!--- @@description: Checks the client's security question and answer, then resets their password --->
<!--- @@author:  Blair McKenzie (blair@daemon.com.au) --->

<!--- @@viewBinding: type --->
<!--- @@viewStack: page --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<ft:serverSideValidation />

<ft:processForm action="Register Now">
	<!--- Get the User --->
	<ft:processFormObjects typename="farUser" bSessionOnly="true">
		<cfset stProperties.objectid = createUUID() />
		<cfset stNew = application.fapi.getContentObject(typename="farUser", objectid=createUUID()) />
		<cfset stNew.userstatus = "pending" />
		<cfset stNew.userid = trim(stProperties.userid) />
		<cfset stNew.password = stProperties.password />
		<cfset stNew.aGroups = [ application.fapi.getContentType(typename="farGroup").getID(name="member") ] />
		<cfset application.fapi.setData(stProperties=stNew) />

		<cfif isDefined("session.stTempObjectStoreKeys.farUser.registerNewUser")>
			<cfset structDelete(session.stTempObjectStoreKeys.farUser, "registerNewUser") />
		</cfif>

		<cfset newUserID = stNew.objectid />
		<cfset newUserName = stNew.userid />
	</ft:processFormObjects>


	<ft:processFormObjects typename="dmProfile" bSessionOnly="true">
		<cfset stNew = application.fapi.getContentObject(typename="dmProfile", objectid=createUUID()) />
		<cfset stNew.firstName = stProperties.firstName />
		<cfset stNew.lastname = stProperties.lastname />
		<cfset stNew.emailAddress = stProperties.emailAddress />
		<cfset stNew.userDirectory = "CLIENTUD" />
		<cfset stNew.username = "#newUserName#_CLIENTUD" />
		<cfset application.fapi.setData(stProperties=stNew) />

		<cfif isDefined("session.stTempObjectStoreKeys.dmProfile.registerNewUser")>
			<cfset structDelete(session.stTempObjectStoreKeys.dmProfile, "registerNewUser") />
		</cfif>
	</ft:processFormObjects>

	<!--- This will send the confirmation email and then redirect to the confirmation page --->
	<skin:view objectid="#newUserID#" typename="farUser" webskin="registerConfirmationEmail" />
</ft:processForm>


<!--- GENERATE NEW SESSION OBJECTS AND MAKE SURE THEY ARE STILL IN THE SESSION --->

<skin:view typename="farUser" webskin="registerEditNewUser" key="registerNewUser" />


<cfsetting enablecfoutputonly="false">