<!--- 
|| LEGAL ||
$Copyright: Breathe Creativity 2002-2006, http://www.breathecreativity.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

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