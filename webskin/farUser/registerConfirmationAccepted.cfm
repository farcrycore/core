<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfset stProperties = structnew() />
<cfset stProperties.objectid = stobj.objectid />
<cfset stProperties.userstatus = "active" />

<cfset stResult = setData(stProperties="#stProperties#") />

<!--- TODO: Need to login here --->


<skin:view typename="farUser" template="displayHeaderLogin" />

<cfoutput><div class="loginInfo"></cfoutput>

<admin:resource key="coapi.farLogin.register.complete@html" var1="#application.fapi.getLink(objectid=application.fapi.getNavID('home'))#"><cfoutput>
	<p>Your Registration is now complete</p>
	<p><a href="{1}">Click here</a> to return to the home page.</p>
</cfoutput></admin:resource>


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