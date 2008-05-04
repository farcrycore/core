<cfsetting enablecfoutputonly="true">

<!--- @@displayname: Reset password --->
<!--- @@description: Checks the client's security question and answer, then resets their password --->
<!--- @@author:  Blair McKenzie (blair@daemon.com.au) --->


<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />


<ft:processForm action="Reset Password">
	
	<ft:processFormObjects typename="dmProfile">
		
		<cfif structKeyExists(stProperties, "emailAddress") AND len(stProperties.emailAddress)>
			<cfquery datasource="#application.dsn#" name="qProfileFromEmail">
			SELECT objectid,username 
			FROM dmProfile
			WHERE emailAddress = '#stProperties.emailAddress#'
			AND userDirectory = 'CLIENTUD'
			</cfquery>
			
			<cfif qProfileFromEmail.recordCount>
				<cfset stUser = createObject("component", application.stcoapi["farUser"].packagePath).getByUserID(userID="#listFirst(qProfileFromEmail.username,"_")#") />
				
				<skin:view objectid="#stUser.objectid#" typename="farUser" webskin="forgotChangePasswordEmail" />
				
				<cfset request.passwordChanged = true />
			<cfelse>
				<cfset request.notFound = true />
			</cfif>

		</cfif>
	</ft:processFormObjects>
</ft:processForm>



<skin:view typename="farUser" template="displayHeaderLogin" />


<cfoutput><div class="loginInfo"></cfoutput>
	<ft:form>
	
		
		
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
				<p>So you forgot your userid. Please enter your email address below to reset. An email with your new password will be sent to your email address.</p>
			</cfoutput>

				<ft:object typename="dmProfile" lfields="emailAddress" />

				<ft:farcryButtonPanel>
					<ft:farcryButton value="Reset Password" />
				</ft:farcryButtonPanel>

		</cfif>
			
		<cfset stParameters = structNew() />
		<cfset stParameters.returnUrl = "#url.returnUrl#" />
		
		<ft:farcryButtonPanel>
			<cfoutput><ul class="loginForgot"></cfoutput>
			<sec:CheckPermission webskinpermission="forgotPassword" type="farUser">
				<cfoutput>
					<li><skin:buildLink type="farUser" view="forgotPassword" stParameters="#stParameters#">Forgot Password</skin:buildLink></li></cfoutput>
			</sec:CheckPermission>		
			<sec:CheckPermission webskinpermission="registerNewUser" type="farUser">
				<cfoutput>
					<li><skin:buildLink type="farUser" view="registerNewUser" stParameters="#stParameters#">Register New User</skin:buildLink></li></cfoutput>
			</sec:CheckPermission>			
				
			<cfoutput>
				<li><skin:buildLink href="/webtop/login.cfm" stParameters="#stParameters#">Login</skin:buildLink></li></cfoutput>
			<cfoutput></ul></cfoutput>
		</ft:farcryButtonPanel>
			
	</ft:form>

	
<cfoutput></div></cfoutput>


<skin:view typename="farUser" template="displayFooterLogin" />

<cfsetting enablecfoutputonly="false">