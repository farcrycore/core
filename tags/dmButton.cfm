<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/Attic/dmButton.cfm,v 1.1.1.1 2002/09/27 06:54:04 petera Exp $
$Author: petera $
$Date: 2002/09/27 06:54:04 $
$Name: b100 $
$Revision: 1.1.1.1 $

|| DESCRIPTION || 
Displays a button on the screen with mouse over color changes.

|| DEVELOPER ||
Mat Bryant (mat@daemon.com.au)
Jason Ellison (jason@daemon.com.au)

|| ATTRIBUTES ||
-> [Attributes.name]: required : name for the button
-> [Attributes.value]: required : value for the button
-> [Attributes.type]: optional (Submit) : The type for the button; button, submit or reset
-> [Attributes.width]: optional : The width of the button
-> [Attributes.style]: optional : The style definition
-> [Attributes.onclick]: optional : The onclick event definition
-> [Attributes.disabled]: optional (False) : if the button should be disabled or not 

|| HISTORY ||
$Log: dmButton.cfm,v $
Revision 1.1.1.1  2002/09/27 06:54:04  petera
no message

Revision 1.1.1.1  2002/06/27 07:30:11  geoff
Geoff's initial build

Revision 1.2  2001/07/06 14:15:41  aaron
Removed default width
Added in attribute for style definitions.
Cleaned up code


|| END FUSEDOC ||
--->

<cfif ISDEFINED("ATTRIBUTES.Name") and ISDEFINED("ATTRIBUTES.Value")>
	<cfparam name="ATTRIBUTES.Type" default="Submit">
	<cfparam name="attributes.disabled" default="false">
	<cfoutput>
	<input name="#ATTRIBUTES.Name#" type="#ATTRIBUTES.Type#"<cfif attributes.disabled eq true> disabled</cfif> value="#ATTRIBUTES.Value#"<cfif IsDefined("Attributes.width")> width="#ATTRIBUTES.Width#"</cfif><cfif IsDefined("Attributes.width") OR IsDefined("Attributes.style")> style="<cfif IsDefined("Attributes.width")>width:#ATTRIBUTES.width#;</cfif><cfif IsDefined("Attributes.style")>#Attributes.style#</cfif>"</cfif> class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';"<cfif IsDefined("Attributes.onclick")> onclick="#ATTRIBUTES.OnClick#"</cfif>>
</cfoutput>
</cfif>

