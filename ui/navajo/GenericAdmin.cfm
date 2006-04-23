<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/ui/navajo/Attic/GenericAdmin.cfm,v 1.2 2003/04/23 23:39:47 brendan Exp $
$Author: brendan $
$Date: 2003/04/23 23:39:47 $
$Name: b131 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: calls generic admin for all types. $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $


|| ATTRIBUTES ||
$in: [url.typename]: object type $
--->

<!--- required variables --->
<cfimport taglib="/farcry/farcry_core/tags/farcry/" prefix="farcry">
<cfparam name="url.type" default="news">

<cfif not IsDefined("url.typename")>
	<h3>Typename not present in URL scope - better fix this link</h3>
	<cfabort>
</cfif>

<cfset permissionType = "news">

<cfscript>
	typename = "#URL.typeName#";
</cfscript>	
<!--- call generic admin with extrapolation of URL type --->

<farcry:genericAdmin permissionType="#permissionType#"  admintype="#url.type#" metadata="True" header="false" typename="#typename#">
