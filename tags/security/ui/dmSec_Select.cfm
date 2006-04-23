<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||
Daemon Pty Limited 1995-2001
http://www.daemon.com.au/

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/security/ui/dmSec_Select.cfm,v 1.3 2004/07/15 02:03:27 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 02:03:27 $
$Name: milestone_3-0-1 $
$Revision: 1.3 $

|| DESCRIPTION || 
Generates a html for selectlist dropdown from a structure.

|| USAGE ||

|| DEVELOPER ||
Matt Dawson (mad@daemon.com.au)

|| ATTRIBUTES ||

|| HISTORY ||
$Log: dmSec_Select.cfm,v $
Revision 1.3  2004/07/15 02:03:27  brendan
i18n updates

Revision 1.2  2003/04/09 08:04:59  spike
Major update to remove need for multiple ColdFusion and webserver mappings.

Revision 1.1  2003/04/08 08:52:20  paul
CFC security updates

Revision 1.1.1.1  2002/08/22 07:18:02  geoff
no message

Revision 1.1  2001/09/20 17:34:57  matson
first import


|| END FUSEDOC ||
--->
<cfimport taglib="/farcry/farcry_core/tags/security/ui/" prefix="dmsec">
<cfparam name="attributes.name">
<cfparam name="attributes.size" default="1">
<cfparam name="attributes.bMultiple" default="0">
<cfparam name="attributes.lSelected" default="">

<cfoutput>
	<select name="#attributes.name#">
	</cfoutput>
	
	<cfif isDefined("attributes.stValues")>
		<cfloop index="i" list="#StructKeyList(attributes.stValues)#">
			<cfoutput>
				<option value="#i#" <cfif listcontains(attributes.lselected,i)>selected</cfif>>#i#
			</cfoutput>
		</cfloop>
		
	<cfelseif isDefined("attributes.aValues")>
		<cfloop index="i" from="1" to="#ArrayLen(attributes.aValues)#">
			<cfoutput>
				<cfif isDefined("attributes.ValueField")>
					<option value="#attributes.aValues[i]['#attributes.ValueField#']#" <cfif listcontains(attributes.lselected,attributes.aValues[i][#attributes.ValueField#])>selected</cfif>>#attributes.aValues[i]['#attributes.TextField#']#
				<cfelse>
					<option value="#attributes.aValues[i]#" <cfif listcontains(attributes.lselected,attributes.aValues[i])>selected</cfif>>#attributes.aValues[i]#
				</cfif>
			</cfoutput>
		</cfloop>
		
	<cfelse>
		<dmsec:dmSec_throw errorCode="dmSec_Parameters" lExtra="#application.adminBundle[session.dmProfile.locale].missingdmSec_SelectValue#">
		
	</cfif>
	
	<cfoutput>
	</select>
</cfoutput>

<cfsetting enablecfoutputonly="No">
