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
	<ft:processFormObjects typename="farUser">
		<cfset stProperties.userstatus = "pending" />
		<cfset stProperties.userid = trim(stProperties.userid) />

		<cfset newUserID = stProperties.objectid />
		<cfset newUserName = stProperties.userid />

		<cfset createObject("component", application.stcoapi["farUser"].packagePath).addGroup(user="#newUserID#", group="member") />
	</ft:processFormObjects>


	<ft:processFormObjects typename="dmProfile">
		<cfset stProperties.userDirectory = "CLIENTUD" />
		<cfset stProperties.username = "#newUserName#_CLIENTUD" />
	</ft:processFormObjects>

	<!--- This will send the confirmation email and then redirect to the confirmation page --->
	<skin:view objectid="#newUserID#" typename="farUser" webskin="registerConfirmationEmail" />
</ft:processForm>


<!--- GENERATE NEW SESSION OBJECTS AND MAKE SURE THEY ARE STILL IN THE SESSION --->

<skin:view typename="farUser" webskin="registerEditNewUser" key="registerNewUser" />


<cfsetting enablecfoutputonly="false">