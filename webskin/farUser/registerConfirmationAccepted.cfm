<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset stProperties.objectid = stobj.objectid />
<cfset stProperties.userstatus = "active" />

<cfset stResult = setData(stProperties="#stProperties#") />

<!--- TODO: Need to login here --->


<skin:view typename="farUser" template="displayHeaderLogin" />

<cfoutput><div class="loginInfo"></cfoutput>

<cfoutput>
	<p>Your Registration is now complete</p>
	<p><skin:buildLink objectid="#application.navid.home#">Click here</skin:buildlink> to return to the home page.</p>
</cfoutput>

<cfparam name="url.returnUrl" default="/">

<ft:farcryButtonPanel>
	<cfoutput><ul class="loginForgot"></cfoutput>
	<sec:CheckPermission webskinpermission="forgotUserID" type="farUser">
		<cfoutput>
			<li><skin:buildLink type="farUser" view="forgotUserID" urlParameters="returnUrl=#url.returnUrl#">Forgot UserID</skin:buildLink></li></cfoutput>
	</sec:CheckPermission>			
	<sec:CheckPermission webskinpermission="registerNewUser" type="farUser">
		<cfoutput>
			<li><skin:buildLink type="farUser" view="registerNewUser" urlParameters="returnUrl=#url.returnUrl#">Register New User</skin:buildLink></li></cfoutput>
	</sec:CheckPermission>			
		
	<cfoutput>
		<li><skin:buildLink href="/webtop/login.cfm" urlParameters="returnUrl=#url.returnUrl#">Login</skin:buildLink></li></cfoutput>
	<cfoutput></ul></cfoutput>
</ft:farcryButtonPanel>

<cfoutput></div></cfoutput>


<skin:view typename="farUser" template="displayFooterLogin" />