<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/customadmin.cfm,v 1.6 2003/11/16 08:18:34 geoff Exp $
$Author: geoff $
$Date: 2003/11/16 08:18:34 $
$Name: milestone_2-2-1 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: This template simply invokes the custom admin module 
with the relevant custom admin code.  Header and footer information 
should be provided by the invoked template. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cftry>
	<cfmodule template="/farcry/#application.applicationname#/customadmin/#URL.module#">
	<cfcatch>
		<cfoutput>
			<h3>Error: Custom Administration</h3>
			<p>#cfcatch.Message#</p>
			<p>#cfcatch.Detail#</p>
		</cfoutput>
	</cfcatch>
</cftry> 

<cfsetting enablecfoutputonly="No">