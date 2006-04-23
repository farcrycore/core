<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSecUI_TestPolicySetup.cfm,v 1.3 2004/01/18 22:45:44 brendan Exp $
$Author: brendan $
$Date: 2004/01/18 22:45:44 $
$Name: milestone_2-1-2 $
$Revision: 1.3 $

|| DESCRIPTION || 
Creates all the required tables for daemon security.

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||
-> [um]: inbound var or attribute 
<- [er]: outbound var or caller var

--->
<cfimport taglib="/farcry/farcry_core/tags/security/ui/" prefix="dmsec">
<dmsec:dmSec_TestPolicySetup>