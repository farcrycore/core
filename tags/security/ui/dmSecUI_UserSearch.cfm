<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSecUI_UserSearch.cfm,v 1.9 2005/08/17 06:50:52 pottery Exp $
$Author: pottery $
$Date: 2005/08/17 06:50:52 $
$Name: milestone_3-0-1 $
$Revision: 1.9 $

|| DESCRIPTION || 
UI for searching for users.

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||

|| HISTORY ||
$Log: dmSecUI_UserSearch.cfm,v $
Revision 1.9  2005/08/17 06:50:52  pottery
FC-83
security setup pages cleaned up and layed forms out with css

Revision 1.8  2005/08/17 04:47:46  daniela
[FC-192]   Add glamour touch

Revision 1.7  2005/08/16 01:28:55  daniela
[FC-192]   Add glamour touch to table displaying the users returned from the search.

Revision 1.6  2005/05/27 02:37:17  pottery
FC-83
main table removed and markd up using labels. results of search still needs formatting. making a mockup html page for skunkworks now as the editing of this cfm file requires a developer

Revision 1.5  2004/07/30 04:55:55  brendan
i18n mods

Revision 1.4  2004/07/15 02:03:27  brendan
i18n updates

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
<form name="userSearch" method="POST" class="f-wrap-1 f-bg-medium wider">
	<fieldset>
	<h3>#application.adminBundle[session.dmProfile.locale].userSearch#</h3>
		
	<label for="lUserDirectory"><b>#application.adminBundle[session.dmProfile.locale].selectSearchUserDir#</b>
	<select name="lUserDirectory" id="lUserDirectory" size="4" multiple="multiple">
	<cfloop index="ud" list="#structKeyList(stUd)#">
	<cfif stUd[ud].type neq "ADSI"><option value="#ud#" <cfif listContains(stobj.lUserDirectory,ud) or listlen(structKeyList(stUd)) eq 1>selected</cfif>>#ud#</cfif>
	</cfloop>
	</select><br />
	</label>
	
	<label for="fragmentLocation"><b>#application.adminBundle[session.dmProfile.locale].userLoginFragment#</b>
	<select name="fragmentLocation" id="fragmentLocation">
		<option value="Starts with" <cfif stobj.fragmentLocation eq "Starts with">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].startsWith#
		<option value="Contains" <cfif stobj.fragmentLocation eq "Contains">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].containsLabel#
		<option value="Ends with" <cfif stobj.fragmentLocation eq "Ends with">selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].endsWith#
	</select><br />
	</label>
	
	<label for="fragment"><b>&nbsp;</b>
	<input type="text" name="fragment" id="fragment" value="#stobj.fragment#" /><br />
	</label>
	
		<fieldset class="f-checkbox-wrap">
			<b>#application.adminBundle[session.dmProfile.locale].searchInactiveAccounts#</b>
			<fieldset>
			<label for="inactive">
			<input type="checkbox" class="f-checkbox" name="inactive" id="inactive" <cfif isdefined("form.submit") and isdefined("form.inactive")>checked="checked"</cfif> /> 
			</label>
			</fieldset>
		</fieldset> 
		
		<div class="f-submit-wrap">
		<input type="Submit" name="Submit" class="f-submit" Value="#application.adminBundle[session.dmProfile.locale].search#" />
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

<cfset lStatus="<span style='color:orange;'>#application.adminBundle[session.dmProfile.locale].blacklisted#</span>,<span style='color:red;'>#application.adminBundle[session.dmProfile.locale].disabled#</span>,<span style='color:blue;'>#application.adminBundle[session.dmProfile.locale].pendingApproval#</span>,<span style='color:green;'>#application.adminBundle[session.dmProfile.locale].Active#</span>">

<!--- assuming a search on daemon user directories here --->
<cfloop index="ud" list="#lUserDirectory#">

<cfoutput>
<hr />
<h3>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].queryResults,"#ud#")#</h3>
<table cellspacing="0" class="table-3">
		<tr>
			<th>#application.adminBundle[session.dmProfile.locale].loginName#</th>
			<th>#application.adminBundle[session.dmProfile.locale].status#</th>
		</tr>
	</thead>
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
				<tr#iif(i mod 2, de(" class=""alt"""), de(""))#>
					<td><a href="?tag=UserCreateEdit&userLogin=#aUsers[i].userLogin#&userDirectory=#ud#">#aUsers[i].userLogin#</a></td>
					<td>#ListGetAt(lStatus, aUsers[i].userstatus)#</td>
				</tr>	
				</cfoutput>
			<cfelse>
				<!--- don't show inactive users --->
				<cfif aUsers[i].userstatus neq 2>
					<cfoutput>
					<tr#iif(i mod 2, de(" class=""alt"""), de(""))#>
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
		<cfoutput>#application.adminBundle[session.dmProfile.locale].adSearchingNotSupported#</cfoutput>
	</cfcase>

	<cfdefaultcase>
		<dmsec:dmSec_throw errorCode="dmSec_UserGetUnknownUDType">
	</cfdefaultcase>
	
</cfswitch>
	
</cfloop>

</cfif>

<cfsetting enablecfoutputonly="No">