<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/security/_NTsecurity/getGroupDescription.cfm,v 1.3 2003/09/10 23:27:33 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 23:27:33 $
$Name: b201 $
$Revision: 1.3 $

|| DESCRIPTION || 
retrieve group description

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none


|| END FUSEDOC ||
--->

<cftry>
    <cfscript>
    o_group = createObject("COM", "NTAdmin.NTGroupManagement");
    desc = o_group.QueryGroupDescription(arguments.domain, arguments.groupName);
    </cfscript>
<cfcatch>
    <cfset desc = "">
</cfcatch>
</cftry>