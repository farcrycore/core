<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/security/_NTsecurity/getUserFullName.cfm,v 1.2 2003/09/10 23:27:33 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 23:27:33 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 
retrieve full name of user

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| END FUSEDOC ||
--->

<cftry>
    <cfscript>
    o_user = createObject("COM", "NTAdmin.NTUserManagement");
    fullName = o_user.QueryUserProperty(arguments.domain, arguments.userName, "FullName");
    </cfscript>
<cfcatch>
    <cfset fullName = "">
</cfcatch>
</cftry>
