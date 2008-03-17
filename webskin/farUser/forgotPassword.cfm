<cfsetting enablecfoutputonly="true">

<!--- @@displayname: Reset password --->
<!--- @@description: Checks the client's security question and answer, then resets their password --->
<!--- @@author:  Blair McKenzie (blair@daemon.com.au) --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />


<ft:processForm action="Reset Password">
	<!--- Get the User --->

	<ft:processFormObjects typename="farUser">
		<cfset stUser = createObject("component", application.stcoapi["farUser"].packagePath).getByUserID(userid="#stProperties.userID#") />
		
		<cfif not structIsEmpty(stUser)>
			<skin:view objectid="#stUser.objectid#" webskin="forgotChangePasswordEmail" />
			
			<cfset request.passwordChanged = true />
		<cfelse>
			<cfset request.notFound = true />
		</cfif>

		<ft:break />
	</ft:processFormObjects>

</ft:processForm>




<skin:view typename="farUser" template="displayHeaderLogin" />

<ft:form>
<cfoutput><div class="loginInfo"></cfoutput>

	
		
		<cfif structKeyExists(request, "notFound")>
			<cfoutput>
				<p class="error">We do not have that email address on record. Please try again</p>
			</cfoutput>
		</cfif>	

		<cfif structKeyExists(request, "passwordChanged")>
			<cfoutput>
				<p>A confirmation email with your NEW password has been sent to your email address and should arrive shortly.</p>
			</cfoutput>
		<cfelse>
			<cfoutput>
				<p>So you forgot your password. Please enter your userid below to reset. An email with your new password will be sent to your email address.</p>
			</cfoutput>

			<ft:object typename="farUser" lfields="userID" />

			<ft:farcryButtonPanel>
				<ft:farcryButton value="Reset Password" />
			</ft:farcryButtonPanel>

		</cfif>
			
		<cfset stParameters = structNew() />
		<cfset stParameters.returnUrl = "#url.returnUrl#" />
		
		<ft:farcryButtonPanel>
			<cfoutput><ul class="fc"></cfoutput>
			<sec:CheckPermission webskinpermission="forgotUserID" type="farUser">
				<skin:buildLink type="farUser" view="forgotUserID" stParameters="#stParameters#"><cfoutput><li>Forgot UserID</li></cfoutput></skin:buildLink>
			</sec:CheckPermission>			
			<sec:CheckPermission webskinpermission="registerNewUser" type="farUser">
				<skin:buildLink type="farUser" view="registerNewUser" stParameters="#stParameters#"><cfoutput><li>Register New User</li></cfoutput></skin:buildLink>
			</sec:CheckPermission>			
				
			<skin:buildLink href="/webtop/login.cfm" stParameters="#stParameters#"><cfoutput><li>Login</li></cfoutput></skin:buildLink>
			<cfoutput></ul></cfoutput>
		</ft:farcryButtonPanel>

	
	


<cfoutput></div></cfoutput>
</ft:form>		


<skin:view typename="farUser" template="displayFooterLogin" />



<cfsetting enablecfoutputonly="false">