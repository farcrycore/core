<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">
<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSecUI_PolicyGroupMappingSearch.cfm,v 1.2 2004/07/15 02:03:27 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 02:03:27 $
$Name: milestone_2-3-2 $
$Revision: 1.2 $

|| DESCRIPTION || 
Shows all policy group mappings.

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||

|| HISTORY ||
$Log: dmSecUI_PolicyGroupMappingSearch.cfm,v $
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

Revision 1.4  2001/11/12 10:54:47  matson
massive update here. navajo is now base install

Revision 1.1.1.1  2001/10/29 15:04:22  matson
no message

Revision 1.3  2001/10/08 12:38:49  matson
no message

Revision 1.2  2001/10/08 11:55:51  matson
no message

Revision 1.1.1.1  2001/09/26 22:02:02  matson
no message


|| END FUSEDOC ||
--->

<cfscript>
	oAuthorisation = request.dmsec.oAuthorisation;
</cfscript>



<cfif isDefined("form.submit")>
	<cfloop index="fieldName" list="#form.fieldNames#">
		<cfif Find("|",fieldName) neq 0>
			<cfscript>
				oAuthorisation.deletePolicyGroupMapping(policyGroupId="#ListGetAt(fieldName,1,'|')#", userdirectory="#ListGetAt(fieldName,2,'|')#", groupName="#ListGetAt(fieldName,3,'|')#");
			</cfscript>
		</cfif>
	</cfloop>
</cfif>

<cfscript>
	aGroups = oAuthorisation.getMultiplePolicyGroupMappings();
</cfscript>


<cfoutput>
<span class="formtitle">#application.adminBundle[session.dmProfile.locale].showPolicyGroupMappings#</span><p></p>

<form action="" method="POST" onSubmit="return confirm('#application.adminBundle[session.dmProfile.locale].confirmDeleteMappings#');">
<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;">
	<tr class="dataheader">
		<td>&nbsp;</td>
		<td>#application.adminBundle[session.dmProfile.locale].policyGroupName#</td>
		<td>#application.adminBundle[session.dmProfile.locale].userDirectory#</td>
		<td>#application.adminBundle[session.dmProfile.locale].externalGroupName#</td>
</tr>

<cfloop index="i" from="1" to="#ArrayLen(aGroups)#">
	<tr class="#IIF(i MOD 2, de("dataOddRow"), de("dataEvenRow"))#">
		<td><input type="checkbox" name="#aGroups[i].policyGroupId#|#aGroups[i].externalgroupuserdirectory#|#aGroups[i].externalGroupName#"></td>
		<td>#aGroups[i].policyGroupName#</td>
		<td>#aGroups[i].externalgroupuserdirectory#</td>
		<td>#aGroups[i].externalGroupName#</td>
	</tr>
</cfloop>

<tr>
	<td colspan=4 align=right><input name="submit" type="submit" value="#application.adminBundle[session.dmProfile.locale].deleteMappings#"></td>
</tr>
</table>
</form>

</cfoutput>

<cfsetting enablecfoutputonly="No">