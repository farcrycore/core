<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSecUI_PolicyGroupSearch.cfm,v 1.2 2004/07/15 02:03:27 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 02:03:27 $
$Name: milestone_2-3-2 $
$Revision: 1.2 $

|| DESCRIPTION || 
UI for searching for policy groups.

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||

|| HISTORY ||
$Log: dmSecUI_PolicyGroupSearch.cfm,v $
Revision 1.2  2004/07/15 02:03:27  brendan
i18n updates

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

<cfoutput><span class="formtitle">#application.adminBundle[session.dmProfile.locale].policyGroups#</span><p></p></cfoutput>

<cfoutput>
<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;">
	<tr class="dataheader">
		<td>#application.adminBundle[session.dmProfile.locale].name#</td>
		<td>#application.adminBundle[session.dmProfile.locale].description#</td>
</tr>
</cfoutput>

<cfscript>
	oAuthorisation = request.dmsec.oAuthorisation;
	aPolicyGroup = oAuthorisation.getAllPolicyGroups();
</cfscript>



<cfloop index="i" from="1" to="#ArrayLen(aPolicyGroup)#">
	<cfoutput>
	<tr class="#IIF(i MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
		<td><a href="?tag=PolicyGroupCreateEdit&PolicyGroupId=#aPolicyGroup[i].PolicygroupId#">#aPolicyGroup[i].PolicygroupName#</a></td>
		<td>#aPolicyGroup[i].PolicygroupNotes#</td>
	</tr>
	</cfoutput>
</cfloop>
	
<cfoutput>
</table>
</cfoutput>

<cfoutput>
<p></p>
<span class="frameMenuBullet" style="margin-left:30px;">&raquo;</span> <a href="?tag=PolicyGroupExport">#application.adminBundle[session.dmProfile.locale].exportPolicyGroups#</a>&nbsp;&nbsp;&nbsp;
<span class="frameMenuBullet">&raquo;</span> <a href="?tag=PolicyGroupImport">#application.adminBundle[session.dmProfile.locale].importPolicyGroups#</a>
<p>

</cfoutput>

<cfsetting enablecfoutputonly="No">