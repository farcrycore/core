<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/editRule.cfm,v 1.2 2003/09/03 01:50:31 brendan Exp $
$Author: brendan $
$Date: 2003/09/03 01:50:31 $
$Name: b201 $
$Revision: 1.2 $

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
		if(application.rules['#url.typename#'].bCustomRule)
			packagePath = "#application.custompackagepath#.rules.#url.typename#";
		else	
			packagePath = "#application.packagepath#.rules.#url.typename#";
		o = createObject("component","#packagepath#");
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