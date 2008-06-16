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
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/reporting/statsVisitorPathDetail.cfm,v 1.7 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: Displays path taken by visitor during session$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<sec:CheckPermission error="true" permission="ReportingStatsTab">
	<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin">
	<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
	
	<!--- get stats --->
	<cfscript>
		qVisitorPath = application.factory.oStats.getVisitorPath(sessionid='#url.sessionId#');
	</cfscript>
	
	<cfoutput>
	<h3>#application.rb.getResource("visitorPath")#</h3>
	</cfoutput>
	
	<cfloop query="qVisitorPath">
		<cftry>
			<q4:contentobjectget objectID="#objectid#" r_stobject="stObject">
			<skin:breadcrumb 
			separator=" &raquo; " 
			objectid = "#navid#"
			here= "#stObject.title#"
			linkclass="breadcrumb">
			<cfoutput> (#timeSpent#)<p></p></cfoutput>
			<cfcatch></cfcatch>
		</cftry>
	</cfloop>
</sec:CheckPermission>

<admin:footer>

<cfsetting enablecfoutputonly="no">