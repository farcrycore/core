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
	<cfparam name="attributes.query" default="" /><!--- A query name that contains the objectids to loop over. --->
	<cfparam name="attributes.array" default="" /><!--- An array of objectids to loop over. Can be used instead of query. --->
	<cfparam name="attributes.typename" default="" />	
	<cfparam name="attributes.paginationID" default="fcPagination" /><!--- Uniquely identifies this pagination set. Set if using sticky pages or if multiple pagination sets on a single page. --->
	<cfparam name="attributes.bStickyPages" default="false" /><!--- Keeps track of the page the user is currently on in session against this key. --->
	<cfparam name="attributes.currentPage" default="0" />
	<cfparam name="attributes.actionURL" default="" />
	<cfparam name="attributes.r_stObject" default="stObject" /><!--- The name of the calling page structure that will contain the current row of the recordset as struct --->
	<cfparam name="attributes.totalRecords" default="0" /><!--- The total number of records in the records. Used if only the current page of the recordset was passed in. 0 assumes that the recordset passed in is the entire recordset to be paginated. --->
	<cfparam name="attributes.maxRecordsToDisplay" default="0" type="numeric">
	<cfparam name="attributes.pageLinks" default="10" type="numeric">
	<cfparam name="attributes.recordsPerPage" default="10" type="numeric">
	<cfparam name="attributes.submissionType" default="url" type="string">
	<cfparam name="attributes.Step" default="1" type="numeric">
	<cfparam name="attributes.top" default="true" type="boolean">
	<cfparam name="attributes.bottom" default="true" type="boolean">	
	<cfparam name="attributes.oddRowClass" default="oddrow" type="string"><!--- The class name returned in stobjects for each "even" current row --->
	<cfparam name="attributes.evenRowClass" default="evenrow" type="string"><!--- The class name returned in stobjects for each "odd" current row --->
	

	<!------------------------------------------------------------------------------------ 
		Check if they have passed in the attribute as the NAME of a query/array in the caller.
		IF SO, change it to the reference to the calling query/array.
	 ------------------------------------------------------------------------------------>
	<cfif isSimpleValue(attributes.query) AND len(attributes.query)>
		<cfif structKeyExists(caller, attributes.query)>
			<cfset attributes.query = caller[attributes.query] />
		</cfif>
	</cfif>
	<cfif isSimpleValue(attributes.array) AND len(attributes.array)>
		<cfif structKeyExists(caller, attributes.array)>
			<cfset attributes.array = caller[attributes.array] />
		</cfif>
	</cfif>

	<!--- INITIALISE THE PAGINATION OBJECT WITH ALL THE REQUIRED VALUES BASED ON THE ATTRIBUTES PASSED INTO THIS TAG. --->
	<cfset oPagination = application.fapi.getContentType("farPagination").setup(argumentCollection="#attributes#") />

	<!--- THIS HIDDEN FIELD WILL STORE THE PAGE REQUESTED IF PAGINATING USING A FORM POST --->
	<cfif attributes.submissionType eq "form">
	
		<skin:loadJS id="jquery" />	
		<skin:loadJS id="farcry-form" />
		
		<skin:htmlHead id="pageSubmitJS">
		<cfoutput>
		<script type="text/javascript">
		farcryps = function(page,formname,type,actionURL){
			if(type=='form'){	
				btnSubmit(formname, ''); //submit farcryform but ensure no actions are taken.	
				return false;
			} else if(type=='url'){
				window.location = actionURL + '&page=' + page;
				return false;
			} else {
				return true;
			}				
		}	
		</script>
		</cfoutput>
		</skin:htmlHead>
						
		<cfoutput>
			<input type="hidden" name="paginationpage#attributes.paginationID#" id="paginationpage#Request.farcryForm.Name#" value="" />
		</cfoutput>
	</cfif>
	
	<!--- Render the pagination at the top --->
	<cfif attributes.top>
		<cfset topPagination = oPagination.getView(template="displayLinks", position="top" ) />
		<cfoutput>#topPagination#</cfoutput>
	</cfif>
	
	<!--- CHECK TO ENSURE THERE ARE ACTUALLY RECORDS TO LOOP THROUGH --->
	<cfif oPagination.getCurrentRow() LTE oPagination.getRecordTo()>
		<cfset currentRow = 1 />
		<cfset recordCount = oPagination.getRecordTo() - oPagination.getCurrentRow() + 1 />
		<cfset recordsetRow = oPagination.getCurrentRow() />
		<cfset recordsetCount = oPagination.getTotalRecords() />
		<cfset caller[attributes.r_stObject] = oPagination.getNextRowAsStruct() />
		<cfset caller[attributes.r_stObject].currentRow = currentRow />
		<cfset caller[attributes.r_stObject].recordCount = recordCount />
		<cfset caller[attributes.r_stObject].recordsetRow = recordsetRow />
		<cfset caller[attributes.r_stObject].recordsetCount = recordsetCount />
		<cfif currentRow mod 2>
			<cfset caller[attributes.r_stObject].currentRowClass = attributes.oddRowClass />
		<cfelse>
			<cfset caller[attributes.r_stObject].currentRowClass = attributes.evenRowClass />
		</cfif>
		<cfif currentRow EQ 1>
			<cfset caller[attributes.r_stObject].bFirst = true />
		<cfelse>
			<cfset caller[attributes.r_stObject].bFirst = false />
		</cfif>
		<cfif currentRow EQ recordCount>
			<cfset caller[attributes.r_stObject].bLast = true />
		<cfelse>
			<cfset caller[attributes.r_stObject].bLast = false />
		</cfif>
	<cfelse>
		<!--- MEANS THERE WERE NO RECORDS SO SIMPLY CALL THE BOTTOM --->
		<cfif attributes.bottom>
			<cfset bottomPagination = oPagination.getView(template="displayLinks", position="bottom" ) />
			<cfoutput>#bottomPagination#</cfoutput>
		</cfif>	
		<cfexit method="exittag" />
	</cfif>
	
</cfif>

<cfif thistag.executionMode eq "End">
	
	<!--- Check to see if we still have more rows to process --->
	<cfif oPagination.getCurrentRow() LTE oPagination.getRecordTo()>
		
		<cfset currentRow = currentRow + 1 />
		<cfset recordsetRow = oPagination.getCurrentRow() />
		
		<cfset caller[attributes.r_stObject] = oPagination.getNextRowAsStruct() />
		<cfset caller[attributes.r_stObject].currentRow = currentRow />
		<cfset caller[attributes.r_stObject].recordCount = recordCount />
		<cfset caller[attributes.r_stObject].recordsetRow = recordsetRow />
		<cfset caller[attributes.r_stObject].recordsetCount = recordsetCount />
		<cfif currentRow mod 2>
			<cfset caller[attributes.r_stObject].currentRowClass = attributes.oddRowClass />
		<cfelse>
			<cfset caller[attributes.r_stObject].currentRowClass = attributes.evenRowClass />
		</cfif>
		<cfif currentRow EQ 1>
			<cfset caller[attributes.r_stObject].bFirst = true />
		<cfelse>
			<cfset caller[attributes.r_stObject].bFirst = false />
		</cfif>
		<cfif currentRow EQ recordCount>
			<cfset caller[attributes.r_stObject].bLast = true />
		<cfelse>
			<cfset caller[attributes.r_stObject].bLast = false />
		</cfif>
		
		<cfsetting enablecfoutputonly="false" />
		<cfexit method="loop" />
	<cfelse>
		<!--- After the last record, we render the pagination. --->
		<cfif attributes.bottom>
			<cfset bottomPagination = oPagination.getView(template="displayLinks", position="bottom" ) />
			<cfoutput>#bottomPagination#</cfoutput>
		</cfif>
	</cfif>
	

</cfif>







<cfsetting enablecfoutputonly="false">