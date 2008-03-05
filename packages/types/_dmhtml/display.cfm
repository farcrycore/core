<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

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