<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/security/_NTsecurity/getUserGroups.cfm,v 1.5 2003/09/10 23:27:33 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 23:27:33 $
$Name: milestone_3-0-1 $
$Revision: 1.5 $

|| DESCRIPTION || 
fetches valid groups a user is a member of

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| END FUSEDOC ||
--->

<cftry>
    <cfscript>
    o_NTAuth = createObject("java", "jrun.security.NTAuth");
    o_NTAuth.init(arguments.domain);
    groups = o_NTAuth.getUserGroups(arguments.userName);
    groups = arrayToList(groups);
    </cfscript>
<cfcatch>
    <cfset groups = "false">
</cfcatch>
</cftry>
