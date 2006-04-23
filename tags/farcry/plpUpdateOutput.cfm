<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/plpUpdateOutput.cfm,v 1.1 2003/03/20 22:43:36 brendan Exp $
$Author: brendan $
$Date: 2003/03/20 22:43:36 $
$Name: b201 $
$Revision: 1.1 $

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