<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/security/_NTsecurity/userInGroup.cfm,v 1.7 2002/11/26 05:37:37 pete Exp $
$Author: pete $
$Date: 2002/11/26 05:37:37 $
$Name: b131 $
$Revision: 1.7 $

|| DESCRIPTION || 
determine if a given user is in a domain group

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| HISTORY ||
$Log: userInGroup.cfm,v $
Revision 1.7  2002/11/26 05:37:37  pete
using ADSI instead of jrun.NTAuth

Revision 1.6  2002/10/24 02:47:14  pete
ADSI changes

Revision 1.5  2002/10/24 02:37:37  pete
ADSI changes

Revision 1.4  2002/10/24 02:32:50  pete
ADSI changes

Revision 1.3  2002/10/15 07:47:23  pete
syntax error fix

Revision 1.2  2002/10/15 03:58:37  pete
no message

Revision 1.1  2002/10/15 03:43:18  pete
no message

|| END FUSEDOC ||
--->

<cftry>
    <cfscript>
    o_group = createObject("COM", "NTAdmin.NTGroupManagement");
    bInGroup = o_group.VerifyGroupMembership(stArgs.domain, stArgs.groupName, stArgs.domain, stArgs.userName);
    </cfscript>
<cfcatch>
    <cfset bInGroup = "false">
</cfcatch>
</cftry>