<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/admin/editRule.cfm,v 1.6.2.1 2006/02/14 02:55:28 tlucas Exp $
$Author: tlucas $
$Date: 2006/02/14 02:55:28 $
$Name: milestone_3-0-1 $
$Revision: 1.6.2.1 $

|| DESCRIPTION || 
$Description: $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<sec:CheckPermission error="true" permission="AdminCOAPITab">
	<cfscript>
	if(isDefined("url.typename") AND isDefined("url.ruleid"))
	{
		o = createObject("component", application.rules[url.typename].rulePath);
		if (url.typename eq "ruleHandpicked") {
			o.update(objectid=URL.ruleid,cancelLocation="#application.url.farcry#/edittabRules.cfm?");
		} else {
			o.update(objectid=URL.ruleid);
		}
	}
	</cfscript>
</sec:CheckPermission>