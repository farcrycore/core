<cfsetting enablecfoutputonly="Yes">

<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
<farcry:deprecated message="widgets tag library is deprecated; please use formtools." />

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
$Header: /cvs/farcry/core/tags/widgets/typeadmincolumn.cfm,v 1.2 2005/07/25 10:52:33 geoff Exp $
$Author: geoff $
$Date: 2005/07/25 10:52:33 $
$Name: milestone_3-0-1 $
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
