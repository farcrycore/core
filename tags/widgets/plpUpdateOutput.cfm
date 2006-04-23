<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/widgets/plpUpdateOutput.cfm,v 1.2 2005/08/01 05:53:24 guy Exp $
$Author: guy $
$Date: 2005/08/01 05:53:24 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 
Updates the output scope with submitted form elements from the plp

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: 
out:
--->
<cfloop index="FormItem" list="#CALLER.FORM.FieldNames#">
	<cfif StructKeyExists(CALLER.output,FormItem)>
		<cfset "CALLER.output.#FormItem#" = Evaluate("CALLER.FORM.#FormItem#")>
	</cfif>
</cfloop>
