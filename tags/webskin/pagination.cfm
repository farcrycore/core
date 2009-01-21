<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->

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
<!--- @@displayname: Pagination --->
<!--- @@description: Provides the functionality to paginate through a recordset  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!------------------ 
START WEBSKIN
 ------------------>
<cfif thistag.executionMode eq "Start">
	
	<!--- OPTIONAL ATTRIBUTES --->
	<cfparam name="attributes.query" default="" />
	<cfparam name="attributes.typename" default="" />	
	<cfparam name="attributes.paginationID" default="" /><!--- Keeps track of the page the user is currently on in session against this key. --->
	<cfparam name="attributes.currentPage" default="0" />
	<cfparam name="attributes.actionURL" default="" />
	<cfparam name="attributes.r_stObject" default="stObject" /><!--- The name of the calling page structure that will contain the current row of the recordset as struct --->
	<cfparam name="attributes.totalRecords" default="0" /><!--- The total number of records in the records. Used if only the current page of the recordset was passed in. 0 assumes that the recordset passed in is the entire recordset to be paginated. --->
	<cfparam name="attributes.maxRecordsToDisplay" default="0" type="numeric">
	<cfparam name="attributes.pageLinks" default="10" type="numeric">
	<cfparam name="attributes.recordsPerPage" default="10" type="numeric">
	<cfparam name="attributes.submissionType" default="url" type="string">
	<cfparam name="attributes.Step" default="1" type="numeric">

	<!------------------------------------------------------------------------------------ 
		Check if they have passed in the attribute as the NAME of a query in the caller.
		IF SO, change it to the reference to the calling query.
	 ------------------------------------------------------------------------------------>
	<cfif isSimpleValue(attributes.query) AND len(attributes.query)>
		<cfif structKeyExists(caller, attributes.query)>
			<cfset attributes.query = caller[attributes.query] />
		</cfif>
	</cfif>

	<!--- INITIALISE THE PAGINATION OBJECT WITH ALL THE REQUIRED VALUES BASED ON THE ATTRIBUTES PASSED INTO THIS TAG. --->
	<cfset oPagination = application.fapi.getContentType("farPagination").setup(argumentCollection="#attributes#") />

	<!--- THIS HIDDEN FIELD WILL STORE THE PAGE REQUESTED IF PAGINATING USING A FORM POST --->
	<cfif attributes.submissionType eq "form">
		<cfoutput>
			<input type="hidden" name="paginationpage#attributes.paginationID#" id="paginationpage#Request.farcryForm.Name#" value="" />
		</cfoutput>
	</cfif>
	
	<!--- Render the pagination at the top --->
	<cfset topPagination = oPagination.getView(template="displayLinks", position="top" ) />
	<cfoutput>#topPagination#</cfoutput>
	
	<cfset caller[attributes.r_stObject] = oPagination.getNextRowAsStruct() />
	
	
</cfif>

<cfif thistag.executionMode eq "End">	
	<!--- Check to see if we still have more rows to process --->
	<cfif oPagination.getCurrentRow() LTE oPagination.getRecordTo()>
		
		<cfset caller[attributes.r_stObject] = oPagination.getNextRowAsStruct() />
		
		<cfsetting enablecfoutputonly="false" />
		<cfexit method="loop" />
	<cfelse>
		<!--- After the last record, we render the pagination. --->
		<cfset bottomPagination = oPagination.getView(template="displayLinks", position="bottom" ) />
		<cfoutput>#bottomPagination#</cfoutput>
	</cfif>
	

</cfif>







<cfsetting enablecfoutputonly="false">