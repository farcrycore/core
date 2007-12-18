<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: $
$Author:  $
$Date:  $
$Name:  $
$Revision:  $

|| DESCRIPTION || 
$Description: 	This file is run after /core/tags/farcry/_requestScope.cfm
				It enables us to both override the default farcry request scope variables and also add our own
$

|| DEVELOPER ||mat@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">
	
<!--- Setup for specific developers --->
<cfswitch expression="#application.sysInfo.machineName#">
	
	
	<cfdefaultcase>
		<cfscript>
			request.mode.bDeveloper = 0; // Developer Mode
		</cfscript>	
	</cfdefaultcase> 
	
	
</cfswitch>
	
	
<cfsetting enablecfoutputonly="no">