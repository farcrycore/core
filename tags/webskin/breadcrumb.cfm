<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/webskin/breadcrumb.cfm,v 1.12 2003/06/06 02:39:04 brendan Exp $
$Author: brendan $
$Date: 2003/06/06 02:39:04 $
$Name: b131 $
$Revision: 1.12 $

|| DESCRIPTION || 
builds a breadcrumb for the page

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: - separator (shown between levels)
	- here (title of page)
	- objectid (id of last item in breadcrumb trail)
	- startLevel (nLevel to show from)
	- linkClass (css class for links)
out:
--->

<cfsetting enablecfoutputonly="Yes">
<cfimport taglib="/farcry/farcry_core/tags/webskin" prefix="skin">

<cfparam name="attributes.separator" default="&raquo;">
<cfparam name="attributes.here" default="here">
<cfparam name="attributes.linkClass" default="">
<cfif structKeyExists(request,"navid")>
	<cfparam name="attributes.objectid" default="#request.navid#">
</cfif>
<cfparam name="attributes.startLevel" default="1">
<cfparam name="attributes.prefix" default="">
<cfparam name="attributes.suffix" default="">
<cfparam name="attributes.includeSelf" default="0">

<cfscript>
// get navigation elements
	o = createObject("component", "#application.packagepath#.farcry.tree");
	qAncestors = o.getAncestors(objectid=attributes.objectid);
</cfscript>

<cfif attributes.includeSelf>
	<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
	<q4:contentobjectget objectId="#attributes.objectId#" r_stObject="stSelf">
</cfif>

<!--- check to see we are not displaying a page under something other than home --->
<cfif valueList(qAncestors.objectid) CONTAINS application.navid.home>

	<!--- order and remove application root --->
	<cfquery dbtype="query" name="qCrumb">
		SELECT * FROM qAncestors
		WHERE nLevel >= #attributes.startLevel#
		ORDER BY nLevel
	</cfquery>
	
	<!--- output prefix HTML --->
	<cfoutput>#attributes.prefix#</cfoutput>
	
	<!--- output breadcrumb --->
	<cfloop query="qCrumb">
		<skin:buildlink objectid="#qCrumb.objectid#" class="#attributes.linkClass#"><cfoutput>#qCrumb.objectName#</cfoutput></skin:buildLink><cfoutput> #attributes.separator# </cfoutput>
	</cfloop>
	<cfif attributes.includeSelf>
		<skin:buildlink objectid="#attributes.objectid#" class="#attributes.linkClass#"><cfoutput>#stSelf.title#</cfoutput></skin:buildLink><cfoutput> #attributes.separator# </cfoutput>
	</cfif>
<cfelse>
	<!--- output home only --->
	<cfoutput>#attributes.prefix# <a href="#application.url.webroot#" class="#attributes.linkClass#">Home</a> #attributes.separator# </cfoutput>

</cfif>

<cfoutput>#attributes.here#</cfoutput>

<!--- output suffix HTML --->
<cfoutput>#attributes.suffix#</cfoutput>

<cfsetting enablecfoutputonly="No">