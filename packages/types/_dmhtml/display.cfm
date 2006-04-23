<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmhtml/display.cfm,v 1.5 2003/12/08 05:28:38 paul Exp $
$Author: paul $
$Date: 2003/12/08 05:28:38 $
$Name: milestone_2-1-2 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: dmHTML default display method  $
$TODO: $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
--->

<cfscript>
	// get navigation elements
	// getChildren for application.navid.home
	qPrimary = request.factory.oTree.getChildren(objectid=application.navid.home);
	qSecondary = request.factory.oTree.getChildren(objectid=request.navid);
	qAncestors = request.factory.oTree.getAncestors(objectid=request.navid);
</cfscript>


<cfsetting enablecfoutputonly="yes">
<cfmodule 
	template="/farcry/templates/pagetemplates/greyBuildHeader.cfm"
	pageTitle="#stObj.title#"
>

<cfoutput>
<div style="padding: 5px; float: right; width: 150px; border: 1px ##333 solid;">
<p>
<b>Primary Nav</b><br>
</cfoutput>
<cfoutput query="qPrimary">
<a href="index.cfm?objectid=#qPrimary.objectid#">#qPrimary.objectName#</a><br>
</cfoutput>
<cfoutput>
</p>
<p>
<b>Secondary Nav</b><br>
</cfoutput>
<cfoutput query="qSecondary">
<a href="index.cfm?objectid=#qSecondary.objectid#">#qSecondary.objectName#</a><br>
</cfoutput>
<cfoutput>
</p>
<p>
<b>Breadcrumb</b><br>
</cfoutput>
<cfoutput query="qAncestors">
<a href="index.cfm?objectid=#qAncestors.objectid#">#qAncestors.objectName#</a><br>
</cfoutput>
<cfoutput>
</p>
</div>

<div style="padding: 5px;">
<h2>Teaser</h2>
<p>#stObj.Teaser#</p>
</div>

<div style="padding: 5px;">
<h2>Body</h2>
#stObj.Body#
</div>

<div style="padding: 5px;">
<cfdump var="#stObj#" label="Complete Object Instance" expand="no">
</div>
</cfoutput>

<cfmodule 
	template="/farcry/templates/pagetemplates/greyBuildFooter.cfm"
>

<cfsetting enablecfoutputonly="no">