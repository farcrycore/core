<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/security/_NTsecurity/getGroupUsers.cfm,v 1.2 2003/09/10 23:27:33 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 23:27:33 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 
retrieve users part of an Active Directory group

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| END FUSEDOC ||
--->

<cfscript>
o_group = createObject("COM", "NTAdmin.NTGroupManagement");

aUsers = arrayNew(1);
aUsers  = o_group.EnumerateGroupMembers(arguments.domain, arguments.groupName);
</cfscript>
