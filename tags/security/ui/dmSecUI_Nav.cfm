<cfsetting enablecfoutputonly="Yes">
<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSecUI_Nav.cfm,v 1.1 2003/04/08 08:52:20 paul Exp $
$Author: paul $
$Date: 2003/04/08 08:52:20 $
$Name: b201 $
$Revision: 1.1 $

|| DESCRIPTION || 

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||
-> [um]: inbound var or attribute 
<- [er]: outbound var or caller var

|| HISTORY ||
$Log: dmSecUI_Nav.cfm,v $
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
<b>Security Management</b><br>
<i>Setup</i><br>
<!--- Test the setup --->
<a href="?tag=TestSecuritySetup">Test Security Setup</a><br>
<br>
<i>Users</i><br>
<!--- find a user --->
<a href="?tag=UserSearch">Search for User</a><br>
<!--- Create a user --->
<a href="?tag=UserCreateEdit">Create a User</a><br>
<br>
<i>Groups</i><br>
<a href="?tag=GroupSearch">Search for Group</a><br>
<!--- Modify groups --->
<a href="?tag=GroupCreateEdit">Create a Group</a><br>
<br>
<b>Policy Management</b><br>
<i>Setup</i><br>
<!--- Test the setup --->
<a href="?tag=TestPolicySetup">Test Policy Setup</a><br>
<br>
<i>Permission Groups</i><br>
<!--- Modify groups --->
<a href="?tag=PolicyGroupSearch">Policy Groups</a><br>
<a href="?tag=PolicyGroupCreateEdit">Create a Policy Group</a><br>
<a href="?tag=PolicyGroupMappingSearch">Show Policy Group Mappings</a><br>
<a href="?tag=PolicyGroupMap">Map Policy Group</a><br>
<br>
<i>Permissions</i><br>
<a href="?tag=PermissionSearch">Permissions</a><br>
<a href="?tag=PermissionCreateEdit">Create a Permission</a><br>
<br>
</nobr>
</cfoutput>

<cfsetting enablecfoutputonly="No">
