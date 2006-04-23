<cfsetting enablecfoutputonly="Yes">
<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSecUI_GroupCreateEdit.cfm,v 1.4 2003/12/08 00:25:13 brendan Exp $
$Author: brendan $
$Date: 2003/12/08 00:25:13 $
$Name: milestone_2-2-1 $
$Revision: 1.4 $

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
		writeoutput("<span style='color:green;'>OK:</span> Group '#form.groupName#' has been deleted.<p>");
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
				writeoutput("<span style='color:green;'>OK:</span> Group Update/Create success<p>");
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
	<cfoutput><span class="formtitle">Create Group</span><p></cfoutput>
<cfelse>
	<cfoutput><span class="formtitle">Edit Group</span><p></cfoutput>
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
		<span class="formlabel">Select a user directory to create the group in.</span><br>
		<select name="UserDirectory">
			<cfloop index="i" list="#structKeyList(stUd)#">
			<option value="#i#" <cfif stObj.userDirectory eq i>selected</cfif>>#i#
			</cfloop>
		</select>
	<cfelse>
		<span class="formlabel">UserDirectory:</span> #stObj.UserDirectory#
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
	<span class="formlabel">Group Name:</span><br>
	<input type="text" size="32" maxsize="32" name="GroupName" value="#stObj.groupName#">
	</td>
</tr>
<tr>
	<td>&nbsp;</td>
</tr>
<tr>
	<td>
	<span class="formlabel">Group Notes:</span><br>
	<Textarea name="groupNotes" class="formtextarea" rows="4">#stObj.groupNotes#</textarea><br>
	</td>
</tr>
<tr>
	<td>&nbsp;</td>
</tr>
<tr>
	<td>
	<cfif stObj.GroupId eq -1>
		<input type="submit" name="Submit" value="Create Group"><br>
	<cfelse>
		<input type="submit" name="Submit" value="Update Group">&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="submit" name="Delete" value="Delete Group" onclick="return confirm('Are you sure you want to delete this group?');">
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
objForm.GroupName.validateNotNull("Please enter a group name");
//-->
</SCRIPT>
</form>

</cfoutput>



<cfsetting enablecfoutputonly="No">
