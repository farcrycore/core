<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
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