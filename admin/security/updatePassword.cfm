<cfprocessingDirective pageencoding="utf-8">

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
<cfoutput>

<cfif isdefined("form.newPassword")>
	
    <cfscript>
    o_user = createObject("component", "#application.packagepath#.security.user");
    bUpdate = o_user.updatePassword(userID=session.dmSec.authentication.userID, oldPassword=form.oldPassword, newPassword=form.newPassword, newPassword2=form.newPassword2, dsn=application.dsn);
    </cfscript>

	<cfif bUpdate>
		<div class="fade success" id="fader" style="margin-left:15px"><strong>#application.adminBundle[session.dmProfile.locale].updateSuccessful#</strong> | <a href="##" onClick="window.close();">#application.adminBundle[session.dmProfile.locale].closeWindow#</a></div>
	<cfelse>
		<div class="fade error" style="margin-left:15px" id="fader2"><strong>#application.adminBundle[session.dmProfile.locale].updateFailed#</strong> | <a href="updatePassword.cfm">#application.adminBundle[session.dmProfile.locale].tryAgain#</a></div>
	</cfif>
<cfelse>
	<form action="updatePassword.cfm" method="post" name="updatePassword" class="f-wrap-1 f-bg-medium" style="margin-left:8px">
	<fieldset>
	
		<h3>#application.adminBundle[session.dmProfile.locale].changePassword#</h3>
		
		<label for="oldPassword">
		<b>#application.adminBundle[session.dmProfile.locale].oldPassword#</b>
		<input type="password" name="oldPassword" id="oldPassword" size="12" /><br />
		</label>
		
		<label for="newPassword">
		<b>#application.adminBundle[session.dmProfile.locale].newPassword#</b>
		<input type="password" name="newPassword" id="newPassword" size="12" /><br />
		</label>
		
		<label for="newPassword2">
		<b>#application.adminBundle[session.dmProfile.locale].confirmNewPassword#</b>
		<input type="password" name="newPassword2" id="newPassword2" size="12" /><br />
		</label>
		
		<div class="f-submit-wrap">
		<input type="submit" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].change#" />
		</div>
		
	</fieldset>
	</form>
	<!--- form validation --->
	<SCRIPT LANGUAGE="JavaScript">
	<!--//
	objForm = new qForm("updatePassword");
	qFormAPI.errorColor="##cc6633";
	objForm.oldPassword.validateNotNull("#application.adminBundle[session.dmProfile.locale].existingPassword#");
	objForm.newPassword.validateNotNull("#application.adminBundle[session.dmProfile.locale].enterNewPassword#");
	objForm.newPassword2.validateNotNull("#application.adminBundle[session.dmProfile.locale].reenterNewPassword#");
	objForm.newPassword.validatePassword('newPassword2', '1','32',"#application.adminBundle[session.dmProfile.locale].badPasswords#");
	objForm.oldPassword.validatePassword(null, '1','32',"#application.adminBundle[session.dmProfile.locale].reenterExistingPassword#");
	//-->
	</SCRIPT>
	
</cfif>
</cfoutput>
<admin:footer>