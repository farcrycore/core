<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/security/_NTsecurity/getUserDescription.cfm,v 1.1 2002/10/15 08:54:29 pete Exp $
$Author: pete $
$Date: 2002/10/15 08:54:29 $
$Name: b131 $
$Revision: 1.1 $

|| DESCRIPTION || 
retrieve a users description from Active Directory

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| HISTORY ||
$Log: getUserDescription.cfm,v $
Revision 1.1  2002/10/15 08:54:29  pete
no message


|| END FUSEDOC ||
--->

<cftry>
    <cfscript>
    o_user = createObject("COM", "NTAdmin.NTUserManagement");
    desc = o_user.QueryUserProperty(stArgs.domain, stArgs.userName, "Description");
    </cfscript>
<cfcatch>
    <cfset desc = "">
</cfcatch>
</cftry>