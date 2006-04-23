<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/security/_NTsecurity/getGroupDescription.cfm,v 1.2 2002/10/15 08:54:15 pete Exp $
$Author: pete $
$Date: 2002/10/15 08:54:15 $
$Name: b131 $
$Revision: 1.2 $

|| DESCRIPTION || 
retrieve group description

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| HISTORY ||
$Log: getGroupDescription.cfm,v $
Revision 1.2  2002/10/15 08:54:15  pete
no message

Revision 1.1  2002/10/15 08:48:51  pete
first working version


|| END FUSEDOC ||
--->

<cftry>
    <cfscript>
    o_group = createObject("COM", "NTAdmin.NTGroupManagement");
    desc = o_group.QueryGroupDescription(stArgs.domain, stArgs.groupName);
    </cfscript>
<cfcatch>
    <cfset desc = "">
</cfcatch>
</cftry>