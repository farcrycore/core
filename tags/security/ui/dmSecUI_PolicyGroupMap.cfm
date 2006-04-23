<cfsetting enablecfoutputonly="Yes">
<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSecUI_PolicyGroupMap.cfm,v 1.2 2003/04/09 08:04:59 spike Exp $
$Author: spike $
$Date: 2003/04/09 08:04:59 $
$Name: b201 $
$Revision: 1.2 $

|| DESCRIPTION || 
UI for mapping external groups to policy groups.

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||

|| HISTORY ||
$Log: dmSecUI_PolicyGroupMap.cfm,v $
Revision 1.2  2003/04/09 08:04:59  spike
Major update to remove need for multiple ColdFusion and webserver mappings.

Revision 1.1  2003/04/08 08:52:20  paul
CFC security updates

Revision 1.4  2003/01/09 02:34:30  geoff
no message

Revision 1.3  2002/10/15 08:48:14  pete
no message

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
<cfimport taglib="/farcry/farcry_core/tags/security/ui/" prefix="dmsec">
<cfscript>
	oAuthorisation = request.dmsec.oAuthorisation;
	oAuthentication = request.dmsec.oAuthentication;
	stUD = oAuthentication.getUserDirectory();
</cfscript>


<cfoutput><span class="formtitle">Map a Policy Group</span><p></p></cfoutput>

<!--- stage 1, select a user directory --->
<cfif not isDefined("url.step") OR url.step eq 1>

	<cfoutput>
	<table class="formtable">
	<tr>
		<td rowspan="10">&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>
		<span class="formlabel">Please select a userdirectory that you wish to map groups from:</span><p>
	
		<form action="?tag=#url.tag#&step=2&showerror=1" method="POST">
			<dmsec:dmSec_Select name="userDirectory" stValues="#stUd#">
			<input type="Submit" name="Next" value="Next">
		</form>
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	</table>
	
	</cfoutput>

<!--- stage 2 --->
<cfelseif url.step eq 2>

<cfscript>
	aGroups = oAuthentication.getMultipleGroups(userdirectory=form.USERDIRECTORY);
	aPolicyGroups = oAuthorisation.getAllPolicyGroups();
</cfscript>


<cfoutput>

<form action="?tag=#url.tag#&step=3" method="POST">
	<input type="hidden" name="userDirectory" value="#form.userDirectory#">
	<table class="formtable">
	<tr>
		<td rowspan="10">&nbsp;</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td>
		<!--- get all the userdirectories groups and show as a drop down --->
		<span class="formlabel">Please select a external group to map from:</span><br>
		<dmsec:dmSec_Select name="groupName" aValues="#aGroups#" ValueField="groupName" TextField="groupName"><br>
		<p></p>
		<!--- get all the policy stores groups and show as drop down --->
		<span class="formlabel">Please select a policy group to map to:</span><br>
		<dmsec:dmSec_Select name="policyGroupId" aValues="#aPolicyGroups#" ValueField="policyGroupId" TextField="policyGroupName"><br>
		<p></p>
		<input type="Submit" name="Map Group" value="Map Group">
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>
	</table>
</form>

</cfoutput>

<cfelse>
<!--- stage 3, add the mapping --->
<cfscript>
	stResult = oAuthorisation.createPolicyGroupMapping(groupname="#form.groupName#",userdirectory="#form.userdirectory#",policyGroupId="#form.policyGroupId#");
	if (stResult.bSuccess)
		msg = "<div style=""color:green;"">OK:</div> Policy group mapping added.<p></p>";
	else
		msg = "<div style=""color:red;"">Failed:</div> Policy group mapping already exists.<p>";
			
</cfscript>

<cfoutput>
#msg#

</cfoutput>
	
</cfif>

<cfsetting enablecfoutputonly="No">