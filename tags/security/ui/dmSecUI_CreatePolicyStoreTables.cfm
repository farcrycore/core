<cfsetting enablecfoutputonly="Yes">
<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSecUI_CreatePolicyStoreTables.cfm,v 1.1 2003/04/08 08:52:20 paul Exp $
$Author: paul $
$Date: 2003/04/08 08:52:20 $
$Name: b201 $
$Revision: 1.1 $

|| DESCRIPTION || 

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||

|| HISTORY ||
$Log: dmSecUI_CreatePolicyStoreTables.cfm,v $
Revision 1.1  2003/04/08 08:52:20  paul
CFC security updates

Revision 1.1.1.1  2002/08/22 07:18:17  geoff
no message

Revision 1.1  2001/11/18 16:15:22  matson
moved all files to custom tags daemon_security/UI (dmSecUI)

Revision 1.2  2001/11/12 10:54:47  matson
massive update here. navajo is now base install

Revision 1.1.1.1  2001/10/29 15:04:22  matson
no message

Revision 1.1.1.1  2001/09/26 22:02:02  matson
no message


|| END FUSEDOC ||
--->

<cfscript>
	oInit = createObject("component","#application.packagepath#.security.init");
	request.dmsec.oAuthorisation.getPolicyStore();
	oInit.initAuthorisationDatabase(datasource="#stPolicyStore.datasource#");
</cfscript>


<cfsetting enablecfoutputonly="No">