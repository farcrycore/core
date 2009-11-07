<!--- 
 // DEPRECATED
	skin:paginateScroll is no longer in use and will be removed from the code base. 
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
<!--- @@Description:  DEPRECATED!! -- This is a subtag that will add the links to enable the user to scroll through the entire recordset  --->


<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.r_stRecord" default="stRecord">
	
	<!--- deprecated --->
	<cfset application.fapi.deprecated("skin:paginateScroll is no longer in use and will be removed from the code base. Use the skin:pagination tag instead.") />
	
	<cfinclude template="/farcry/core/webtop/includes/utilityFunctions.cfm" >

	
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