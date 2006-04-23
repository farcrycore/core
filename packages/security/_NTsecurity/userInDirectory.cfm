<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/security/_NTsecurity/userInDirectory.cfm,v 1.2 2002/10/15 03:58:37 pete Exp $
$Author: pete $
$Date: 2002/10/15 03:58:37 $
$Name: b131 $
$Revision: 1.2 $

|| DESCRIPTION || 
determine if a given login is a member of a domain

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| HISTORY ||
$Log: userInDirectory.cfm,v $
Revision 1.2  2002/10/15 03:58:37  pete
no message

Revision 1.1  2002/10/15 03:43:18  pete
no message

|| END FUSEDOC ||
--->

<cftry>
    <cfscript>
    o_NTAuth = createObject("java", "jrun.security.NTAuth");
    o_NTAuth.init(stArgs.domain);
    o_NTAuth.isUserInDirectory(stArgs.userName);
    bInDir = "true";
    </cfscript>
<cfcatch>
    <cfset bInDir = "false">
</cfcatch>
</cftry>