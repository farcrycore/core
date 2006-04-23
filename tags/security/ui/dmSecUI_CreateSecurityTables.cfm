<cfsetting enablecfoutputonly="Yes">
<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSecUI_CreateSecurityTables.cfm,v 1.2 2003/09/22 03:45:38 brendan Exp $
$Author: brendan $
$Date: 2003/09/22 03:45:38 $
$Name: b201 $
$Revision: 1.2 $

|| DESCRIPTION || 

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||
-> userDirectory: which user directory to use.

|| HISTORY ||
$Log: dmSecUI_CreateSecurityTables.cfm,v $
Revision 1.2  2003/09/22 03:45:38  brendan
*nix mods

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
	stUD=request.dmsec.oAuthentication.getUserDirectory();
	if (stUd[userDirectory].type IS "Daemon")
		oInit.initAuthenticationDatabase(datasource="#stUd[userDirectory].datasource#");
	else
		writeoutput("<span style='color:red;'>Error:</span> Cannot create non daemon security setups.");	
</cfscript>

<cfsetting enablecfoutputonly="No">