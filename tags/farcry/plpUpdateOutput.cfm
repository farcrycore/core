<!--- 
 // DEPRECATED
	farcry:plpUpdateOutput is no longer in use and will be removed from the code base. 
	You should be using formtools sub-system instead.
--------------------------------------------------------------------------------------------------->
<!--- @@bDeprecated: true --->
<cfset application.fapi.deprecated("farcry:plpUpdateOutput is no longer in use and will be removed from the code base. You should be using formtools sub-system instead.") />


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
$Header: /cvs/farcry/core/tags/farcry/plpUpdateOutput.cfm,v 1.3 2005/06/22 07:03:04 guy Exp $
$Author: guy $
$Date: 2005/06/22 07:03:04 $
$Name: milestone_3-0-1 $
$Revision: 1.3 $

|| DESCRIPTION || 
Updates the output scope with submitted form elements from the plp

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: 
out:
--->

<cfinclude template="/farcry/core/webtop/includes/utilityFunctions.cfm">
<cfloop index="FormItem" list="#CALLER.FORM.FieldNames#">
	<cfif StructKeyExists(CALLER.output,FormItem)>
		<cfif FormItem EQ "body">
			<cfset "CALLER.output.#FormItem#" = fEscapeHTMLChars(Evaluate("CALLER.FORM.#FormItem#"))>
		<cfelse>
			<cfset "CALLER.output.#FormItem#" = Evaluate("CALLER.FORM.#FormItem#")>
		</cfif>
	</cfif>
</cfloop>