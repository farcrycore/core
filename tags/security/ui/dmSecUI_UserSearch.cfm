<cfsetting enablecfoutputonly="Yes">
<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSecUI_UserSearch.cfm,v 1.3 2003/07/10 02:35:15 brendan Exp $
$Author: brendan $
$Date: 2003/07/10 02:35:15 $
$Name: b201 $
$Revision: 1.3 $

|| DESCRIPTION || 
UI for searching for users.

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||

|| HISTORY ||
$Log: dmSecUI_UserSearch.cfm,v $
Revision 1.3  2003/07/10 02:35:15  brendan
linux mods

Revision 1.2  2003/04/09 08:04:59  spike
Major update to remove need for multiple ColdFusion and webserver mappings.

Revision 1.1  2003/04/08 08:52:20  paul
CFC security updates

Revision 1.9  2003/01/29 23:41:12  geoff
Oracle Updates

Revision 1.8  2002/10/15 04:19:04  pete
removed ability to search on ADSI/ActiveDirectory userdirectories in UI

Revision 1.7  2002/10/15 04:17:13  pete
no message

Revision 1.6  2002/10/09 05:33:52  pete
no message

Revision 1.5  2002/10/09 05:20:53  pete
no message

Revision 1.4  2002/10/09 02:26:22  brendan
search option for inactive, defaults to only active

Revision 1.3  2002/10/09 00:31:12  brendan
added option for active only user search

Revision 1.2  2002/09/11 07:17:56  geoff
no message

Revision 1.1.1.1  2002/08/22 07:18:17  geoff
no message

Revision 1.3  2001/11/28 10:21:21  matson
remove emailaddress and userdefined from user

Revision 1.2  2001/11/25 23:36:13  matson
no message

Revision 1.1  2001/11/18 16:15:22  matson
moved all files to custom tags daemon_security/UI (dmSecUI)

Revision 1.3  2001/11/16 11:46:54  matson
added custom search

Revision 1.2  2001/11/12 10:54:47  matson
massive update here. navajo is now base install

Revision 1.1.1.1  2001/10/29 15:04:23  matson
no message

Revision 1.1.1.1  2001/09/26 22:02:03  matson
no message


|| END FUSEDOC ||
--->

<cfimport taglib="/farcry/farcry_core/tags/security/ui" prefix="dmsec">
<cfparam name="form.lUserDirectory" default="">

<cfoutput><span class="formtitle">User Search</span><p></cfoutput>

<cfif isDefined("URL.msg")>
	<cfoutput>#URL.msg#</cfoutput>
</cfif>

<!--- User directory selection --->
<cfscript>
	oAuthorisation = request.dmsec.oAuthorisation;
	oAuthentication = request.dmsec.oAuthentication;
	stUD = oAuthentication.getUserDirectory();
</cfscript>


<cfset maxResults = 100>

<cfscript>
// maximum users we want to find
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
<form name="userSearch" method="POST">
<table class="formtable">
<tr>
	<td rowspan="15">&nbsp;</td>
</tr>
<tr>
	<td>&nbsp;</td>
</tr>
<tr>
	<td><span class="formlabel">Select a user directory to search in.</span></td>
</tr>
<tr>
	<td>
	<select name="lUserDirectory" size=4 multiple class="formselectlist">
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
	<td><span class="formlabel">Enter a fragment of the userLogin:</span></td>
</tr>
<tr>
	<td>
	<input type="text" name="fragment" value="#stobj.fragment#" size="30">
	<cfset lLocations="Starts with,Contains,Ends with">
	<select name="fragmentLocation">
		<cfloop index="location" list="#lLocations#">
			<option value="#location#" <cfif location eq stobj.fragmentLocation>selected</cfif>>#location#
		</cfloop>
	</select>
	</td>
</tr>
<tr>
	<td>&nbsp;</td>
</tr>
<tr>
	<td><input type="checkbox" name="inactive" <cfif isdefined("form.submit") and isdefined("form.inactive")>checked</cfif>> Search inactive accounts</td>
</tr>
<tr>
	<td>&nbsp;</td>
</tr>
<tr>
	<td><input type="Submit" name="Submit" Value="Search"></td>
</tr>
<tr>
	<td>&nbsp;</td>
</tr>
</table>

</form><br>
<br>
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
<cfloop index="ud" list="#lUserDirectory#">

<cfoutput>
<span class="formtitle">Query Results: #ud#</span><p>
<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;">
<tr class="dataheader">
	<td>Login name</td>
	<td>Status</td>
</tr>

</cfoutput>	

<cfswitch expression="#stUd[ud].type#">
	
	<cfcase value="Daemon,Custom,Daemon_GroupsByTest,Spectra">
		
		<cfscript>
			aUsers = oAuthentication.getMultipleUsers(lUserdirectories="#ud#",fragment="#form.fragment#",maxResults="#maxResults#");
		</cfscript>	
	
		
		<cfloop index="i" from="1" to="#arrayLen(aUsers)#">
			<cfif isdefined("form.inactive")>
				<!--- show all users --->
				<cfoutput>
				<tr class="#IIF(i MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
					<td><a href="?tag=UserCreateEdit&userLogin=#aUsers[i].userLogin#&userDirectory=#ud#">#aUsers[i].userLogin#</a></td>
					<td>#ListGetAt(lStatus, aUsers[i].userstatus)#</td>
				</tr>	
				</cfoutput>
			<cfelse>
				<!--- don't show inactive users --->
				<cfif aUsers[i].userstatus neq 2>
					<cfoutput>
					<tr class="#IIF(i MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
						<td><a href="?tag=UserCreateEdit&userLogin=#aUsers[i].userLogin#&userDirectory=#ud#">#aUsers[i].userLogin#</a></td>
						<td>#ListGetAt(lStatus, aUsers[i].userstatus)#</td>
					</tr>	
					</cfoutput>
				</cfif> 
			</cfif>
		</cfloop>
		
		<cfoutput></tr>
		</table></cfoutput>
		
		
	</cfcase>
	
	<cfcase value="ADSI">
		<cfoutput>Active Directory searching not supported</cfoutput>
	</cfcase>

	<cfdefaultcase>
		<dmsec:dmSec_throw errorCode="dmSec_UserGetUnknownUDType">
	</cfdefaultcase>
	
</cfswitch>
	
</cfloop>

</cfif>

<cfsetting enablecfoutputonly="No">