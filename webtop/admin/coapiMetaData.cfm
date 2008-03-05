<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/admin/coapiMetaData.cfm,v 1.5 2005/08/16 05:53:23 pottery Exp $
$Author: pottery $
$Date: 2005/08/16 05:53:23 $
$Name: milestone_3-0-1 $
$Revision: 1.5 $

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

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="AdminCOAPITab">
	<cfoutput><h3>#application.rb.getResource("COAPITypeMetaData")#</h3></cfoutput>
	<cfdump var="#application.types#" label="application.types" expand="no">
	
	<cfoutput>
	<h3>#application.rb.getResource("COAPIRulesMetaData")#</h3></cfoutput>
	
	<cfdump var="#application.rules#" label="application.rules" expand="no">
</sec:CheckPermission>

<admin:footer>

<cfsetting enablecfoutputonly="No">