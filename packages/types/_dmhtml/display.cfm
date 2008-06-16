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
$Header: /cvs/farcry/core/packages/types/_dmhtml/display.cfm,v 1.8 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: dmHTML default display method  $


|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
--->
<cfprocessingDirective pageencoding="utf-8">

<cfscript>
	// get navigation elements
	// getChildren for application.navid.home
	qPrimary = application.factory.oTree.getChildren(objectid=application.navid.home);
	qSecondary = application.factory.oTree.getChildren(objectid=request.navid);
	qAncestors = application.factory.oTree.getAncestors(objectid=request.navid);
</cfscript>

<cfsetting enablecfoutputonly="yes">
<cfmodule 
	template="/farcry/templates/pagetemplates/greyBuildHeader.cfm"
	pageTitle="#stObj.title#"
>

<cfoutput>
<div style="padding: 5px; float: right; width: 150px; border: 1px ##333 solid;">
<p>
<b>#application.rb.getResource("primaryNav")#</b><br>
</cfoutput>
<cfoutput query="qPrimary">
<a href="index.cfm?objectid=#qPrimary.objectid#">#qPrimary.objectName#</a><br>
</cfoutput>
<cfoutput>
</p>
<p>
<b>#application.rb.getResource("secondaryNav")#</b><br>
</cfoutput>
<cfoutput query="qSecondary">
<a href="index.cfm?objectid=#qSecondary.objectid#">#qSecondary.objectName#</a><br>
</cfoutput>
<cfoutput>
</p>
<p>
<b>#application.rb.getResource("breadcrumb")#</b><br>
</cfoutput>
<cfoutput query="qAncestors">
<a href="index.cfm?objectid=#qAncestors.objectid#">#qAncestors.objectName#</a><br>
</cfoutput>
<cfoutput>
</p>
</div>

<div style="padding: 5px;">
<h2>#application.rb.getResource("teaser")#</h2>
<p>#stObj.Teaser#</p>
</div>

<div style="padding: 5px;">
<h2>Body</h2>
#stObj.Body#
</div>

<div style="padding: 5px;">
<cfdump var="#stObj#" label="#application.rb.getResource("completeObjInstance")#" expand="no">
</div>
</cfoutput>

<cfmodule 
	template="/farcry/templates/pagetemplates/greyBuildFooter.cfm"
>

<cfsetting enablecfoutputonly="no">