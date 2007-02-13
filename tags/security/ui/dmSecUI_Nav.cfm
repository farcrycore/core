<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/security/ui/dmSecUI_Nav.cfm,v 1.2 2004/07/15 02:03:27 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 02:03:27 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||
-> [um]: inbound var or attribute 
<- [er]: outbound var or caller var

|| HISTORY ||
$Log: dmSecUI_Nav.cfm,v $
Revision 1.2  2004/07/15 02:03:27  brendan
i18n updates

Revision 1.1  2003/04/08 08:52:20  paul
CFC security updates

Revision 1.1.1.1  2002/08/22 07:18:17  geoff
no message

Revision 1.1  2001/11/18 16:15:22  matson
moved all files to custom tags daemon_security/UI (dmSecUI)

Revision 1.3  2001/11/12 10:54:47  matson
massive update here. navajo is now base install

Revision 1.1.1.1  2001/10/29 15:04:22  matson
no message

Revision 1.2  2001/10/05 17:21:27  matson
no message

Revision 1.1.1.1  2001/09/26 22:02:02  matson
no message


|| END FUSEDOC ||
--->

<cfoutput>
<nobr>
<br>
<b>#application.adminBundle[session.dmProfile.locale].securityManagement#</b><br>
<i>#application.adminBundle[session.dmProfile.locale].setup#</i><br>
<br>
<!--- Test the setup --->
<a href="?tag=TestSecuritySetup">#application.adminBundle[session.dmProfile.locale].testSecuritySetup#</a><br>
<br>
<i>#application.adminBundle[session.dmProfile.locale].users#</i><br>
<!--- find a user --->
<a href="?tag=UserSearch"><br>#application.adminBundle[session.dmProfile.locale].searchForUser#</a><br>
<!--- Create a user --->
<a href="?tag=UserCreateEdit">#application.adminBundle[session.dmProfile.locale].createUser#</a><br>
<br>
<i>#application.adminBundle[session.dmProfile.locale].groups#</i><br>
<a href="?tag=GroupSearch">#application.adminBundle[session.dmProfile.locale].searchForGroup#</a><br>
<!--- Modify groups --->
<a href="?tag=GroupCreateEdit">#application.adminBundle[session.dmProfile.locale].createAGroup#</a><br>
<br>
<b>#application.adminBundle[session.dmProfile.locale].policyManagement#</b><br>
<i>#application.adminBundle[session.dmProfile.locale].Setup#</i><br>
<!--- Test the setup --->
<a href="?tag=TestPolicySetup">#application.adminBundle[session.dmProfile.locale].testPolicySetup#</a><br>
<br>
<i>#application.adminBundle[session.dmProfile.locale].permissionGroups#</i><br>
<!--- Modify groups --->
<a href="?tag=PolicyGroupSearch">#application.adminBundle[session.dmProfile.locale].policyGroups#</a><br>
<a href="?tag=PolicyGroupCreateEdit">#application.adminBundle[session.dmProfile.locale].createPolicyGroup#</a><br>
<a href="?tag=PolicyGroupMappingSearch">#application.adminBundle[session.dmProfile.locale].showPolicyGroupMappings#</a><br>
<a href="?tag=PolicyGroupMap">#application.adminBundle[session.dmProfile.locale].mapPolicyGroup#</a><br>
<br>
<i>#application.adminBundle[session.dmProfile.locale].permissions#</i><br>
<a href="?tag=PermissionSearch">#application.adminBundle[session.dmProfile.locale].permissions#</a><br>
<a href="?tag=PermissionCreateEdit">#application.adminBundle[session.dmProfile.locale].createPermission#</a><br>
<br>
</nobr>
</cfoutput>

<cfsetting enablecfoutputonly="No">
