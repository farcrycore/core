<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/_error.cfm,v 1.4 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-0 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: basic error control page. Emails administrator and shows dump if requested$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- email administrator --->
<cfmail to="#application.config.general.ADMINEMAIL#" from="#application.config.general.ADMINEMAIL#" subject="Error in #application.applicationname#" type="html">
<cfdump var="#error#" label="Error Diagnostics">
</cfmail>

<!--- dump error diagnostics for developers --->
<cfif isdefined("url.debug")>
	<!--- reset dump variable in request scope to try cf into thinking it hasn't already dumped on the page --->
	<cfset request.cfdumpinited = false>
	<p></p><cfdump var="#error#" label="Error Diagnostics">
</cfif>