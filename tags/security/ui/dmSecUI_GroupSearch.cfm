<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSecUI_GroupSearch.cfm,v 1.3 2004/07/30 04:55:55 brendan Exp $
$Author: brendan $
$Date: 2004/07/30 04:55:55 $
$Name: milestone_2-3-2 $
$Revision: 1.3 $

|| DESCRIPTION || 
UI for searching for groups.

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||

|| HISTORY ||
$Log: dmSecUI_GroupSearch.cfm,v $
Revision 1.3  2004/07/30 04:55:55  brendan
i18n mods

Revision 1.2  2004/07/15 02:03:27  brendan
i18n updates

Revision 1.1  2003/04/08 08:52:20  paul
CFC security updates

Revision 1.3  2002/10/15 05:45:46  pete
removed ability to search on ADSI/ActiveDirectory userdirectories in UI

Revision 1.2  2002/09/11 07:27:22  geoff
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

<cfparam name="form.lUserDirectory" default="">

<cfoutput><span class="formtitle">#application.adminBundle[session.dmProfile.locale].groupSearch#</span><p></cfoutput>

<!--- User directory selection --->
<cfscript>
	oAuthorisation = request.dmsec.oAuthorisation;
	oAuthentication = request.dmsec.oAuthentication;
	stUD = oAuthentication.getUserDirectory();
</cfscript>


<cfscript>
if( isDefined("form.submit"))
{
	stobj=form;
}
else
{
	stobj = StructNew();
	stobj.lUserDirectory="";
	stobj.fragmentLocation="";
	stobj.fragment="";
}
</cfscript>

<cfoutput>
<form name="groupSearch" action="" method="POST">
<table class="formtable">
<tr>
	<td rowspan="10">&nbsp;</td>
</tr>
<tr>
	<td>&nbsp;</td>
</tr>
<tr>
	<td><span class="formlabel">#application.adminBundle[session.dmProfile.locale].selectSearchUserDir#</span></td>
</tr>
<tr>
	<td>
	<select name="lUserDirectory" size=4 multiple>
		<cfloop index="ud" list="#structKeyList(stUd)#">
		<cfif stUd[ud].type neq "ADSI"><option value="#ud#" <cfif listContains(stobj.lUserDirectory,ud) or listlen(structKeyList(stUd)) eq 1>selected</cfif>>#ud#</cfif>
		</cfloop>
	</select>
	</td>
</tr>
<tr>
	<td>&nbsp;</td>
</tr>
<tr>
	<td><span class="formlabel">#application.adminBundle[session.dmProfile.locale].groupNameFragment#</span></td>
</tr>
<tr>
	<td>
	<input type="text" name="fragment" value="#stobj.fragment#">
	<!--- i18n: problematic --->
	<cfset lLocations="Starts with,Contains,Ends with">
	<select name="fragmentLocation">
		<option value="Starts with" <cfif stobj.fragmentLocation eq "Starts with">selected</cfif>>#application.adminBundle[session.dmProfile.locale].startsWith#
		<option value="Contains" <cfif stobj.fragmentLocation eq "Contains">selected</cfif>>#application.adminBundle[session.dmProfile.locale].containsLabel#
		<option value="Ends with" <cfif stobj.fragmentLocation eq "Ends with">selected</cfif>>#application.adminBundle[session.dmProfile.locale].endsWith#
	</select>
	</td>
</tr>
<tr>
	<td>&nbsp;</td>
</tr>
<tr>
	<td><input type="Submit" name="Submit" Value="#application.adminBundle[session.dmProfile.locale].search#"></td>
</tr>
<tr>
	<td>&nbsp;</td>
</tr>
</table>

</form>
</cfoutput>

<!---- DO THE SEARCH ---->
<cfif isDefined("form.submit")>

<cfif form.fragmentlocation eq "Ends with" OR form.fragmentlocation eq "Contains">
	<cfset form.fragment="%"&form.fragment>
</cfif>

<cfif form.fragmentlocation eq "Starts with" OR form.fragmentlocation eq "Contains">
	<cfset form.fragment=form.fragment&"%">
</cfif>

<cfset lStatus="<span style='color:orange;'>Blacklisted</span>,<span style='color:red;'>Disabled</span>,<span style='color:blue;'>Pending Approval</span>,<span style='color:green;'>Active</span>">

<!--- assuming a search on daemon user directories here --->
<cfloop index="ud" list="#stObj.lUserDirectory#">

<cfoutput>
<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;">
<tr class="dataheader">
	<td>Group Name</td>
	<td>Group Notes</td>
</tr>

<cfscript>
	aGroups = oAuthentication.getMultipleGroups(userdirectory=ud);
</cfscript>
<cfloop index="i" from="1" to="#ArrayLen(aGroups)#">
	<cfoutput>
	<tr  class="#IIF(i MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
		<cfif stUd[ud].type eq "Daemon">
			<td><a href="?tag=GroupCreateEdit&groupName=#aGroups[i].groupName#&userDirectory=#ud#">#aGroups[i].groupName#</a></td>
		<cfelse>
			<td>#aGroups[i].groupName#</td>
		</cfif>
		<td>#aGroups[i].groupNotes#&nbsp;</td>
	</tr>
	</cfoutput>
</cfloop>
	
</tr>
</table>

</cfoutput>


</cfloop>

</cfif>

<cfsetting enablecfoutputonly="No">