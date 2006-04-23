<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/security/_NTsecurity/userInGroup.cfm,v 1.8 2003/09/10 23:27:33 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 23:27:33 $
$Name: b201 $
$Revision: 1.8 $

|| DESCRIPTION || 
determine if a given user is in a domain group

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| END FUSEDOC ||
--->

<cftry>
    <cfscript>
    o_group = createObject("COM", "NTAdmin.NTGroupManagement");
    bInGroup = o_group.VerifyGroupMembership(arguments.domain, arguments.groupName, arguments.domain, arguments.userName);
    </cfscript>
<cfcatch>
    <cfset bInGroup = "false">
</cfcatch>
</cftry>