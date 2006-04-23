<cfprocessingDirective pageencoding="utf-8">

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
<cfoutput>
<cfif isdefined("form.newPassword")>
	
    <cfscript>
    o_user = createObject("component", "#application.packagepath#.security.user");
    bUpdate = o_user.updatePassword(userID=session.dmSec.authentication.userID, oldPassword=form.oldPassword, newPassword=form.newPassword, newPassword2=form.newPassword2, dsn=application.dsn);
    </cfscript>

	<cfif bUpdate>
		<div class="formtitle" style="margin-left:30px;margin-top:30px;">#application.adminBundle[session.dmProfile.locale].updateSuccessful#</div>
		<p></p>
		<span class="frameMenuBullet" style="margin-left:30px;">&raquo;</span> <a href="##" onClick="window.close();">#application.adminBundle[session.dmProfile.locale].closeWindow#</a>
	<cfelse>
		<div class="formtitle" style="margin-left:30px;margin-top:30px;">#application.adminBundle[session.dmProfile.locale].updateFailed#</div>
		<p></p>
		<span class="frameMenuBullet" style="margin-left:30px;">&raquo;</span> <a href="updatePassword.cfm">#application.adminBundle[session.dmProfile.locale].tryAgain#</a>
	</cfif>
<cfelse>

	<form action="updatePassword.cfm" method="post" name="updatePassword">

	<div class="formtitle" style="margin-left:30px;margin-top:30px;">#application.adminBundle[session.dmProfile.locale].changePassword#</div><br>
	
	<table class="formtable" style="width:300px">
	<tr>
		<td rowspan="10">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr>
		<td><span class="formlabel">#application.adminBundle[session.dmProfile.locale].oldPassword#</span></td>
		<td><input type="password" name="oldPassword" size="12"></td>
	</tr>
	<tr>
		<td><span class="formlabel">#application.adminBundle[session.dmProfile.locale].newPassword#</span></td>
		<td><input type="password" name="newPassword" size="12"></td>
	</tr>
	<tr>
		<td><span class="formlabel">#application.adminBundle[session.dmProfile.locale].confirmNewPassword#</span></td>
		<td><input type="password" name="newPassword2" size="12"></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td><input type="submit" value="#application.adminBundle[session.dmProfile.locale].change#" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';"></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	</table>
	</form>
	<!--- form validation --->
	<SCRIPT LANGUAGE="JavaScript">
	<!--//
	objForm = new qForm("updatePassword");
	objForm.oldPassword.validateNotNull("#application.adminBundle[session.dmProfile.locale].existingPassword#");
	objForm.newPassword.validateNotNull("#application.adminBundle[session.dmProfile.locale].enterNewPassword#");
	objForm.newPassword2.validateNotNull("#application.adminBundle[session.dmProfile.locale].reenterPassword#");
	objForm.newPassword.validatePassword('newPassword2', '1','32',"#application.adminBundle[session.dmProfile.locale].badPasswords#");
	objForm.oldPassword.validatePassword(null, '1','32',"#application.adminBundle[session.dmProfile.locale].reenterExistingPassword#");
	//-->
	</SCRIPT>
	
</cfif>
</cfoutput>
<admin:footer>