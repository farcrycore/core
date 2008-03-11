<cfsetting enablecfoutputonly="true">

<!--- @@displayname: Reset password --->
<!--- @@description: Checks the client's security question and answer, then resets their password --->
<!--- @@author:  Blair McKenzie (blair@daemon.com.au) --->


<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />


<ft:processForm action="Reset Password">
	
	<ft:processFormObjects typename="dmProfile">
		
		<cfif structKeyExists(stProperties, "emailAddress") AND len(stProperties.emailAddress)>
			<cfquery datasource="#application.dsn#" name="qProfileFromEmail">
			SELECT objectid,username 
			FROM dmProfile
			WHERE emailAddress = '#stProperties.emailAddress#'
			AND userDirectory = 'CLIENTUD'
			</cfquery>
			
			<cfif qProfileFromEmail.recordCount>
				<cfset stUser = createObject("component", application.stcoapi["farUser"].packagePath).getByUserID(userID="#listFirst(qProfileFromEmail.username,"_")#") />
				
				<skin:view objectid="#stUser.objectid#" typename="farUser" webskin="forgotChangePasswordEmail" />
				
				<cfset request.passwordChanged = true />
			<cfelse>
				<cfset request.notFound = true />
			</cfif>

		</cfif>
	</ft:processFormObjects>
</ft:processForm>


		
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
<cfoutput><div class="loginInfo"></cfoutput>

	
		
		
		<cfif structKeyExists(request, "notFound")>
			<cfoutput>
				<p class="error">We do not have that email address on record. Please try again</p>
			</cfoutput>
		</cfif>	
			
		<cfif structKeyExists(request, "passwordChanged")>
			<cfoutput>
				<p>A confirmation email with your NEW password has been sent to your email address and should arrive shortly.</p>
			</cfoutput>
		<cfelse>
			<cfoutput>
				<p>So you forgot your userid. Please enter your email address below to reset. An email with your new password will be sent to your email address.</p>
			</cfoutput>

				<ft:object typename="dmProfile" lfields="emailAddress" />

				<ft:farcryButtonPanel>
					<ft:farcryButton value="Reset Password" />
				</ft:farcryButtonPanel>

		</cfif>
			
		<cfset stParameters = structNew() />
		<cfset stParameters.returnUrl = "#url.returnUrl#" />
		
		<ft:farcryButtonPanel>
			<cfoutput><ul></cfoutput>
			<sec:CheckPermission webskinpermission="forgotPassword" type="farUser">
				<skin:buildLink type="farUser" view="forgotPassword" stParameters="#stParameters#"><cfoutput><li>Forgot Password</li></cfoutput></skin:buildLink>
			</sec:CheckPermission>		
			<sec:CheckPermission webskinpermission="registerNewUser" type="farUser">
				<skin:buildLink type="farUser" view="registerNewUser" stParameters="#stParameters#"><cfoutput><li>Register New User</li></cfoutput></skin:buildLink>
			</sec:CheckPermission>			
				
			<skin:buildLink href="/webtop/login.cfm" stParameters="#stParameters#"><cfoutput><li>Login</li></cfoutput></skin:buildLink>
			<cfoutput></ul></cfoutput>
		</ft:farcryButtonPanel>
			
	
	
<cfoutput></div></cfoutput>
</ft:form>

<cfoutput>
		<h3><img src="images/powered_by_farcry_watermark.gif" />Tell it to someone who cares</h3>
		<p style="text-align:right;border-top:1px solid ##e3e3e3;margin-top:25px;"><small>#createObject("component", "#application.packagepath#.farcry.sysinfo").getVersionTagline()#</small></p>
	</div>

	</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="false">