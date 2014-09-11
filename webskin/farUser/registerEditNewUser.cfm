<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />



<skin:view typename="farUser" template="displayHeaderLogin" />


	<cfoutput>
		<div class="loginInfo">
			<admin:resource key="coapi.farLogin.register.blurb@text" var1="#application.fapi.getConfig("general","siteTitle")#">Enter your details below to register for {1}</admin:resource>
		</div>
	</cfoutput>

	<cfset stPropMetadata = structNew()>
	<cfset stPropMetadata.userid.ftLabelAlignment = "block" />
	<cfset stPropMetadata.password.ftLabelAlignment = "block" />
	
<ft:form>
	<cfoutput><br style="clear:both;" /></cfoutput>
	<ft:object objectid="#stobj.objectid#" typename="farUser" lfields="userid,password" stPropMetadata="#stPropMetadata#"/>
	
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
			<li><skin:buildLink href="#application.url.webtoplogin#">Login</skin:buildLink></li></cfoutput>
		<cfoutput></ul></cfoutput>
	</ft:buttonPanel>

</ft:form>	
	

<skin:view typename="farUser" template="displayFooterLogin" />

<cfsetting enablecfoutputonly="false">