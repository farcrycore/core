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
$Description:  -- This is a subtag that will loop through all the records from the containing cf_paginate and put each row in a structure and return it too the caller$


|| DEVELOPER ||
$Developer: Matthew Bryant (mat@bcreative.com.au)$

|| ATTRIBUTES ||
$in: r_stRecord -- the name of the structure to return to the caller $
--->




<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.r_stRecord" default="stRecord">
	
	<!--- Get the BaseTagData  --->
	<cfset PaginateData = getBaseTagData("cf_paginate")>
	
	<!--- Append the Attributes from the base tag to this sub tag --->
	<cfset StructAppend(attributes,PaginateData.attributes)>
	

	
	<!--- Put the Current Row of the recordset into a structure and return to caller. --->
	<cfset CurrentRow = PaginateData.StartRecord>

	<cfif CurrentRow GT Attributes.Query.RecordCount>
		<cfexit>
	</cfif>
	
	<cfset stCurrentRecord = StructNew()>
	
	<cfloop list="#Attributes.Query.ColumnList#" index="i">
		<cfset stCurrentRecord[i] = Attributes.Query[i][CurrentRow]>
	</cfloop>

	<cfset CALLER[attributes.r_stRecord] = stCurrentRecord>
	
</cfif>

<cfif thistag.executionMode eq "End">
	
	<cfset CurrentRow = CurrentRow + 1>
	<cfif CurrentRow GT PaginateData.EndRecord>
		<cfexit method="exittag">
	<cfelse>
		
		<!--- Put the Current Row of the recordset into a structure and return to caller. --->		
		<cfset stCurrentRecord = StructNew()>
		
		<cfloop list="#attributes.Query.ColumnList#" index="i">
			<cfset stCurrentRecord[i] = attributes.Query[i][CurrentRow]>
		</cfloop>
	
		<cfset CALLER[attributes.r_stRecord] = stCurrentRecord>
			
		<cfexit method="loop">	
	</cfif>
</cfif>