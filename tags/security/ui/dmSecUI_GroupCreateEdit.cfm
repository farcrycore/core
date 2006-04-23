<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSecUI_GroupCreateEdit.cfm,v 1.8 2005/09/07 06:05:12 daniela Exp $
$Author: daniela $
$Date: 2005/09/07 06:05:12 $
$Name: milestone_3-0-0 $
$Revision: 1.8 $

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
				writeoutput("<h3 id='fading1' class='fade'><span class='success'>Success</span>: #application.adminBundle[session.dmProfile.locale].groupChangeOK#</h3><br />");
				stObj = oAuthentication.getGroup(groupName='#form.GroupName#', userDirectory='#form.UserDirectory#');
			}
			else
			{
				writeoutput("<h3 id='fading2' class='fade'><span class='error'>Error</span>: #stResult.message#</h3><br />");	
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

<cfoutput>
<form action="" name="groupForm" method="POST" class="f-wrap-1 f-bg-medium wider">
	<fieldset>
		<div class="req"><b>*</b>Required</div>
		<cfif stObj.GroupId eq -1 >
			<h3>#application.adminBundle[session.dmProfile.locale].createGroup#</h3>
		<cfelse>
			<h3>#application.adminBundle[session.dmProfile.locale].editGroup#</h3>
		</cfif>
		<label for="UserDirectory">
			<cfif stObj.GroupId eq -1>
				<b>#application.adminBundle[session.dmProfile.locale].selectUserDir#</b>
				<select name="UserDirectory" id="UserDirectory">
					<cfloop index="i" list="#structKeyList(stUd)#">
					<option value="#i#" <cfif stObj.userDirectory eq i>selected="selected"</cfif>>#i#</option>
					</cfloop>
				</select>
			<cfelse>
				<b>#application.adminBundle[session.dmProfile.locale].userDirectoryLabel#</b>
				<span style="font-weight:bold;margin-left:8px">#stObj.UserDirectory#</span><input type="hidden" name="UserDirectory" value="#stObj.UserDirectory#" />
			</cfif>
			<br />
		</label>
		<input type="hidden" name="GroupId" value="#stObj.GroupId#" /> 
		<label for="GroupName"><b>#application.adminBundle[session.dmProfile.locale].groupNameLabel#<span class="req">*</span></b>
			<!--- User Details --->
			<input type="text" name="GroupName" id="GroupName" value="#stObj.groupName#" maxsize="32" />
			<br />
		</label>
		<label for="groupNotes"><b>#application.adminBundle[session.dmProfile.locale].groupNotesLabel#</b>
			<textarea cols="30" class="f-comments" rows="5" name="groupNotes" id="groupNotes">#stObj.groupNotes#</textarea>
			<br />
		</label>
		<div class="f-submit-wrap">
			<cfif stObj.GroupId eq -1>
				<input type="submit" name="Submit" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].createGroup#" />
			<cfelse>
				<input type="submit" name="Submit" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].updateGroup#" />
				<input type="submit" name="Delete" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].deleteGroup#" onclick="return confirm('#application.adminBundle[session.dmProfile.locale].confirmGroupDelete#');" />
			</cfif>
		</div>
	</fieldset>
	
	<!--- form validation --->
	<SCRIPT LANGUAGE="JavaScript">
		<!--//
		objForm = new qForm("groupForm");
		qFormAPI.errorColor="##cc6633";
		objForm.GroupName.validateNotNull("#application.adminBundle[session.dmProfile.locale].enterGroupName#");
		//-->
	</SCRIPT>
</form>

</cfoutput>

<cfsetting enablecfoutputonly="No">
