<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2006, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header:  $
$Author:  $
$Date: $
$Name:  $
$Revision: $

|| DESCRIPTION || 
$Description: Admin footer $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
--->

<!--- exit tag if its been closed, ie don't run twice --->
<cfif thistag.executionmode eq "end">
	<cfexit method="exittag" />
</cfif>

<cfoutput>
</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="No">