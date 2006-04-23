<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/editRule.cfm,v 1.6 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-0 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iCOAPITab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminCOAPITab");
</cfscript>

<cfif iCOAPITab eq 1>
	<cfscript>
	if(isDefined("url.typename") AND isDefined("url.ruleid"))
	{
		o = createObject("component", application.rules[url.typename].rulePath);
		if (url.typename eq "ruleHandpicked") {
			o.update(objectid=URL.ruleid,cancelLocation="#application.url.farcry#/editTabRules.cfm?");
		} else {
			o.update(objectid=URL.ruleid);
		}
	}
	</cfscript>

<cfelse>
	<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
	<admin:permissionError>
</cfif>