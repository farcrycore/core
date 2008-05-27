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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header:  $
$Author: $
$Date:  $
$Name:  $
$Revision: $

|| DESCRIPTION || 
$Description:  -- Helps to construct a table that allows pagination to loop through pages of the recordset$


|| DEVELOPER ||
$Developer: Matthew Bryant (mat@bcreative.com.au)$

|| ATTRIBUTES ||
$in: PageLinksShown -- The number of page links in the pagination. ie, if there are going to be 100 pages, only show links to 10 at a time. The current page is centred so that links to 5 pages either side of the current will be displayed$
$in: RecordsPerPage -- The number of records to be displayed on each page $
$in: Recordset -- The recordset that is going to be paginated (if that's a real word) $
--->


<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.paramname" default="">


</cfif>

<cfif thistag.executionMode eq "End">

</cfif>

<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.PageLinksShown" default="5">
	<cfparam name="attributes.RecordsPerPage" default="10">
	<cfparam name="attributes.Query" type="query">
	

	<cfparam name="url.page" default="1">

	
	<cfquery dbtype="query" name="GetCount">
	SELECT COUNT(objectid) AS records FROM attributes.Query
	</cfquery>
	

	<cfif isNumeric(GetCount.Records)>
		<cfset TotalPages = ceiling(GetCount.records / attributes.RecordsPerPage)>
	<cfelse>
		<cfset TotalPages = 0>
	</cfif>
	
	
	<cfif url.Page GT TotalPages>
		<cfset url.Page = 1>
		<cfset StartRecord = url.page * attributes.RecordsPerPage - attributes.RecordsPerPage + 1>
		<cfset EndRecord = StartRecord + attributes.RecordsPerPage - 1>
	<cfelse>
		<cfset StartRecord = url.page * attributes.RecordsPerPage - attributes.RecordsPerPage + 1>
		<cfset EndRecord = StartRecord + attributes.RecordsPerPage - 1>
	</cfif>
	<cfif EndRecord GT GetCount.Records>
		<cfset EndRecord = GetCount.Records>
	</cfif>
	
	<cfset Startpage = 1>
	<cfset ShowPages = min(attributes.PageLinksShown,TotalPages)>

	<cfif url.page + int(ShowPages / 2) - 1 GTE TotalPages>
		<cfset StartPage = TotalPages - ShowPages + 1>
	<cfelseif url.page + 1 GT ShowPages>
		<cfset StartPage = url.page - int(ShowPages / 2)>
	</cfif>
	
	<cfset Endpage = StartPage + ShowPages - 1>

	
	<cfset CALLER.StartRow = StartRecord>
	<cfset CALLER.EndRow = StartRecord + Attributes.RecordsPerPage -1>


	

	

	
</cfif>

<cfif thistag.executionMode eq "End">


</cfif>