<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/farcry/dmSubmitButton.cfm,v 1.2 2004/07/15 02:02:18 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 02:02:18 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 
Displays a form button

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: width,type,onClick,value,name
out:
--->
<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<cfif ISDEFINED("ATTRIBUTES.Name") and ISDEFINED("ATTRIBUTES.Value")>
	<cfparam name="ATTRIBUTES.Width" default="70">
	<cfparam name="ATTRIBUTES.Type" default="Submit">
	<cfparam name="ATTRIBUTES.OnClick" default="">
	<cfoutput>
	<input name="#ATTRIBUTES.Name#" type="#ATTRIBUTES.Type#" value="#ATTRIBUTES.Value#" style="width:#ATTRIBUTES.Width#" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onclick="#ATTRIBUTES.OnClick#">
</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="no">
