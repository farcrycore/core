<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/editRule.cfm,v 1.4 2004/01/08 22:42:24 brendan Exp $
$Author: brendan $
$Date: 2004/01/08 22:42:24 $
$Name: milestone_2-1-2 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: $
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

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