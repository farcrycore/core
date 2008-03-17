<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />



<skin:view typename="farUser" template="displayHeaderLogin" />

<ft:form>
	<cfoutput>
		<div class="loginInfo">
			Enter your details below to register for #application.config.general.siteTitle#
		</div>
	</cfoutput>

	<cfoutput><br style="clear:both;" /></cfoutput>
	<ft:object objectid="#stobj.objectid#" typename="farUser" lfields="userid,password" />
	
	<skin:view typename="dmProfile" webskin="registerEditNewProfile" key="registerNewUser" />
	
	<ft:farcryButtonPanel>
		<ft:farcryButton value="Register Now" />
	</ft:farcryButtonPanel>

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

</ft:form>	
	

<skin:view typename="farUser" template="displayFooterLogin" />

<cfsetting enablecfoutputonly="false">