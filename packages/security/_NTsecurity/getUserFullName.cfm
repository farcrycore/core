<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/security/_NTsecurity/getUserFullName.cfm,v 1.1 2002/10/17 04:14:39 pete Exp $
$Author: pete $
$Date: 2002/10/17 04:14:39 $
$Name: b131 $
$Revision: 1.1 $

|| DESCRIPTION || 
retrieve full name of user

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| HISTORY ||
$Log: getUserFullName.cfm,v $
Revision 1.1  2002/10/17 04:14:39  pete
no message


|| END FUSEDOC ||
--->

<cftry>
    <cfscript>
    o_user = createObject("COM", "NTAdmin.NTUserManagement");
    fullName = o_user.QueryUserProperty(stArgs.domain, stArgs.userName, "FullName");
    </cfscript>
<cfcatch>
    <cfset fullName = "">
</cfcatch>
</cftry>
