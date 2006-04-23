<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/security/_NTsecurity/authenticateUser.cfm,v 1.4 2003/09/10 23:27:33 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 23:27:33 $
$Name: b201 $
$Revision: 1.4 $

|| DESCRIPTION || 
authenticates user login information against Active Directory

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

    // authenticateUser throws an exception if it fails
    o_NTAuth.authenticateUser(arguments.userName, arguments.password);
    bAuth = "true";
    </cfscript>
<cfcatch>
    <cfset bAuth = "false">
</cfcatch>
</cftry>