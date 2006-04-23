<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/widgets/dmButton.cfm,v 1.1 2005/06/24 03:38:13 guy Exp $
$Author: guy $
$Date: 2005/06/24 03:38:13 $
$Name: milestone_3-0-0 $
$Revision: 1.1 $

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