<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/security/_NTsecurity/authenticateUser.cfm,v 1.3 2002/10/15 03:42:19 pete Exp $
$Author: pete $
$Date: 2002/10/15 03:42:19 $
$Name: b131 $
$Revision: 1.3 $

|| DESCRIPTION || 
authenticates user login information against Active Directory

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| HISTORY ||
$Log: authenticateUser.cfm,v $
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

    // authenticateUser throws an exception if it fails
    o_NTAuth.authenticateUser(stArgs.userName, stArgs.password);
    bAuth = "true";
    </cfscript>
<cfcatch>
    <cfset bAuth = "false">
</cfcatch>
</cftry>