<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2002
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/security/_NTsecurity/getDomainGroups.cfm,v 1.2 2003/09/10 23:27:33 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 23:27:33 $
$Name: b201 $
$Revision: 1.2 $

|| DESCRIPTION || 
retrieve all groups in specified domain

|| DEVELOPER ||
Peter Alexandrou (suspiria@daemon.com.au)

|| ATTRIBUTES ||
none

|| END FUSEDOC ||
--->

<cfscript>
o_domain = createObject("COM", "NTAdmin.NTContainerManagement");

aGroups = arrayNew(1);
aGroups  = o_domain.EnumerateContainer(arguments.domain, "GlobalGroup");
</cfscript>
