<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/security/ui/_dmSecUI_Header.cfm,v 1.2 2004/07/15 02:03:27 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 02:03:27 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||

|| HISTORY ||
$Log: _dmSecUI_Header.cfm,v $
Revision 1.2  2004/07/15 02:03:27  brendan
i18n updates

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

<cfset request.cfa.mode.debug = 1>

<cfoutput>
<html dir="#session.writingDir#" lang="#session.userLanguage#">

<style>
table, body, input, select, textarea
{
	font-size:11px;
}

a
{
	color: ##000044;
	text-decoration : none;
}
</style>

<body style="margin:0 0 0 0;">

<table border="1" cellpadding="5" cellspacing="1" width="100%" height="100%">
<tr height="1%">
	<td colspan="2" bgcolor="##87CEEB" valign="middle" align="center" width="100%"><h2 style="display:inline;">#application.adminBundle[session.dmProfile.locale].daemonSecurityAdmin#</h2></td>
</tr>

<tr>
<td bgcolor="##87CEEB" valign="top"><cfinclude template="dmSecUI_Nav.cfm"></td>
<td bgcolor="##F0F8FF" valign="top" width="100%">
</cfoutput>

<cfsetting enablecfoutputonly="No">
