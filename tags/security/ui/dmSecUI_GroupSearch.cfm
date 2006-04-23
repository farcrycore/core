<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSecUI_GroupSearch.cfm,v 1.5 2005/08/17 06:50:52 pottery Exp $
$Author: pottery $
$Date: 2005/08/17 06:50:52 $
$Name: milestone_3-0-1 $
$Revision: 1.5 $

|| DESCRIPTION || 
UI for searching for groups.

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||

|| HISTORY ||
$Log: dmSecUI_GroupSearch.cfm,v $
Revision 1.5  2005/08/17 06:50:52  pottery
FC-83
security setup pages cleaned up and layed forms out with css

Revision 1.4  2005/08/17 04:19:22  daniela
[FC-192]   Add glamour touch

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
<form action="" name="groupSearch" method="post" class="f-wrap-1 f-bg-medium wider">
	<fieldset>
		<h3>#application.adminBundle[session.dmProfile.locale].groupSearch#</h3>
		
		<label for="lUserDirectory"><b>#application.adminBundle[session.dmProfile.locale].selectSearchUserDir#</b>
			<select name="lUserDirectory" size=4 multiple="multiple">
				<cfloop index="ud" list="#structKeyList(stUd)#">
					<cfif stUd[ud].type neq "ADSI"><option value="#ud#" <cfif listContains(stobj.lUserDirectory,ud) or listlen(structKeyList(stUd)) eq 1>selected="selected"</cfif>>#ud#</cfif></option>
				</cfloop>
			</select>
			<br />
		</label>
		<label for="fragment"><b>#application.adminBundle[session.dmProfile.locale].groupNameFragment#</b>
			<!--- i18n: problematic --->
			<cfset lLocations="Starts with,Contains,Ends with">
			<select name="fragmentLocation" id="fragmentLocation">
				<option value="Starts with" <cfif stobj.fragmentLocation eq "Starts with">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].startsWith#</option>
				<option value="Contains" <cfif stobj.fragmentLocation eq "Contains">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].containsLabel#</option>
				<option value="Ends with" <cfif stobj.fragmentLocation eq "Ends with">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].endsWith#</option>
			</select>
			<br />
		</label>
		<label for="fragment"><b>&nbsp;</b>
			<input type="text" name="fragment" id="fragment" value="#stobj.fragment#">
			<br />
		</label>
		<div class="f-submit-wrap">
			<input type="Submit" name="Submit" class="f-submit" Value="#application.adminBundle[session.dmProfile.locale].search#">
		</div>
	</fieldset>
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
<hr />
<h3>#application.adminBundle[session.dmProfile.locale].groups#</h3>

<table cellspacing="0" class="table-3">
		<tr>
			<th>Group Name</th>
			<th>Group Notes</th>
		</tr>
<cfscript>
	aGroups = oAuthentication.getMultipleGroups(userdirectory=ud);
</cfscript>
<cfloop index="i" from="1" to="#ArrayLen(aGroups)#">
	<cfoutput>
	<tr#iif(i mod 2, de(" class=""alt"""), de(""))#>
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