<cfsetting enablecfoutputonly="Yes">
<!--- @@displayname: Farcry UD login form --->

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />


		
<cfoutput>
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
	<head> 
		<title>#application.config.general.siteTitle# :: #application.applicationname#</title>
</cfoutput>

<!--- check for custom Admin CSS in project codebase --->
<cfif fileExists("#application.path.project#/www/css/customadmin/admin.css")>
    <cfoutput>
    	<link href="#application.url.webroot#/css/customadmin/admin.css" rel="stylesheet" type="text/css">
    </cfoutput>
<cfelse>
    <cfoutput>
    	<link href="#application.url.farcry#/css/main.css" rel="stylesheet" type="text/css">
    </cfoutput>
</cfif>

<cfoutput>
	</head>
	
	<body id="sec-login">
</cfoutput>


<cfoutput>
	<div id="login">
		
		<h1>
			<a href="#application.url.webroot#/">
</cfoutput>

<!--- if there is a site logo, use it instead of the default placeholder --->       
<cfif structKeyExists(application.config.general,'siteLogoPath') and application.config.general.siteLogoPath NEQ "">
	<cfoutput>
		<img src="#application.config.general.siteLogoPath#" alt="#application.config.general.siteTitle#" />
	</cfoutput>
<cfelse>
	<cfoutput>
		<img src="images/logo_placeholder.gif" alt="#application.config.general.siteTitle#" />
	</cfoutput>
</cfif>

<cfoutput>
			</a>
			#application.config.general.siteTitle#
			<span>#application.config.general.siteTagLine#</span>

		</h1>
		
</cfoutput>
		
	<ft:form>
			
		<cfoutput><div class="loginInfo"></cfoutput>			
			<cfif structKeyExists(server, "stFarcryProjects") AND listLen(structKeyList(server.stFarcryProjects)) GT 1>
				<cfoutput><fieldset class="formSection"></cfoutput>
				
				<cfoutput>
					<select id="selectFarcryProject" onchange="window.location='#application.url.webtop#/login.cfm?returnUrl=#urlencodedformat(url.returnUrl)#&farcryProject='+this.value;">						
						<cfloop list="#structKeyList(server.stFarcryProjects)#" index="thisProject">
							<option value="#thisProject#"<cfif cookie.currentFarcryProject eq thisProject> selected</cfif>>LOGIN TO: #server.stFarcryProjects[thisProject]#</option>
						</cfloop>						
					</select>
				</cfoutput>

				
				<cfoutput></fieldset></cfoutput>		
			</cfif>
			
		
			<sec:SelectUDLogin />
			

			
			
			<ft:object typename="farLogin" lFields="username,password,datetimelastupdated" />
			
			<ft:farcrybuttonPanel>
			

				<cfif isdefined("arguments.stParam.message") and len(arguments.stParam.message)>
					<cfoutput>
						<div class="error">#arguments.stParam.message#</div>
					</cfoutput>
				</cfif>
				
				<ft:farcrybutton value="Log In" />
			</ft:farcrybuttonPanel>
			
			
			
			<cfset stParameters = structNew() />
			<cfset stParameters.returnUrl = "#url.returnUrl#" />
			
			<ft:farcrybuttonPanel>					
				<cfoutput><ul class="fc"></cfoutput>
					<sec:CheckPermission webskinpermission="forgotPassword" type="farUser">
						<skin:buildLink type="farUser" view="forgotPassword" stParameters="#stParameters#"><cfoutput><li>Forgot Password</li></cfoutput></skin:buildLink>
					</sec:CheckPermission>
					<sec:CheckPermission webskinpermission="forgotUserID" type="farUser">
						<skin:buildLink type="farUser" view="forgotUserID" stParameters="#stParameters#"><cfoutput><li>Forgot UserID</li></cfoutput></skin:buildLink>
					</sec:CheckPermission>			
					<sec:CheckPermission webskinpermission="registerNewUser" type="farUser">
						<skin:buildLink type="farUser" view="registerNewUser" stParameters="#stParameters#"><cfoutput><li>Register New User</li></cfoutput></skin:buildLink>
					</sec:CheckPermission>
				<cfoutput></ul></cfoutput>
				
			</ft:farcrybuttonPanel>
			
			

	<cfoutput></div></cfoutput>		
			
</ft:form>

<cfoutput>
		
		<br style="clear:both;" />
		<h3><img src="images/powered_by_farcry_watermark.gif" />Tell it to someone who cares</h3>

		<p style="text-align:right;border-top:1px solid ##e3e3e3;margin-top:25px;"><small>#createObject("component", "#application.packagepath#.farcry.sysinfo").getVersionTagline()#</small></p>
	</div>
	
</cfoutput>

<cfoutput>
	</body>
</html>
</cfoutput>