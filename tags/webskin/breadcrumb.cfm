<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/webskin/breadcrumb.cfm,v 1.18 2004/04/12 12:10:50 brendan Exp $
$Author: brendan $
$Date: 2004/04/12 12:10:50 $
$Name: milestone_2-2-1 $
$Revision: 1.18 $

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

<cfparam name="attributes.separator" default=" &raquo; ">
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
	qAncestors = request.factory.oTree.getAncestors(objectid=attributes.objectid);
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
		<skin:buildLink objectid="#qCrumb.objectid#" class="#attributes.linkClass#"><cfoutput>#trim(qCrumb.objectName)#</cfoutput></skin:buildLink><cfoutput>#attributes.separator#</cfoutput>
	</cfloop>
	<cfif attributes.includeSelf>
		<skin:buildLink objectid="#attributes.objectid#" class="#attributes.linkClass#"><cfoutput>#stSelf.title#</cfoutput></skin:buildLink><cfoutput>#attributes.separator#</cfoutput>
	</cfif>
<cfelse>
	<!--- output home only --->
	<cfoutput>#attributes.prefix# <a href="#application.url.webroot#/" class="#attributes.linkClass#">Home</a>#attributes.separator#</cfoutput>

</cfif>

<cfoutput>#attributes.here#</cfoutput>

<!--- output suffix HTML --->
<cfoutput>#attributes.suffix#</cfoutput>

<cfsetting enablecfoutputonly="No">