
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />



<skin:view typename="farUser" template="displayHeaderLogin" />

<cfoutput><div class="loginInfo"></cfoutput>

<cfswitch expression="#stobj.userStatus#">
<cfcase value="pending">

	<cfoutput><p>Thank you for registering. You should recieve a confirmation email shortly.</p></cfoutput>
	
	
	<cfoutput><p><skin:buildLink objectid="#stobj.objectID#" urlParameters="view=registerConfirmationEmail">Resend</skin:buildLink> Confirmation email</p></cfoutput>
</cfcase>

<cfcase value="active">
	<cfoutput><p>Your registration is complete</p></cfoutput>
</cfcase>

<cfdefaultcase>
	<cfoutput><p>Not a valid registration. Would you like to register now?</p></cfoutput>
	
	
	<cfoutput><p><skin:buildLink type="farUser" view="registerNewUser">Register Now</skin:buildLink></p></cfoutput>
</cfdefaultcase>
</cfswitch>

<cfparam name="url.returnURL" default="" />

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


<skin:view typename="farUser" template="displayFooterLogin" />