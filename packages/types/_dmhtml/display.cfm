<!--------------------------------------------------------------------
dmHTML
default display method 
--------------------------------------------------------------------->
<cfscript>
// get navigation elements
	o = createObject("component", "fourq.utils.tree.tree");
	// getChildren for application.navid.home
	qPrimary = o.getChildren(objectid=application.navid.home);
	qSecondary = o.getChildren(objectid=request.navid);
	qAncestors = o.getAncestors(objectid=request.navid);
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