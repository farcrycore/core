<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/security/_NTsecurity/userInDirectory.cfm,v 1.3 2003/09/10 23:27:33 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 23:27:33 $
$Name: milestone_3-0-1 $
$Revision: 1.3 $

|| DESCRIPTION || 
determine if a given login is a member of a domain

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
    o_NTAuth.isUserInDirectory(arguments.userName);
    bInDir = "true";
    </cfscript>
<cfcatch>
    <cfset bInDir = "false">
</cfcatch>
</cftry>
