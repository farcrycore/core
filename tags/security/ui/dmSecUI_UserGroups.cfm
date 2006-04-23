<cfsetting enablecfoutputonly="Yes">
<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSecUI_UserGroups.cfm,v 1.1 2003/04/08 08:52:20 paul Exp $
$Author: paul $
$Date: 2003/04/08 08:52:20 $
$Name: b131 $
$Revision: 1.1 $

|| DESCRIPTION || 
Manage the groups a user belongs to.

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||
-> attributes.userdirectory: the user directory the user belongs to.
-> attributes.userLogin: the login name of the user.

|| HISTORY ||
$Log: dmSecUI_UserGroups.cfm,v $
Revision 1.1  2003/04/08 08:52:20  paul
CFC security updates

Revision 1.2  2002/09/11 07:17:56  geoff
no message

Revision 1.1.1.1  2002/08/22 07:18:17  geoff
no message

Revision 1.1  2001/11/18 16:15:22  matson
moved all files to custom tags daemon_security/UI (dmSecUI)

Revision 1.2  2001/11/12 10:54:47  matson
massive update here. navajo is now base install

Revision 1.1.1.1  2001/10/29 15:04:23  matson
no message

Revision 1.1.1.1  2001/09/26 22:02:03  matson
no message


|| END FUSEDOC ||
--->

<cfparam name="url.userLogin">
<cfparam name="url.userdirectory">


<cfparam name="form.memberOf" default="">
<cfparam name="form.notMemberOf" default="">

<cfset userdirectory = url.userdirectory>
<cfset userLogin     = url.userLogin>

<cfscript>
	oAuthorisation = request.dmsec.oAuthorisation;
	oAuthentication = request.dmsec.oAuthentication;
	stUD = oAuthentication.getUserDirectory();
</cfscript>

<cfoutput><span class="formtitle">Manage User Groups (#userLogin#)</span><p></cfoutput>

<cfif isDefined("form.Submit")>
	<!--- update the groups this user is a member of --->
	<cfloop index="i" list="#form.MemberOf#">
		<cfscript>
			oAuthentication.addUserTogroup(userlogin=userlogin,userdirectory=userdirectory,groupname=i);
		</cfscript>
	</cfloop>
	
	<cfloop index="i" list="#form.NotMemberOf#">
		<cfscript>
			oAuthentication.removeUserFromGroup(userlogin=userlogin,userdirectory=userdirectory,groupname=i);
		</cfscript>
	</cfloop>
</cfif>

<cfscript>
	aUserGroups=oAuthentication.getMultipleGroups(userlogin=userlogin,userdirectory=userdirectory);
	aNotUserGroups=oAuthentication.getMultipleGroups(userlogin=userlogin,userdirectory=userdirectory,bInvert=1);
</cfscript>

<cfoutput>

<script language="JavaScript">
function AddGroup()
{
	f = document.forms.userSearch;
	a = f.MemberOf;
	r = f.NotMemberOf;
	
	for(cnt=0; cnt<r.options.length; cnt++)
	{
		if (r.options[cnt].selected)
		{
			// copy right side to left side
			a.options[a.options.length]=new Option(r.options[cnt].text,r.options[cnt].value);
			// remove from right side
			r.options[cnt]=null; cnt--;
		}
	}
}

function RemoveGroup()
{
	f = document.forms.userSearch;
	r = f.MemberOf;
	a = f.NotMemberOf;
	
	for(cnt=0; cnt<r.options.length; cnt++)
	{
		if (r.options[cnt].selected)
		{
			// copy right side to left side
			a.options[a.options.length]=new Option(r.options[cnt].text,r.options[cnt].value);
			// remove from right side
			r.options[cnt]=null; cnt--;
		}
	}
}

function SelectAllOptions()
{
f = document.forms.userSearch;
	r = f.MemberOf;
	a = f.NotMemberOf;
	
	for(cnt=0; cnt<r.options.length; cnt++)
	{
		r.options[cnt].selected=true;
	}
	
	for(cnt=0; cnt<a.options.length; cnt++)
	{
		a.options[cnt].selected=true;
	}
}
</script>

<form action="" name="userSearch" method="POST" onSubmit="SelectAllOptions();">

<table class="formtable">
<tr>
	<td rowspan="20">&nbsp;</td>
	<td colspan="3">&nbsp;</td>
	<td rowspan="20">&nbsp;</td>
</tr>

<tr>
	<td>
		<span class="formlabel">Member of:</span><br>
		<select name="MemberOf" multiple size=10 style="width:140px;">
			<cfloop index="i" from="1" to="#arrayLen(aUserGroups)#">
				<option value="#aUserGroups[i].groupName#">#aUserGroups[i].groupName#
			</cfloop>
		</select>
	</td>
	<td align="center" width="100%">
		<input type="Button" name="Add" value="&lt;&lt;-" onClick="AddGroup();"><Br>
		<br>
		<input type="Button" name="Remove" value="-&gt;&gt;" onClick="RemoveGroup();">
	</td>
	<td>
		<span class="formlabel">Not a Member of:</span><br>
		<select name="NotMemberOf" multiple size=10 style="width:140px;">
			<cfloop index="i" from="1" to="#arrayLen(aNotUserGroups)#">
				<option value="#aNotUserGroups[i].groupName#">#aNotUserGroups[i].groupName#
			</cfloop>
		</select>
	</td>
</tr>
<tr>
	<td colspan="3">&nbsp;</td>
</tr>
<tr>
	<td colspan=3 align=center><input type="Submit" name="Submit" value="Update"></td>
</tr>
<tr>
	<td colspan="3">&nbsp;</td>
</tr>
</table>

</form>
</cfoutput>

<cfsetting enablecfoutputonly="No">