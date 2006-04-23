<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSecUI_GroupCreateEdit.cfm,v 1.5 2004/07/15 02:03:27 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 02:03:27 $
$Name: milestone_2-3-2 $
$Revision: 1.5 $

|| DESCRIPTION || 
Interface for creating and editing groups.

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||

|| END FUSEDOC ||
--->
<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">

<!--- Get all the current user directories --->
<cfscript>
	oAuthorisation = request.dmsec.oAuthorisation;
	oAuthentication = request.dmsec.oAuthentication;
	stUD = oAuthentication.getUserDirectory(lFilterTypes="Daemon,Custom");
	if (isDefined("form.delete"))
	{
		oAuthentication.deleteGroup(groupName=form.groupName,userDirectory=form.userDirectory);
		writeoutput("#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].groupDeleted,'#form.groupName#')#<p>");
		location(url='redirect.cfm?tag=GroupSearch&msg');
	}
	else
	{
		if (isDefined("form.submit"))
		{
			
			if (form.groupID EQ -1)
				stResult = oAuthentication.createGroup(groupname=form.groupname,groupnotes=form.groupnotes,userdirectory=form.userdirectory);
			else
				stResult = oAuthentication.updateGroup(groupid=form.groupid,groupname=form.groupname,groupnotes=form.groupnotes,userdirectory=form.userdirectory);	
			bSuccess = stResult.bSuccess;
			if (stResult.bSuccess)
			{	
				writeoutput("#application.adminBundle[session.dmProfile.locale].groupChangeOK#<p>");
				stObj = oAuthentication.getGroup(groupName='#form.GroupName#', userDirectory='#form.UserDirectory#');
			}
			else
			{
				writeoutput("<span style='color:red;'>#stResult.message#<p>");	
				stObj = form;
			}	
		}
		else if (isDefined("url.groupName"))
		{	
			stObj = oAuthentication.getGroup(groupName="#url.groupName#", userdirectory="#url.userDirectory#");
		}
		else
		{
			stObj=structNew();
			stObj.GroupId=-1;
			stObj.GroupName="";
			stObj.GroupNotes="";
			stObj.userDirectory="";
		}
	}	
			
			
</cfscript>


<cfif stObj.GroupId eq -1 >
	<cfoutput><span class="formtitle">#application.adminBundle[session.dmProfile.locale].createGroup#</span><p></cfoutput>
<cfelse>
	<cfoutput><span class="formtitle">#application.adminBundle[session.dmProfile.locale].editGroup#</span><p></cfoutput>
</cfif>

<cfoutput>
<form action="" method="POST" name="groupForm">
<table class="formtable">
<tr>
	<td rowspan="10">&nbsp;</td>
</tr>
<tr>
	<td>&nbsp;</td>
</tr>
<tr>
	<td>
	<cfif stObj.GroupId eq -1>
		<span class="formlabel">#application.adminBundle[session.dmProfile.locale].selectUserDir#</span><br>
		<select name="UserDirectory">
			<cfloop index="i" list="#structKeyList(stUd)#">
			<option value="#i#" <cfif stObj.userDirectory eq i>selected</cfif>>#i#
			</cfloop>
		</select>
	<cfelse>
		#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].userDir,"#stObj.UserDirectory#")#
		<input type="hidden" name="UserDirectory" value="#stObj.UserDirectory#"> 
	</cfif>
	</td>
</tr>
<tr>
	<td>&nbsp;</td>
</tr>
<input type="hidden" name="GroupId" value="#stObj.GroupId#"> 
<tr>
	<td>
	<!--- User Details --->
	<span class="formlabel">#application.adminBundle[session.dmProfile.locale].groupNameLabel#</span><br>
	<input type="text" size="32" maxsize="32" name="GroupName" value="#stObj.groupName#">
	</td>
</tr>
<tr>
	<td>&nbsp;</td>
</tr>
<tr>
	<td>
	<span class="formlabel">#application.adminBundle[session.dmProfile.locale].groupNotesLabel#</span><br>
	<Textarea name="groupNotes" class="formtextarea" rows="4">#stObj.groupNotes#</textarea><br>
	</td>
</tr>
<tr>
	<td>&nbsp;</td>
</tr>
<tr>
	<td>
	<cfif stObj.GroupId eq -1>
		<input type="submit" name="Submit" value="#application.adminBundle[session.dmProfile.locale].createGroup#"><br>
	<cfelse>
		<input type="submit" name="Submit" value="#application.adminBundle[session.dmProfile.locale].updateGroup#">&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="submit" name="Delete" value="#application.adminBundle[session.dmProfile.locale].deleteGroup#" onclick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmGroupDelete#');">
	</cfif>
	</td>
</tr>
<tr>
	<td>&nbsp;</td>
</tr>
</table>
<!--- form validation --->
<SCRIPT LANGUAGE="JavaScript">
<!--//
objForm = new qForm("groupForm");
objForm.GroupName.validateNotNull("#application.adminBundle[session.dmProfile.locale].enterGroupName#");
//-->
</SCRIPT>
</form>

</cfoutput>

<cfsetting enablecfoutputonly="No">
