<cfsetting enablecfoutputonly="Yes">
<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSecUI_PolicyGroupCreateEdit.cfm,v 1.1 2003/04/08 08:52:20 paul Exp $
$Author: paul $
$Date: 2003/04/08 08:52:20 $
$Name: b131 $
$Revision: 1.1 $

|| DESCRIPTION || 
Interface for creating and editing policy groups.

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||

|| HISTORY ||
$Log: dmSecUI_PolicyGroupCreateEdit.cfm,v $
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

<!--- Delete the policy group--->
<cfscript>
	oAuthorisation = request.dmsec.oAuthorisation;
	oAuthentication = request.dmsec.oAuthentication;
	if(isDefined("form.Delete"))
	{
		oAuthorisation.deletePolicyGroup(policygroupid=form.policygroupid);
		writeoutput("<span style='color:green;'>OK:</span>Policy group '#form.policyGroupName#' has been deleted.<p></p>");
		stObj=structNew();
		stObj.PolicyGroupId=-1;
		stObj.PolicyGroupName="";
		stObj.PolicyGroupNotes="";
	}	
	else
	{
		if (isDefined("form.submit"))
		{
			if (form.PolicyGroupId eq -1)
				stResult=oAuthorisation.createPolicyGroup(policyGroupName=form.policyGroupName,policyGroupNotes=form.policyGroupNotes);
			else
				stresult=oAuthorisation.updatePolicyGroup(policyGroupID=form.policyGroupID,policyGroupName=form.policyGroupName,policyGroupNotes=form.policyGroupNotes);
			if (stResult.bSuccess)
			{	
				writeoutput("<span style='color:green;'>OK:</span> Policy Group Update/Create success<p></p>");
				stObj = oAuthorisation.getPolicyGroup(policyGroupName=form.PolicyGroupName);
			}
			else
				stObj=form;
		}
		else if (isDefined("url.policyGroupName"))
			stObj = oAuthorisation.getPolicyGroup(policyGroupName="#url.policyGroupName#");
		else if (isDefined("url.policyGroupID"))
			stObj = oAuthorisation.getPolicyGroup(policyGroupID=url.policyGroupID);
		else
		{
			stObj=structNew();
			stObj.PolicyGroupId=-1;
			stObj.PolicyGroupName="";
			stObj.PolicyGroupNotes="";	
		}	
	}
	
		
</cfscript>


<cfif stObj.PolicyGroupId eq -1 >
	<cfoutput><span class="formtitle">Create Policy Group</span><p></p></cfoutput>
<cfelse>
	<cfoutput><span class="formtitle">Edit Policy Group</span><p></p></cfoutput>
</cfif>

<cfoutput>
<form action="" method="POST">
	
	<input type="hidden" name="PolicyGroupId" value="#stObj.PolicyGroupId#"> 
	<table class="formtable">
	<tr>
		<td rowspan="10">&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>
			<span class="formlabel">Policy Group Name:</span><br>
			<input type="text" size="32" maxsize="32" name="PolicyGroupName" value="#stObj.PolicyGroupName#">	
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>
			<span class="formlabel">Policy Group Notes:</span><br>
			<Textarea name="PolicyGroupNotes" cols="40" rows="4">#stObj.PolicyGroupNotes#</textarea>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>
			<cfif stObj.PolicyGroupId eq -1>
				<input type="submit" name="Submit" value="Create Policy Group"><br>
			<cfelse>
				<input type="submit" name="Submit" value="Update Policy Group">&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="submit" name="Delete" value="Delete Policy Group" onclick="return confirm('Are you sure you want to delete this policy group?');">
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
