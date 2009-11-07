<!--- 
 // DEPRECATED
	skin:paginateAllRecords is no longer in use and will be removed from the code base. 
	You should be using the skin:pagination tag instead.
--------------------------------------------------------------------------------------------------->

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
<!--- @@Description:  DEPRECATED!! -- This is a subtag that will loop through all the records from the containing cf_paginate and put each row in a structure and return it too the caller --->
<!---
|| ATTRIBUTES ||
$in: r_stRecord -- the name of the structure to return to the caller $
--->


<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.r_stRecord" default="stRecord">
	<!--- deprecated --->
	<cfset application.fapi.deprecated("skin:paginateAllRecords is no longer in use and will be removed from the code base. Use the skin:pagination tag instead.") />
	
	<!--- Get the BaseTagData  --->
	<cfset PaginateData = getBaseTagData("cf_paginate")>
	
	<!--- Append the Attributes from the base tag to this sub tag --->
	<cfset StructAppend(attributes,PaginateData.attributes)>
	
	<!--- Put the Current Row of the recordset into a structure and return to caller. --->
	<cfset CurrentRow = PaginateData.StartRecord>


	<cfset stCurrentRecord = StructNew()>
	
	<cfloop list="#PaginateData.qPageRecords.ColumnList#" index="i">
		<cfset stCurrentRecord[i] = PaginateData.qPageRecords[i][CurrentRow]>
	</cfloop>

	<cfset CALLER[attributes.r_stRecord] = stCurrentRecord>
	
</cfif>

<cfif thistag.executionMode eq "End">
	
	<cfset CurrentRow = CurrentRow + 1>
	<cfif CurrentRow GT attributes.RecordsPerPage OR CurrentRow GT PaginateData.GetCount.Records>
		<cfexit method="exittag">
	<cfelse>
		
		<!--- Put the Current Row of the recordset into a structure and return to caller. --->		
		<cfset stCurrentRecord = StructNew()>
		
		<cfloop list="#PaginateData.qPageRecords.ColumnList#" index="i">
			<cfset stCurrentRecord[i] = PaginateData.qPageRecords[i][CurrentRow]>
		</cfloop>
	
		<cfset CALLER[attributes.r_stRecord] = stCurrentRecord>
			
		<cfexit method="loop">	
	</cfif>
</cfif>