<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/coapiMetaData.cfm,v 1.4 2004/07/15 01:10:24 brendan Exp $
$Author: brendan $
$Date: 2004/07/15 01:10:24 $
$Name: milestone_2-3-2 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Dumps COAPI metadata $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting enablecfoutputonly="Yes" requesttimeout="600">

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iCOAPITab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminCOAPITab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iCOAPITab eq 1>	

	<cfoutput><span class="formtitle">#application.adminBundle[session.dmProfile.locale].COAPITypeMetaData#</span><p></p></cfoutput>
	<cfdump var="#application.types#" label="application.types" expand="no">
	
	<cfoutput><p></p>
	<span class="formtitle">#application.adminBundle[session.dmProfile.locale].COAPIRulesMetaData#</span><p></p></cfoutput>
	
	<cfdump var="#application.rules#" label="application.rules" expand="no">

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>

<cfsetting enablecfoutputonly="No">