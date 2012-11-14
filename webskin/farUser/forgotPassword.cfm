<cfsetting enablecfoutputonly="true">

<!--- @@displayname: Reset password --->
<!--- @@description: Checks the client's security question and answer, then resets their password --->
<!--- @@author:  Blair McKenzie (blair@daemon.com.au) --->

<!--- @@viewBinding: type --->
<!--- @@viewStack: page --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />


<ft:processForm action="Reset Password">
	<!--- Get the User --->

	<ft:processFormObjects typename="farUser">
		<cfset stUser = createObject("component", application.stcoapi["farUser"].packagePath).getByUserID(userid="#stProperties.userID#") />
		
		<cfif not structIsEmpty(stUser)>
			<skin:view objectid="#stUser.objectid#" typename="farUser" webskin="forgotChangePasswordEmail" />
			
			<cfset request.passwordChanged = true />
		<cfelse>
			<cfset request.notFound = true />
		</cfif>

		<ft:break />
	</ft:processFormObjects>

</ft:processForm>




<skin:view typename="farUser" template="displayHeaderLogin" />


<cfoutput><div class="loginInfo"></cfoutput>

	<ft:form>
		
		<cfif structKeyExists(request, "notFound")>
			<cfoutput>
				<p id="errorMsg"><admin:resource key="coapi.farUser.forgotpassword.unknownuser@text">We do not have that User ID on record. Please try again</admin:resource></p>
			</cfoutput>
		</cfif>	

		<cfif structKeyExists(request, "passwordChanged")>
			<cfoutput>
				<p id="OKMsg"><admin:resource key="coapi.farUser.forgotpassword.passwordreset@text">A link to change your password has been sent to your email address and should arrive shortly.</admin:resource></p>
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
		
		
		<cfoutput><ul class="loginForgot"></cfoutput>
		<sec:CheckPermission webskinpermission="forgotUserID" type="farUser">
			<cfoutput>
				<li><skin:buildLink type="farUser" view="forgotUserID" rbkey="coapi.farLogin.login.forgotuserid">Forgot UserID</skin:buildLink></li></cfoutput>
		</sec:CheckPermission>			
		<sec:CheckPermission webskinpermission="registerNewUser" type="farUser">
			<cfoutput> 
				<li><skin:buildLink type="farUser" view="registerNewUser" rbkey="coapi.farLogin.login.registernewuser">Register New User</skin:buildLink></li></cfoutput>
		</sec:CheckPermission>			
			
		<cfoutput> 
			<li><skin:buildLink href="#application.url.webtoplogin#" rbkey="coapi.farLogin.login.login">Login</skin:buildLink></li></cfoutput>
		<cfoutput></ul></cfoutput>
	

	
	
	</ft:form>

<cfoutput></div></cfoutput>
		


<skin:view typename="farUser" template="displayFooterLogin" />



<cfsetting enablecfoutputonly="false">