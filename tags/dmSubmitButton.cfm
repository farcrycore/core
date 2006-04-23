<cfif ISDEFINED("ATTRIBUTES.Name") and ISDEFINED("ATTRIBUTES.Value")>
	<cfparam name="ATTRIBUTES.Width" default="70">
	<cfparam name="ATTRIBUTES.Type" default="Submit">
	<cfparam name="ATTRIBUTES.OnClick" default="">
	<cfoutput>
	<input name="#ATTRIBUTES.Name#" type="#ATTRIBUTES.Type#" value="#ATTRIBUTES.Value#" style="width:#ATTRIBUTES.Width#" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onclick="#ATTRIBUTES.OnClick#">
</cfoutput>
</cfif>

