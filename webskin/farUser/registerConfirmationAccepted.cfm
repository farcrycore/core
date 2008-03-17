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
	<cfoutput><ul class="fc"></cfoutput>
	<sec:CheckPermission webskinpermission="forgotUserID" type="farUser">
		<skin:buildLink type="farUser" view="forgotUserID" urlParameters="returnUrl=#url.returnUrl#"><cfoutput><li>Forgot UserID</li></cfoutput></skin:buildLink>
	</sec:CheckPermission>			
	<sec:CheckPermission webskinpermission="registerNewUser" type="farUser">
		<skin:buildLink type="farUser" view="registerNewUser" urlParameters="returnUrl=#url.returnUrl#"><cfoutput><li>Register New User</li></cfoutput></skin:buildLink>
	</sec:CheckPermission>			
		
	<skin:buildLink href="/webtop/login.cfm" urlParameters="returnUrl=#url.returnUrl#"><cfoutput><li>Login</li></cfoutput></skin:buildLink>
	<cfoutput></ul></cfoutput>
</ft:farcryButtonPanel>

<cfoutput></div></cfoutput>


<skin:view typename="farUser" template="displayFooterLogin" />