<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


		
<cfoutput>
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
	<head> 
		<title>#application.config.general.siteTitle# :: #application.applicationname#</title>

		<!--- check for custom Admin CSS in project codebase --->
		<cfif fileExists("#application.path.project#/www/css/customadmin/admin.css")>
		    <link href="#application.url.webroot#/css/customadmin/admin.css" rel="stylesheet" type="text/css">
		<cfelse>
		    <link href="#application.url.farcry#/css/main.css" rel="stylesheet" type="text/css">
		</cfif>
	</head>
	<body id="sec-login">
	<div id="login">
		<h1>
			<a href="#application.url.webroot#/">
	
			<!--- if there is a site logo, use it instead of the default placeholder --->       
			<cfif structKeyExists(application.config.general,'siteLogoPath') and application.config.general.siteLogoPath NEQ "">
				<img src="#application.config.general.siteLogoPath#" alt="#application.config.general.siteTitle#" />
			<cfelse>
				<img src="#application.url.webtop#/images/logo_placeholder.gif" alt="#application.config.general.siteTitle#" />
			</cfif>

			</a>
			#application.config.general.siteTitle#
			<span>#application.config.general.siteTagLine#</span>

		</h1>
</cfoutput>

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
		<cfoutput><ul></cfoutput>
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
	
<cfoutput>
		<h3><img src="images/powered_by_farcry_watermark.gif" />Tell it to someone who cares</h3>
		<p style="text-align:right;border-top:1px solid ##e3e3e3;margin-top:25px;"><small>#createObject("component", "#application.packagepath#.farcry.sysinfo").getVersionTagline()#</small></p>
	</div>

	</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="false">