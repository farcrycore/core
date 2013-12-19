<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Reset password --->
<!--- @@viewBinding: type --->
<!--- @@viewStack: page --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />


<ft:processform action="Reset Password">
	<!--- Get the User --->
	<ft:processformobjects typename="farUser" >
		<cfset stUser = getByUserID(userid="#stProperties.userID#") />
		
		<cfif not structIsEmpty(stUser)>
			<skin:view objectid="#stUser.objectid#" typename="farUser" webskin="forgotChangePasswordEmail" />
			
			<cfset request.passwordChanged = true />
		<cfelse>
			<cfset request.notFound = true />
		</cfif>

		<ft:break />
	</ft:processformobjects>

</ft:processform>


<skin:view typename="farUser" template="displayHeaderLogin" />

<cfoutput><div class="loginInfo"></cfoutput>

	<ft:form>
		
		<cfif structKeyExists(request, "notFound")>
			<cfoutput>
				<p class="alert alert-error"><admin:resource key="coapi.farUser.forgotpassword.unknownuser@text">We do not have that User ID on record. Please try again</admin:resource></p>
			</cfoutput>
		</cfif>	

		<cfif structKeyExists(request, "passwordChanged")>
			<cfoutput>
				<p class="alert alert-success"><admin:resource key="coapi.farUser.forgotpassword.passwordreset@text">A link to change your password has been sent to your email address and should arrive shortly.</admin:resource></p>
			</cfoutput>
		<cfelse>
			<cfoutput>
				<p><admin:resource key="coapi.farUser.forgotpassword.blurb@text">So you forgot your password. Please enter your userid below to reset. An email with a link to change your password will be sent to your email address.</admin:resource></p>
			</cfoutput>

			<ft:object typename="farUser" lfields="userID" />

			<ft:buttonPanel>
				<ft:button value="Reset Password" rbkey="security.button.resetpassword" />
			</ft:buttonPanel>
		</cfif>

		<cfoutput>
			<p class="help-inline">
				<skin:buildLink href="#application.url.webtoplogin#" rbkey="coapi.farLogin.login.login">Login</skin:buildLink>
				<sec:CheckPermission webskinpermission="forgotUserID" type="farUser">
					&middot;
					<skin:buildLink type="farUser" view="forgotUserID" rbkey="coapi.farLogin.login.forgotuserid">Forgot Username</skin:buildLink>
				</sec:CheckPermission>
				<sec:CheckPermission webskinpermission="registerNewUser" type="farUser">
					&middot;
					<skin:buildLink type="farUser" view="registerNewUser" rbkey="coapi.farLogin.login.registernewuser">Register New User</skin:buildLink>
				</sec:CheckPermission>
			</p>
		</cfoutput>

	</ft:form>

<cfoutput></div></cfoutput>

<skin:view typename="farUser" template="displayFooterLogin" />

<cfsetting enablecfoutputonly="false">