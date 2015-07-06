<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Reset password --->
<!--- @@viewBinding: type --->
<!--- @@viewStack: page --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />


<cfset stMeta = structNew()>
<cfset stMeta.userid = structNew()>
<cfset stMeta.userid.ftLabel = "Username">

<cfset errormsg = "">

<ft:processform action="Reset Password">
	<!--- Get the User --->
	<ft:processformobjects typename="farUser" bSessionOnly="true">
		<cfset stUser = getByUserID(userid=form.forgot_userid) />
		
		<cfif not structIsEmpty(stUser)>
			<cftry>
				<skin:view objectid="#stUser.objectid#" typename="farUser" webskin="forgotChangePasswordEmail" />
				<cfset request.passwordChanged = true />
				<cfcatch>
					<!--- error sending email --->
					<cfset application.fc.lib.error.logData(application.fc.lib.error.normalizeError(cfcatch)) />
					<cfset errormsg = "There was an error sending your password reset link by email. Please contact your administrator.">
				</cfcatch>
			</cftry>
		<cfelse>
			<cfsavecontent variable="errormsg">
				<cfoutput><admin:resource key="coapi.farUser.forgotpassword.unknownuser@text">We do not have that username on record. Please try again</admin:resource></cfoutput>
			</cfsavecontent>
		</cfif>

		<ft:break />
	</ft:processformobjects>

</ft:processform>


<skin:view typename="farUser" template="displayHeaderLogin" />


<cfoutput>

<style type="text/css">
.form-inline .control-label {
	width: auto;
}
.form-inline .controls {
	margin-left: 0;
}
</style>


<div class="loginInfo">

	<ft:form>
		
		<cfif len(trim(errormsg))>
			<p class="alert alert-error">#trim(errormsg)#</p>
		</cfif>	

		<cfif structKeyExists(request, "passwordChanged")>
			<p class="alert alert-success"><admin:resource key="coapi.farUser.forgotpassword.passwordreset@text">A link to change your password has been sent to your email address and should arrive shortly.</admin:resource></p>
		<cfelse>
			<p><admin:resource key="coapi.farUser.forgotpassword.blurb@text"><strong>Forgot your password?</strong> Please enter your username below and a link to change your password will be sent to your email address.</admin:resource></p>

			<div class="form-inline">
				<ft:object prefix="forgot_" typename="farUser" lfields="userID" stPropMetadata="#stMeta#" />
			</div>

			<ft:buttonPanel>
				<ft:button value="Reset Password" rbkey="security.button.resetpassword" />
			</ft:buttonPanel>
		</cfif>

		<p class="help-inline">
			<skin:buildLink href="#application.url.webtoplogin#" rbkey="coapi.farLogin.login.login">Login</skin:buildLink>
			<sec:CheckPermission webskinpermission="forgotUserID" type="farUser">
				&middot;
				<skin:buildLink type="farUser" view="forgotUserID" rbkey="coapi.farLogin.login.forgotuserid">Forgot Username</skin:buildLink>
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