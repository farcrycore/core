<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/security/_NTsecurity/getDomainGroups.cfm,v 1.1 2002/10/15 08:48:51 pete Exp $
$Author: pete $
$Date: 2002/10/15 08:48:51 $
$Name: b131 $
$Revision: 1.1 $

|| DESCRIPTION || 
retrieve all groups in specified domain

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| HISTORY ||
$Log: getDomainGroups.cfm,v $
Revision 1.1  2002/10/15 08:48:51  pete
first working version


|| END FUSEDOC ||
--->

<cfscript>
o_domain = createObject("COM", "NTAdmin.NTContainerManagement");

aGroups = arrayNew(1);
aGroups  = o_domain.EnumerateContainer(stArgs.domain, "GlobalGroup");
</cfscript>
