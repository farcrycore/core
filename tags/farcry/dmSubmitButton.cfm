<!--- 
 // DEPRECATED
	farcry:dmSubmitButton is no longer in use and will be removed from the code base. 
	You should be using formtools sub-system instead.
--------------------------------------------------------------------------------------------------->
<!--- @@bDeprecated: true --->
<cfset application.fapi.deprecated("farcry:dmSubmitButton is no longer in use and will be removed from the code base. You should be using formtools sub-system instead.") />

<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
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
