<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />



<skin:view typename="farUser" template="displayHeaderLogin" />


	<cfoutput>
		<div class="loginInfo">
			Enter your details below to register for #application.config.general.siteTitle#
		</div>
	</cfoutput>

<ft:form>
	<cfoutput><br style="clear:both;" /></cfoutput>
	<ft:object objectid="#stobj.objectid#" typename="farUser" lfields="userid,password" />
	
	<skin:view typename="dmProfile" webskin="registerEditNewProfile" key="registerNewUser" />
	
	<ft:buttonPanel>
		<ft:button value="Register Now" />
	</ft:buttonPanel>
	
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
			<li><skin:buildLink href="#application.url.webtop#/login.cfm">Login</skin:buildLink></li></cfoutput>
		<cfoutput></ul></cfoutput>
	</ft:buttonPanel>

</ft:form>	
	

<skin:view typename="farUser" template="displayFooterLogin" />

<cfsetting enablecfoutputonly="false">