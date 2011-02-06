
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />



<skin:view typename="farUser" template="displayHeaderLogin" />

<cfoutput><div class="loginInfo"></cfoutput>

<cfswitch expression="#stobj.userStatus#">
<cfcase value="pending">

	<cfoutput><p>Thank you for registering. You should recieve a confirmation email shortly.</p></cfoutput>
	
</cfcase>

<cfcase value="active">
	<cfoutput><p>Your registration is complete</p></cfoutput>
</cfcase>

<cfdefaultcase>
	<cfoutput><p>Not a valid registration. Would you like to register now?</p></cfoutput>
	
	
	<cfoutput><p><skin:buildLink type="farUser" view="registerNewUser">Register Now</skin:buildLink></p></cfoutput>
</cfdefaultcase>
</cfswitch>

<ft:buttonPanel>
	<cfoutput><ul class="loginForgot"></cfoutput>
	<sec:CheckPermission webskinpermission="forgotUserID" type="farUser">
		<cfoutput>
			<li><skin:buildLink type="farUser" view="forgotUserID">Forgot UserID</skin:buildLink></li></cfoutput>
	</sec:CheckPermission>			
	<sec:CheckPermission webskinpermission="registerNewUser" type="farUser">
		<cfoutput>
			<li><skin:buildLink type="farUser" view="registerNewUser">Register New User</skin:buildLink></li></cfoutput>
	</sec:CheckPermission>			
		
	<cfoutput>
		<li><skin:buildLink href="#application.url.webtoplogin#">Login</skin:buildLink></li></cfoutput>
	<cfoutput></ul></cfoutput>
</ft:buttonPanel>


<cfoutput></div></cfoutput>


<skin:view typename="farUser" template="displayFooterLogin" />