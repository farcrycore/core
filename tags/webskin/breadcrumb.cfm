<cfsetting enablecfoutputonly="Yes">

<cfsilent>
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/webskin/breadcrumb.cfm,v 1.18.6.2 2006/01/20 01:23:48 gstewart Exp $
$Author: gstewart $
$Date: 2006/01/20 01:23:48 $
$Name: milestone_3-0-1 $
$Revision: 1.18.6.2 $

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
<!--- import tag library --->
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin">

<!--- allow developers to close custom tag by exiting on end --->
<cfif thistag.ExecutionMode eq "end">
	<cfsetting enablecfoutputonly="false" />
	<cfexit method="exittag" />
</cfif>

<!--- optional attributes --->
<cfparam name="attributes.separator" default=" &raquo; "><!--- @@attrhint: The separator for the steps in the bread crumb.  Can be a snippet of html (an image tag for example) --->
<cfparam name="attributes.here" default=""><!--- @@attrhint: set the text for the last item in the breadcrumb --->
<cfparam name="attributes.linkClass" default="">
<cfif structKeyExists(request,"navid")>
	<cfparam name="attributes.objectid" default="#request.navid#"><!--- @@attrhint: This sets the starting point of the bread crumb tail.  This is the attribute you are looking for.  This must be a UUID of an element in the tree. To start this off, you can set an alias in the tree (for example 'mystuff') and then assign the alias uuid using something like application.navid['mystuff']. The default for this is request.navid --->
</cfif>
<cfparam name="attributes.startLevel" default="1">
<cfparam name="attributes.prefix" default="">
<cfparam name="attributes.suffix" default="">
<cfparam name="attributes.includeSelf" default="0"><!--- @@attrhint: include the current item in the bread crumb trail --->
<cfparam name="attributes.linkSelf" default="true"><!--- @@attrhint: should this item be a link in the bread crumb @@options: true,false --->
<cfparam name="attributes.homeNavID" default="#application.navid.home#"><!--- @@attrhint: the objectId of the starting element of the breadcrumb. This UUID should be of one of the items in the navigation tree. For example, if you were to set an alias of a navigation you could set this value like: application.navid['myalias']. The default is application.navid.home.  --->

<cfscript>
// get navigation elements
	qAncestors = application.factory.oTree.getAncestors(objectid=attributes.objectid);
</cfscript>

<cfif attributes.includeSelf>
	<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
	<q4:contentobjectget objectId="#attributes.objectId#" r_stObject="stSelf">
</cfif>

<!--- check to see we are not displaying a page under something other than home --->
</cfsilent><cfif valueList(qAncestors.objectid) CONTAINS attributes.homeNavID><cfsilent>
	<!--- order and remove application root --->
	<cfquery dbtype="query" name="qCrumb">
		SELECT * FROM qAncestors
		WHERE nLevel >= #attributes.startLevel#
		ORDER BY nLevel
	</cfquery>
	
	</cfsilent>
	<!--- output prefix HTML --->
	<cfoutput>#attributes.prefix#</cfoutput><cfsilent>
		
	<!--- output breadcrumb --->
	<cfset iCount = 1>
	</cfsilent>
	<cfloop query="qCrumb">
		<cfoutput><skin:buildLink objectid="#qCrumb.objectid#" class="#attributes.linkClass#" /><cfif iCount neq qCrumb.recordCount>#attributes.separator#</cfif></cfoutput>
		<cfsilent><cfset iCount = iCount + 1></cfsilent>
	</cfloop>
	<cfif attributes.includeSelf>
		<cfif qCrumb.recordCount><cfoutput>#attributes.separator#</cfoutput></cfif>
		<cfif attributes.linkSelf>
			<skin:buildLink objectid="#attributes.objectid#" class="#attributes.linkClass#"><cfoutput>#stSelf.title#</cfoutput></skin:buildLink>
		<cfelse>
			<cfoutput>#stSelf.title#</cfoutput>
		</cfif>		
	</cfif>
	<cfif len(attributes.here)>
		<cfoutput>#attributes.separator##attributes.here#</cfoutput>
	</cfif>
<cfelse>
	<!--- output home only --->
	<cfoutput>#attributes.prefix# <skin:buildLink objectid="#application.navid.home#" class="#attributes.linkClass#" /></cfoutput>
	<!--- #FC-611 if calling page is including itself, display page linked title --->
	<cfif attributes.includeSelf>
		<cfoutput>#attributes.separator#</cfoutput>
		<cfif attributes.linkSelf>
			<skin:buildLink objectid="#attributes.objectid#" class="#attributes.linkClass#"><cfoutput>#stSelf.title#</cfoutput></skin:buildLink>
		<cfelse>
			<cfoutput>#stSelf.title#</cfoutput>
		</cfif>
	</cfif>
	<!--- #FC-611 if calling page is including 'here', display value of attributes.here, no link --->
	<cfif len(attributes.here)>
		<cfoutput>#attributes.separator##attributes.here#</cfoutput>
	</cfif>
</cfif>

<!--- output suffix HTML --->
<cfoutput>#attributes.suffix#</cfoutput>

<cfsetting enablecfoutputonly="No">
