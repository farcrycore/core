<!--- 
breadcrumb tag
 - builds a breadcrumb for the page

Environment
request.navid

-> separator
-> here
--->

<cfsetting enablecfoutputonly="Yes">

<cfparam name="attributes.separator" default="&raquo;">
<cfparam name="attributes.here" default="here">

<cfscript>
// get navigation elements
	o = createObject("component", "fourq.utils.tree.tree");
	qAncestors = o.getAncestors(objectid=request.navid);
</cfscript>

<!--- check to see we are not displaying a page under something other than home --->
<cfif valueList(qAncestors.objectid) CONTAINS application.navid.home>

<!--- order and remove application root --->
<cfquery dbtype="query" name="qCrumb">
SELECT * FROM qAncestors
WHERE nLevel > 0
ORDER BY nLevel
</cfquery>

<!--- output breadcrumb --->
<cfoutput query="qCrumb">
<a href="index.cfm?objectid=#qCrumb.objectid#">#qCrumb.objectName#</a> #attributes.separator# 
</cfoutput>

<cfelse>
<!--- output home only --->
<cfoutput>
<a href="index.cfm?objectid=#application.navid.home#">Home</a> #attributes.separator# 
</cfoutput>

</cfif>

<cfoutput>#attributes.here#</cfoutput>
<cfsetting enablecfoutputonly="No">