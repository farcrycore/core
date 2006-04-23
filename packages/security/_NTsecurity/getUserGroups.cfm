<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/security/_NTsecurity/getUserGroups.cfm,v 1.4 2002/10/15 07:14:06 pete Exp $
$Author: pete $
$Date: 2002/10/15 07:14:06 $
$Name: b131 $
$Revision: 1.4 $

|| DESCRIPTION || 
fetches valid groups a user is a member of

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| HISTORY ||
$Log: getUserGroups.cfm,v $
Revision 1.4  2002/10/15 07:14:06  pete
no message

Revision 1.3  2002/10/15 03:42:19  pete
no message

Revision 1.2  2002/10/15 02:21:49  pete
no message

Revision 1.1  2002/10/15 01:56:58  pete
first working version

|| END FUSEDOC ||
--->

<cftry>
    <cfscript>
    o_NTAuth = createObject("java", "jrun.security.NTAuth");
    o_NTAuth.init(stArgs.domain);
    groups = o_NTAuth.getUserGroups(stArgs.userName);
    groups = arrayToList(groups);
    </cfscript>
<cfcatch>
    <cfset groups = "false">
</cfcatch>
</cftry>