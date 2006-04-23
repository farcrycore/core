<html>
<head>
<title>Update user password</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<link href="<cfoutput>#application.url.farcry#</cfoutput>/css/admin.css" rel="stylesheet" type="text/css">
	
<!--// load the qForm JavaScript API //-->
<SCRIPT SRC="<cfoutput>#application.url.farcry#</cfoutput>/includes/lib/qforms.js"></SCRIPT>
<!--// you do not need the code below if you plan on just
       using the core qForm API methods. //-->
<!--// [start] initialize all default extension libraries  //-->
<SCRIPT LANGUAGE="JavaScript">
<!--//
// specify the path where the "/qforms/" subfolder is located
qFormAPI.setLibraryPath("<cfoutput>#application.url.farcry#</cfoutput>/includes/lib/");
// loads all default libraries
qFormAPI.include("*");
//-->


</SCRIPT>
<!--// [ end ] initialize all default extension libraries  //-->

</head>

<body>

<cfif isdefined("form.newPassword")>
	
	<cfinvoke 
	 component="farcry.packages.security.user"
	 method="updatePassword" returnvariable="bUpdate">
		<cfinvokeargument name="userId" value="#request.stLoggedInUser.userId#"/>
		<cfinvokeargument name="newPassword" value="#form.newPassword#"/>
		<cfinvokeargument name="newPassword2" value="#form.newPassword2#"/>
		<cfinvokeargument name="dsn" value="#application.dsn#"/>
	</cfinvoke>

	<cfif bUpdate>
		<div class="formtitle" style="margin-left:30px;margin-top:30px;">Update Successful</div>
		<p></p>
		<span class="frameMenuBullet" style="margin-left:30px;">&raquo;</span> <a href="#"  onClick="javascript:window.close();">Close window</a>
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
		<td><input type="submit" value="Change"></td>
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

</body>
</html>
