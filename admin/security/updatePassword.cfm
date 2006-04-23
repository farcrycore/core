<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif isdefined("form.newPassword")>
	
    <cfscript>
    o_user = createObject("component", "#application.packagepath#.security.user");
    bUpdate = o_user.updatePassword(userID=session.dmSec.authentication.userID, newPassword=form.newPassword, newPassword2=form.newPassword2, dsn=application.dsn);
    </cfscript>

	<cfif bUpdate>
		<div class="formtitle" style="margin-left:30px;margin-top:30px;">Update Successful</div>
		<p></p>
		<span class="frameMenuBullet" style="margin-left:30px;">&raquo;</span> <a href="#" onClick="window.close();">Close window</a>
	<cfelse>
		<div class="formtitle" style="margin-left:30px;margin-top:30px;">Update Failed</div>
		<p></p>
		<span class="frameMenuBullet" style="margin-left:30px;">&raquo;</span> <a href="updatePassword.cfm">Try again</a>
	</cfif>
<cfelse>

	<form action="updatePassword.cfm" method="post" name="updatePassword">

	<div class="formtitle" style="margin-left:30px;margin-top:30px;">Change Password</div><br>
	
	<table class="formtable" style="width:300px">
	<tr>
		<td rowspan="10">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr>
		<td><span class="formlabel">Old password</span></td>
		<td><input type="password" name="oldPassword" size="12"></td>
	</tr>
	<tr>
		<td><span class="formlabel">New Password</span></td>
		<td><input type="password" name="newPassword" size="12"></td>
	</tr>
	<tr>
		<td><span class="formlabel">Confirm New Password</span></td>
		<td><input type="password" name="newPassword2" size="12"></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td><input type="submit" value="Change" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';"></td>
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
	objForm.oldPassword.validateNotNull("Please enter your existing password");
	objForm.newPassword.validateNotNull("Please enter a new password");
	objForm.newPassword2.validateNotNull("Please re-enter your new password");
	objForm.newPassword.validatePassword('newPassword2', '1','32',"Your new passwords did not match or are not valid");
	objForm.oldPassword.validatePassword(null, '1','32',"Your re-enter your existing password");
	//-->
	</SCRIPT>
	
</cfif>

<admin:footer>