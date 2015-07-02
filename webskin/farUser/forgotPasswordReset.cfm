<cfsetting enablecfoutputonly="true">

<!--- @@displayname: Reset password --->
<!--- @@description: Checks sent has to let the user reset his password --->
<!--- @@author:  Fredi (fredi@daemon.com.au) --->

<!--- @@viewBinding: type --->
<!--- @@viewStack: page --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />


<cfset errormsg = "Password reset failed">

<ft:processForm action="Reset Password">
	<!--- check user again --->
	<cfif StructKeyExists(session,"resetPWUserID")
			AND structKeyExists(FORM, "#FORM.farcryFormPrefixes#objectid") 
			AND session.resetPWUserID eq FORM["#FORM.farcryFormPrefixes#objectid"]
		>
		
		<ft:validateFormObjects typename="farUser" objectid="#session.resetPWUserID#" />

		<cfif request.stFarcryFormValidation.bSuccess>
			<ft:processFormObjects typename="farUser" r_stProperties="stProperties">
				<cfif structKeyExists(stProperties, "password")>
				
					<cfset structDelete(session,"resetPWUserID")>
				
					<cfset request.pwchanged = true />
					
					<!--- Clear out the password reset key --->
					<cfset stProperties.forgotPasswordHash = "" />
				<cfelse>
					<cfset request.error = true />
				</cfif>
			</ft:processFormObjects>
		<cfelse>
			<cfset request.error = true />
			<cfset errormsg = "Your passwords did not match. Please try again.">
			<cfif structKeyExists(request.stFarcryFormValidation, session.resetPWUserID)>
				<cfset errorObj = request.stFarcryFormValidation[session.resetPWUserID]>
				<cfif isDefined("errorObj.password.stError.message")>
					<cfset errormsg = errorObj.password.stError.message>
				</cfif>
			</cfif>
		</cfif>
	<cfelse>
		<cfset request.error = true />
	</cfif>	
		
</ft:processForm>

<skin:view typename="farUser" template="displayHeaderLogin" />


<cfoutput>

<div class="loginInfo">
	<ft:form>
		
		<cfif structKeyExists(request, "error")>
			<p class="alert alert-error">#errormsg#</p>
		</cfif>	
			
		<cfif structKeyExists(request, "pwchanged")>
			<p class="alert alert-success">
				<admin:resource key="coapi.farUser.forgotpassword.passwordchanged@text">Your password has been changed!</admin:resource><br/>
			</p>
		<cfelse>
			<cfif structKeyExists(session,"resetPWUserID")> <!--- typed in a wrong password --->
				<ft:object typename="farUser" objectid="#session.resetPWUserID#" lfields="password" r_stFields="stFields" />
				
				<cfoutput>#stFields.password.html#</cfoutput>

				<ft:buttonPanel>
					<ft:button value="Reset Password" />
				</ft:buttonPanel>
			<cfelseif structKeyExists(url,"rh") and application.fc.utils.isGeneratedRandomString(url.rh)> <!--- coming from email --->
				<!--- check which user it is --->
				<cfquery datasource="#application.dsn#" name="qFarUser">
					SELECT objectid
					FROM farUser
					WHERE forgotPasswordHash = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.rh#">
				</cfquery>
				
				<cfif qFarUser.recordCount eq 1>
					<!--- Set reset hash into session to make sure it is still the same user when updating --->
					<cfset session.resetPWUserID = qFarUser.objectid>
					
					<ft:object typename="farUser" objectid="#qFarUser.objectid#" lfields="password" r_stFields="stFields" />
	
					<cfoutput>#stFields.password.html#</cfoutput>

					<ft:buttonPanel>
						<ft:button value="Reset Password" />
					</ft:buttonPanel>
				<cfelse>
					<p class="alert alert-error"><admin:resource key="coapi.farUser.forgotpassword.resetfailed@text">Password reset failed</admin:resource></p>
				</cfif>			
			<cfelseif NOT structKeyExists(request, "error")> <!--- page called without valid reset hash --->
				<p class="alert alert-error"><admin:resource key="coapi.farUser.forgotpassword.resetfailed@text">Password reset failed</admin:resource></p>
			</cfif>
			
		</cfif>
	
		<p class="help-inline">
			<skin:buildLink href="#application.url.webtoplogin#" rbkey="coapi.farLogin.login.login">Login</skin:buildLink>
			<sec:CheckPermission webskinpermission="forgotUserID" type="farUser">
				&middot;
				<skin:buildLink type="farUser" view="forgotUserID" rbkey="coapi.farLogin.login.forgotuserid">Forgot Username</skin:buildLink>
			</sec:CheckPermission>
			<sec:CheckPermission webskinpermission="forgotUserID" type="farUser">
				&middot;
				<skin:buildLink type="farUser" view="forgotPassword" rbkey="coapi.farLogin.login.forgotpassword">Forgot Password</skin:buildLink>
			</sec:CheckPermission>
			<sec:CheckPermission webskinpermission="registerNewUser" type="farUser">
				&middot;
				<skin:buildLink type="farUser" view="registerNewUser" rbkey="coapi.farLogin.login.registernewuser">Register New User</skin:buildLink>	
			</sec:CheckPermission>
		</p>

	</ft:form>
	
</div>
</cfoutput>

<skin:view typename="farUser" template="displayFooterLogin" />

<cfsetting enablecfoutputonly="false">