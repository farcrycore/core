<cfsetting enablecfoutputonly="true">

<!--- @@displayname: Reset password --->
<!--- @@description: Checks the client's security question and answer, then resets their password --->
<!--- @@author:  Blair McKenzie (blair@daemon.com.au) --->

<!--- @@viewBinding: type --->
<!--- @@viewStack: page --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />


<cfset errormsg = "">

<ft:processForm action="Retrieve Username">
	<ft:processFormObjects typename="dmProfile">
		<cfif structKeyExists(stProperties, "emailAddress") AND len(stProperties.emailAddress)>
			<cfquery datasource="#application.dsn#" name="qProfileFromEmail">
			SELECT objectid,username 
			FROM dmProfile
			WHERE emailAddress = <cfqueryparam cfsqltype="cf_sql_varchar" value="#stProperties.emailAddress#">
			AND userDirectory = 'CLIENTUD'
			</cfquery>
			
			<cfif qProfileFromEmail.recordCount>
				<cfset stUser = createObject("component", application.stcoapi["farUser"].packagePath).getByUserID(userID="#application.factory.oUtils.listSlice(qProfileFromEmail.username,1,-2,"_")#") />
				
				<cftry>
					<skin:view objectid="#stUser.objectid#" typename="farUser" webskin="forgotUserIDEmail" />
					<cfset request.emailSent = true />
					<cfcatch>
						<!--- error sending email --->
						<cfset errormsg = "There was an error sending your username by email. Please contact your administrator.">
					</cfcatch>
				</cftry>
			<cfelse>
				<cfset request.notFound = true />
				<cfsavecontent variable="errormsg">
					<cfoutput><admin:resource key="coapi.farUser.forgotuserid.emailnotonrecord@text">We do not have that email address on record. Please try again or contact your administrator.</admin:resource></cfoutput>
				</cfsavecontent>
			</cfif>
		</cfif>
		<ft:break />
	</ft:processFormObjects>
</ft:processForm>


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
			
		<cfif structKeyExists(request, "emailSent")>
			<p class="alert alert-success"><admin:resource key="coapi.farUser.forgotuserid.confirmationsent@text">A confirmation email with your username has been sent to your email address and should arrive shortly.</admin:resource></p>
		<cfelse>
			<p style="padding-bottom: 0.5em;"><admin:resource key="coapi.farUser.forgotuserid.blurb@text"><strong>Forgot your Username?</strong> Please enter your email address below and your username will be sent to your email address.</admin:resource></p>

			<div class="form-inline">
				<ft:object typename="dmProfile" lfields="emailAddress" />
			</div>

			<ft:buttonPanel>
				<ft:button value="Retrieve Username" rbkey="security.button.retrieveuserid" />
			</ft:buttonPanel>

		</cfif>

		<p class="help-inline">
			<skin:buildLink href="#application.url.webtoplogin#" rbkey="coapi.farLogin.login.login">Login</skin:buildLink>
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