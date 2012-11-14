
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />



<skin:view typename="farUser" template="displayHeaderLogin" />

<cfoutput><div class="loginInfo"></cfoutput>

<cfswitch expression="#stobj.userStatus#">
	<cfcase value="pending">
		<admin:resource key="coapi.farLogin.register.pending@html"><cfoutput><p>Thank you for registering. You should recieve a confirmation email shortly.</p></cfoutput></admin:resource>
	</cfcase>
	
	<cfcase value="active">
		<admin:resource key="coapi.farLogin.register.active@html"><cfoutput><p>Your registration is complete</p></cfoutput></admin:resource>
	</cfcase>
	
	<cfdefaultcase>
		<admin:resource key="coapi.farLogin.register.invalid@html"><cfoutput><p>Not a valid registration. Would you like to register now?</p></cfoutput></admin:resource>
		<cfoutput><p><skin:buildLink type="farUser" view="registerNewUser" rbkey="coapi.farLogin.login.registernow">Register Now</skin:buildLink></p></cfoutput>
	</cfdefaultcase>
</cfswitch>

<ft:buttonPanel>
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
</ft:buttonPanel>


<cfoutput></div></cfoutput>


<skin:view typename="farUser" template="displayFooterLogin" />