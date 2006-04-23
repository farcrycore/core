<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/plpUpdateOutput.cfm,v 1.3 2005/06/22 07:03:04 guy Exp $
$Author: guy $
$Date: 2005/06/22 07:03:04 $
$Name: milestone_3-0-0 $
$Revision: 1.3 $

|| DESCRIPTION || 
Updates the output scope with submitted form elements from the plp

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: 
out:
--->

<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm">
<cfloop index="FormItem" list="#CALLER.FORM.FieldNames#">
	<cfif StructKeyExists(CALLER.output,FormItem)>
		<cfif FormItem EQ "body">
			<cfset "CALLER.output.#FormItem#" = fEscapeHTMLChars(Evaluate("CALLER.FORM.#FormItem#"))>
		<cfelse>
			<cfset "CALLER.output.#FormItem#" = Evaluate("CALLER.FORM.#FormItem#")>
		</cfif>
	</cfif>
</cfloop>