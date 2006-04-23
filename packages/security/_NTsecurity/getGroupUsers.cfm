<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/security/_NTsecurity/getGroupUsers.cfm,v 1.1 2002/10/22 01:00:21 pete Exp $
$Author: pete $
$Date: 2002/10/22 01:00:21 $
$Name: b131 $
$Revision: 1.1 $

|| DESCRIPTION || 
retrieve users part of an Active Directory group

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| HISTORY ||
$Log: getGroupUsers.cfm,v $
Revision 1.1  2002/10/22 01:00:21  pete
first working version



|| END FUSEDOC ||
--->

<cfscript>
o_group = createObject("COM", "NTAdmin.NTGroupManagement");

aUsers = arrayNew(1);
aUsers  = o_group.EnumerateGroupMembers(stArgs.domain, stArgs.groupName);
</cfscript>