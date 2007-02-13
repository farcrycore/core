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
$Description:  -- This is a subtag that will add the links to enable the user to scroll through the entire recordset $


|| DEVELOPER ||
$Developer: Matthew Bryant (mat@bcreative.com.au)$

|| ATTRIBUTES ||
$in:  $
--->






<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.r_stRecord" default="stRecord">
	
	
	<cfinclude template="/farcry/core/admin/includes/utilityFunctions.cfm" >

	
	<!--- Get the BaseTagData  --->
	<cfset PaginateData = getBaseTagData("cf_paginate")>
	
	<!--- Append the Attributes from the base tag to this sub tag --->
	<cfset StructAppend(attributes,PaginateData.attributes)>
	
	<cfscript>
		stURL = Duplicate(url);
		stURL = filterStructure(stURL,'Page');
		queryString=structToNamePairs(stURL);
	</cfscript>

	<cfoutput>
	<div class="pagination">

		<div class="pages">
			Page 
			<cfif PaginateData.TotalPages GT 1>
				<select name="page" style="width:45px;" onchange="javascript:window.location = '#cgi.SCRIPT_NAME#?#queryString#&page=' + this.value;">
					<cfloop from="1" to="#PaginateData.TotalPages#" index="i">
						<option value="#i#" <cfif url.page EQ i>selected</cfif> >#i#</option>
					</cfloop>
				</select>
			<cfelse>
				#PaginateData.TotalPages#
			</cfif>
			of #PaginateData.TotalPages#
		</div>
						
		<div class="pagelinks">
			
			<cfif url.page EQ 1>
				<cfif PaginateData.TotalPages GT Attributes.PageLinksShown>
			   		<span>First Page</span> 
				</cfif>
				<span>Prev Page</span> 
			<cfelse>
				<cfif PaginateData.TotalPages GT Attributes.PageLinksShown>
					<a href="#cgi.SCRIPT_NAME#?#queryString#&page=1"><strong>First Page</strong></a>
			   	</cfif>
			   	<a href="#cgi.SCRIPT_NAME#?#queryString#&page=#url.page-1#"><strong>Prev Page</strong></a>
			</cfif>
		
			<cfloop from="#PaginateData.StartPage#" to="#PaginateData.EndPage#" index="i">
			    <cfif url.page EQ i>
			       <span>#i#</span>
			   <cfelse>
			       <a href="#cgi.SCRIPT_NAME#?#queryString#&page=#i#">#i#</a>
			    </cfif>
			</cfloop>
		
		
			<cfif url.page * Attributes.RecordsPerPage LT PaginateData.GetCount.records>
			   <a href="#cgi.SCRIPT_NAME#?#queryString#&page=#url.page+1#"><strong>Next Page</strong></a>
			   <cfif PaginateData.TotalPages GT Attributes.PageLinksShown>
			   		<a href="#cgi.SCRIPT_NAME#?#queryString#&page=#PaginateData.TotalPages#"><strong>Last Page</strong></a>
			   	</cfif>
			<cfelse>
			   <span>Next Page</span>
				<cfif PaginateData.TotalPages GT Attributes.PageLinksShown>
			   		<span>Last Page</span>
			   	</cfif>
			</cfif>
			
								 
		</div>
		

	</div>
	</cfoutput>
	
</cfif>

<cfif thistag.executionMode eq "End">
	

</cfif>