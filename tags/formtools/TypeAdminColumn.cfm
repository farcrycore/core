<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/widgets/typeadmincolumn.cfm,v 1.2 2005/07/25 10:52:33 geoff Exp $
$Author: geoff $
$Date: 2005/07/25 10:52:33 $
$Name:  $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: Column definitions for generic administration screen for content types, by typeadmin. $

|| DEVELOPER ||
$Developer: Geoff Bowers (geoff@daemon.com.au)$

|| USAGE ||
<cf_typeadmincolumn
	columntype="expression/evaluate/value" 
	title="Heading"
	value="some value" />

|| ATTRIBUTES ||
-> [columntype]: type of column (required); expression/evaluate/value
-> [title]: Title for the admin.  Defaults to content type component display name.
-> [value]: value to resolve for query cell.
--->

<!--- make sure the tag is within cf_typeadmin --->
<cfset ParentTag = GetBaseTagList()>
<cfif NOT ListFindNoCase(ParentTag, "cf_typeadmin")>
	<cfabort showerror="<strong>Error in cf_typeadmincolumn</strong><br>This tag must be coded within a parent cf_typeadmin tag.">
</cfif>
<!--- make sure tag is correctly implemented --->
<cfif NOT ThisTag.HasEndTag>
	<cfabort showerror="<strong>cf_typeadmincolumn requires a closing tag.</strong><br><b>Usage:</b><br>&lt;cf_typeadmincolumn&gt;&lt;/cf_typeadmincolumn&gt; or &lt;cf_typeadmincolumn /&gt;">
</cfif>

<cfswitch expression="#ThisTag.ExecutionMode#">
<cfcase value="start">
	<!--- required attributes --->
	<cfparam name="attributes.columnType">
	<cfparam name="attributes.value">
	<cfparam name="attributes.title">
	<!--- optional attributes --->
	<cfparam name="attributes.style" default="text-align: left;">
	<cfparam name="attributes.orderby" default="">

</cfcase>

<cfcase value="end">
	<cfassociate basetag="cf_typeadmin" datacollection="aColumns">
</cfcase>
</cfswitch>

<cfsetting enablecfoutputonly="No">
