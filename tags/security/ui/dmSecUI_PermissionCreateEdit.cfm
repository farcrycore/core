<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSecUI_PermissionCreateEdit.cfm,v 1.2 2004/07/15 02:03:27 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 02:03:27 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 
Interface for creating and editing permissions.

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||

|| HISTORY ||
$Log: dmSecUI_PermissionCreateEdit.cfm,v $
Revision 1.2  2004/07/15 02:03:27  brendan
i18n updates

Revision 1.1  2003/04/08 08:52:20  paul
CFC security updates

Revision 1.2  2002/09/12 01:15:47  geoff
no message

Revision 1.1.1.1  2002/08/22 07:18:17  geoff
no message

Revision 1.1  2001/11/18 16:15:22  matson
moved all files to custom tags daemon_security/UI (dmSecUI)

Revision 1.2  2001/11/12 10:54:47  matson
massive update here. navajo is now base install

Revision 1.1.1.1  2001/10/29 15:04:22  matson
no message

Revision 1.1.1.1  2001/09/26 22:02:02  matson
no message


|| END FUSEDOC ||
--->


<!--- Delete the permission --->
<cfscript>
	oAuthorisation = request.dmsec.oAuthorisation;
	oAuthentication = request.dmsec.oAuthentication;
	if(isDefined("form.Delete"))
	{
		oAuthorisation.deletePermission(permissionid=form.permissionid);
		writeoutput("<span style='color:green;'>OK:</span> Permission '#form.PermissionName#' has been deleted.<p></p>");
		stObj=structNew();
		stObj.PermissionId=-1;
		stObj.PermissionName="";
		stObj.PermissionNotes="";
		stObj.PermissionType="";
	}	
	else
	{
		if (isDefined("form.submit"))
		{
			if (form.permissionId eq -1)
				stResult=oAuthorisation.createPermission(permissionname=form.permissionname,permissiontype=form.permissiontype,permissionnotes=form.permissionnotes);
			else
				stresult=oAuthorisation.updatePermission(permissionid=form.permissionID,permissionname=form.permissionname,permissiontype=form.permissiontype,permissionnotes=form.permissionnotes);
			if (stResult.bSuccess)
			{	
				writeoutput("<span style='color:green;'>OK:</span> Permission Update/Create success<p></p>");
				stObj = oAuthorisation.getPermission(permissionName="#form.PermissionName#",permissionType="#form.PermissionType#");
			}
			else
				stObj=form;
		}
		else if (isDefined("url.PermissionName"))
			stObj = oAuthorisation.getPermission(permissionName="#url.PermissionName#");
		else if (isDefined("url.PermissionId"))
			stObj = oAuthorisation.getPermission(permissionID=url.permissionid);
		else
		{
			stObj=structNew();
			stObj.PermissionId=-1;
			stObj.PermissionName="";
			stObj.PermissionNotes="";
			stObj.PermissionType="";	
		}	
	}
	
		
</cfscript>

<cfif stObj.PermissionId eq -1 >
	<cfoutput><span class="formtitle">#application.adminBundle[session.dmProfile.locale].createPermission#</span><p></p></cfoutput>
<cfelse>
	<cfoutput><span class="formtitle">#application.adminBundle[session.dmProfile.locale].editPermission#</span><p></p></cfoutput>
</cfif>

<cfoutput>
<form action="" method="POST">
	<input type="hidden" name="PermissionId" value="#stObj.PermissionId#"> 
	
	<table class="formtable">
	<tr>
		<td rowspan="10">&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td><span class="formlabel">#application.adminBundle[session.dmProfile.locale].permissionNameLabel#</span><br>
		<input type="text" size="32" maxsize="32" name="PermissionName" value="#stObj.PermissionName#"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td><span class="formlabel">#application.adminBundle[session.dmProfile.locale].permissionNotesLabel#</span><br>
		<Textarea name="PermissionNotes" cols="40" rows="4">#stObj.PermissionNotes#</textarea></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td><span class="formlabel">#application.adminBundle[session.dmProfile.locale].permissionTypeLabel#</span><br>
		<input type="text" size="32" maxsize="32" name="PermissionType" value="#stObj.PermissionType#"></td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>
		<cfif stObj.PermissionId eq -1>
			<input type="submit" name="Submit" value="#application.adminBundle[session.dmProfile.locale].createPermission#"><br>
		<cfelse>
			<input type="submit" name="Submit" value="#application.adminBundle[session.dmProfile.locale].updatePermission#">&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="submit" name="Delete" value="#application.adminBundle[session.dmProfile.locale].deletePermission#" onclick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmDeletePermission#');">
		</cfif>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	</table>
	
</form>

</cfoutput>

<cfsetting enablecfoutputonly="No">
