<!--- 
 // DEPRECATED
	farcry:dmButton is no longer in use and will be removed from the code base. 
	You should be using formtools sub-system instead.
--------------------------------------------------------------------------------------------------->
<!--- @@bDeprecated: true --->
<cfset application.fapi.deprecated("farcry:dmButton is no longer in use and will be removed from the code base. You should be using formtools sub-system instead.") />


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
$Header: /cvs/farcry/core/tags/farcry/dmButton.cfm,v 1.2 2004/07/15 02:02:18 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 02:02:18 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 
Displays a button on the screen with mouse over color changes.

|| DEVELOPER ||
Mat Bryant (mat@daemon.com.au)
Jason Ellison (jason@daemon.com.au)

|| ATTRIBUTES ||
in: [Attributes.name]: required : name for the button
in: [Attributes.value]: required : value for the button
in: [Attributes.type]: optional (Submit) : The type for the button; button, submit or reset
in: [Attributes.width]: optional : The width of the button
in: [Attributes.style]: optional : The style definition
in: [Attributes.onclick]: optional : The onclick event definition
in: [Attributes.disabled]: optional (False) : if the button should be disabled or not 
out:
--->
<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<cfif ISDEFINED("ATTRIBUTES.Name") and ISDEFINED("ATTRIBUTES.Value")>
	<cfparam name="ATTRIBUTES.Type" default="Submit">
	<cfparam name="attributes.disabled" default="false">
	<cfoutput>
	<input name="#ATTRIBUTES.Name#" type="#ATTRIBUTES.Type#"<cfif attributes.disabled eq true> disabled</cfif> value="#ATTRIBUTES.Value#"<cfif IsDefined("Attributes.width")> width="#ATTRIBUTES.Width#"</cfif><cfif IsDefined("Attributes.width") OR IsDefined("Attributes.style")> style="<cfif IsDefined("Attributes.width")>width:#ATTRIBUTES.width#;</cfif><cfif IsDefined("Attributes.style")>#Attributes.style#</cfif>"</cfif> class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';"<cfif IsDefined("Attributes.onclick")> onClick="#ATTRIBUTES.OnClick#"</cfif>>
</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="no">
