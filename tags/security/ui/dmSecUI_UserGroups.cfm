<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSecUI_UserGroups.cfm,v 1.5 2005/10/07 04:14:14 daniela Exp $
$Author: daniela $
$Date: 2005/10/07 04:14:14 $
$Name: milestone_3-0-1 $
$Revision: 1.5 $

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
Revision 1.5  2005/10/07 04:14:14  daniela
[FC-340]
Redirect - use application.url.farcry rather than /farcry (virtual directory sites)

Revision 1.4  2005/08/17 05:18:52  daniela
[FC-192]   Add glamour touch and add a cancel button

Revision 1.3  2004/07/30 02:00:28  brendan
i18n mods

Revision 1.2  2004/07/15 02:03:27  brendan
i18n updates

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
	
	<!--- return to listing page???? --->
	
	
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

<form action="" method="post" name="userSearch" id="userSearch" class="f-wrap-1 f-bg-medium" onSubmit="SelectAllOptions();">
	<fieldset> 
			<h3>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].manageUserGroups,"#userLogin#")#</h3>
		<br />
		<table border="0" cellpadding="1" cellspacing="0" class="table-1">
			<colgroup align="left">
			<colgroup align="center">
			<colgroup align="left">
			<thead valign="top">
				<tr>
					<th>#application.adminBundle[session.dmProfile.locale].memberOf#</th>
					<th>&nbsp;</th>
					<th>#application.adminBundle[session.dmProfile.locale].memberNot#</th>
				</tr>
			</thead>
			<tr>
				<td>
					<select name="MemberOf" id="MemberOf" size="10" multiple style="width:140px;">
						<cfloop index="i" from="1" to="#arrayLen(aUserGroups)#">
							<option value="#aUserGroups[i].groupName#">#aUserGroups[i].groupName#
						</cfloop>
					</select>
				</td>
				<td>
					<input type="Button" name="Add" class="f-submit" value="&lt;&lt;-" onClick="AddGroup();">
					<br />
					<input type="Button" name="Remove" class="f-submit" value="-&gt;&gt;" onClick="RemoveGroup();">
				</td>
				<td>
					<select name="NotMemberOf" id="NotMemberOf" size="10" multiple style="width:140px;">
						<cfloop index="i" from="1" to="#arrayLen(aNotUserGroups)#">
							<option value="#aNotUserGroups[i].groupName#">#aNotUserGroups[i].groupName#
						</cfloop>
					</select>
				</td>
			</tr>
		</table>
		<div class="f-submit-wrap">
			<input type="Submit" name="Submit" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].updateLC#">
			<input type="button" name="cancel" class="f-submit" value="#application.adminBundle[session.dmProfile.locale].cancel#" onclick="location.href='#application.url.farcry#/security/redirect.cfm?tag=UserCreateEdit&userDirectory=#userdirectory#&userLogin=#userlogin#'">
		</div>
	</fieldset>

</form>
</cfoutput>

<cfsetting enablecfoutputonly="No">