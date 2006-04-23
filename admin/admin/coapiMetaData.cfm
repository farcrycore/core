<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/coapiMetaData.cfm,v 1.3 2003/09/03 01:50:31 brendan Exp $
$Author: brendan $
$Date: 2003/09/03 01:50:31 $
$Name: b201 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: Dumps COAPI metadata $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting enablecfoutputonly="Yes" requesttimeout="600">

<!--- check permissions --->
<cfscript>
	iCOAPITab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminCOAPITab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iCOAPITab eq 1>	

	<cfoutput><span class="formtitle">COAPI Type MetaData</span><p></p></cfoutput>
	<cfdump var="#application.types#" label="application.types" expand="no">
	
	<cfoutput><p></p>
	<span class="formtitle">COAPI Rules MetaData</span><p></p></cfoutput>
	
	<cfdump var="#application.rules#" label="application.rules" expand="no">

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="No">