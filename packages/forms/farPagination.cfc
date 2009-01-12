<cfcomponent displayname="Pagination" hint="Provides a granular way to paginate a recordset" extends="forms" output="false">



<cffunction name="setup" access="public" output="false" returntype="farPagination" hint="Initialises a farPagination object">
	<cfargument name="qRecordset" default="" hint="The recordset to be paginated" />
	<cfargument name="typename" default="" />	
	<cfargument name="paginationID" default="" /><!--- Keeps track of the page the user is currently on in session against this key. --->
	<cfargument name="currentPage" default="0" />
	<cfargument name="actionURL" default="" />
	<cfargument name="r_stObject" default="stObject" /><!--- The name of the calling page structure that will contain the current row of the recordset as struct --->
	<cfargument name="totalRecords" default="0" /><!--- The total number of records in the records. Used if only the current page of the recordset was passed in. 0 assumes that the recordset passed in is the entire recordset to be paginated. --->
	<cfargument name="maxRecordsToDisplay" default="0" type="numeric">
	<cfargument name="pageLinks" default="10" type="numeric">
	<cfargument name="recordsPerPage" default="10" type="numeric">
	<cfargument name="submissionType" default="url" type="string">
	<cfargument name="Step" default="1" type="numeric">

	
	<!--- SET THE ARGUMENTS AS THE this SCOPE --->
	<cfloop collection="#arguments#" item="i">
		<cfset this[i] = arguments[i] />
	</cfloop>


	
	<!--- SETUP THE RECORDSET --->	
	<cfset setRecordset() />
	
	<!--- SETUP THE ACTION URL --->	
	<cfset setActionURL() />
	
	<!--- DETERMINE THE CURRENT PAGE OF THE RECORDSET --->	
	<cfset setCurrentPage() />

	<!--- SETUP OF PAGINATION INFO AND GENERATES THE LINK INFO STRUCTURE THAT IS PASSED INTO THE DISPLAYLINKS WEBSKIN --->
	<cfset setPageInfo() />
	
		
	<cfreturn this />
	
</cffunction>
	
<cffunction name="getRecordSet" access="public" output="false" returntype="query" hint="Get the start page of the pagination loop">
	<cfreturn this.qRecordset />
</cffunction>
<cffunction name="getPageFrom" access="public" output="false" returntype="numeric" hint="Get the start page of the pagination loop">
	<cfreturn 1 />
</cffunction>
<cffunction name="getPageTo" access="public" output="false" returntype="numeric" hint="Get the end page of the pagination loop">
	<cfreturn arrayLen(this.stLinks.aPages) />
</cffunction>

<cffunction name="getCurrentPage" access="public" output="false" returntype="numeric" hint="Get the current page">
	<cfreturn this.currentPage />
</cffunction>
<cffunction name="getTotalPages" access="public" output="false" returntype="numeric" hint="Get the total number of pages">
	<cfreturn numberFormat(this.totalPages) />
</cffunction>
<cffunction name="getFirstPage" access="public" output="false" returntype="numeric" hint="Get the first page in the pagination loop">
	<cfreturn numberFormat(this.firstPage) />
</cffunction>
<cffunction name="getLastPage" access="public" output="false" returntype="numeric" hint="Get the last page in the pagination loop">
	<cfreturn numberFormat(this.lastPage) />
</cffunction>
	
<cffunction name="getRecordFrom" access="public" output="false" returntype="numeric" hint="Get the first row of the recordset for the current page of the pagination.">
	<cfreturn this.recordFrom />
</cffunction>
<cffunction name="getRecordTo" access="public" output="false" returntype="numeric" hint="Get the last row of the recordset for the current page of the pagination.">
	<cfreturn this.recordTo />
</cffunction>
<cffunction name="getCurrentRow" access="public" output="false" returntype="numeric" hint="Get the current row of the recordset for the current page of the pagination.">
	<cfreturn this.currentRow />
</cffunction>
	
<cffunction name="incrementCurrentRow" access="public" output="false" returntype="void" hint="Increments the current row of the recordset for the current page of the pagination.">
	<cfset this.currentRow = this.currentRow + 1 />
</cffunction>


<cffunction name="getNextRowAsStruct" access="public" returntype="struct" hint="Converts the current row of the recordset to a structure.">
	
	<cfset var stResult = structNew() />
	<cfset var i = "" />
	<cfset var q = getRecordset() />
	<cfset var row = getCurrentRow() />
	
	<cfif row LTE q.recordCount>
		<cfloop list="#q.columnList#" index="i">
			<cfset stResult[i] = q[i][row] />
		</cfloop>
		
		<cfset incrementCurrentRow() />
	<cfelse>
		<cfthrow message="The current row [#row#] is more than the recordCount [#q.recordCount#]."/>
	</cfif>
	
	
	
	<cfreturn stResult />
</cffunction>

<cffunction name="getLink" access="public" output="false" returntype="struct" hint="Get a specific link">
	<cfargument name="linkID" required="true" type="any" hint="Can be either first, last, next, previous or a page number" />
	
	<cfset var stLink = structNew() />
	
	<cfswitch expression="#arguments.linkID#">
	<cfcase value="first">
		<cfset stLink = this.stLinks.stFirst />
	</cfcase>
	<cfcase value="last">
		<cfset stLink = this.stLinks.stLast />
	</cfcase>
	<cfcase value="next">
		<cfset stLink = this.stLinks.stNext />
	</cfcase>
	<cfcase value="previous">
		<cfset stLink = this.stLinks.stPrevious />
	</cfcase>
	<cfdefaultcase>
		<cfif not isNumeric(arguments.linkID)>
			<cfthrow message="The linkID must be either 'first', 'last', 'next', 'previous' or a page number" />
		</cfif>
		
		<cfif arguments.linkID GT 0 AND arguments.linkID LTE arrayLen(this.stLinks.aPages)>
			<cfset stLink = this.stLinks.aPages[arguments.linkID] />
		</cfif>
	</cfdefaultcase>
	</cfswitch>
	
	<cfreturn stLink />
</cffunction>
	

<!--- //////////////////////////////////////////// --->
<cffunction name="setRecordset" access="private" output="false" returntype="void" hint="Setup the recordset">
	
	<cfset var o = "" />
	
	<!--- ENSURE WE HAVE A RECORDSET --->
	<cfif isQuery(this.qRecordset)>
		<!--- ALL OK --->
	<cfelseif len(this.typename)>
		<cfset o = application.fapi.getContentType("#this.typename#") />		
		<cfset this.qRecordSet = o.getMultipleByQuery(OrderBy="datetimecreated desc") />
	<cfelse>
		<cfthrow message="You must initialise pagination with qRecordset (query) or typename (string)." />
	</cfif>
</cffunction>

<cffunction name="setActionURL" access="private" output="false" returntype="void" hint="Setup the Action URL">
	

	<cfset var stURL = "" />
	<cfset var queryString = "" />
		
	<!--- SORT OUT THE ACTION URL --->
	<cfif NOT len(trim(this.actionURL))>
		
		<cfset stURL = Duplicate(url) />
		<cfset stURL = application.fapi.filterStructure(stURL,'Page#this.paginationID#,updateapp') />
		<cfset queryString=application.fapi.structToNamePairs(stURL) />
		
		<cfset this.actionURL = "#cgi.script_name#?#queryString#" />
	
	<cfelse>
	
		<!--- IF THERE IS AN ACTIONURL PASSED, WE'LL APPEND A ? SO 'PAGE' CAN BE APPENDED BY PAGINATION.CFM --->
		<cfif NOT find("?", this.actionURL)>
			<cfset this.actionURL = this.actionURL & "?" />
		</cfif>
	
	</cfif>
</cffunction>



<cffunction name="setCurrentPage" access="private" output="false" returntype="void" hint="Determine the current page of the recordset">
	

	<cfif this.CurrentPage eq 0 or not isNumeric(this.currentPage)>
		<cfif structKeyExists(url,"page#this.paginationID#")>
			<cfset this.CurrentPage = url["page#this.paginationID#"]>
		<cfelseif structKeyExists(form, "paginationpage#this.paginationID#")>
			<cfset this.CurrentPage = form["paginationpage#this.paginationID#"]>		
		</cfif>
	</cfif>
		
	<cfif this.paginationID neq ""> <!--- use session key --->
		<cfparam name="session.ftPagination" default="#structNew()#" />
		<cfif not structKeyExists(session.ftPagination, this.paginationID)>
			<cfset session.ftPagination[this.paginationID] = 1 />
		</cfif>
		

		<cfif this.currentPage GT 0 and isNumeric(this.CurrentPage)>
			<cfset session.ftPagination[this.paginationID] = this.currentPage />
			
			
		<cfelseif session.ftPagination[paginationID] GT 1><!--- use the last url page after leaving master page --->
			<cfset this.CurrentPage = session.ftPagination[this.paginationID]>
		</cfif>	
		
	</cfif>	

	<cfif this.CurrentPage eq 0 or not isNumeric(this.currentPage)>
		<cfset this.CurrentPage = 1>
	</cfif>
	
		
</cffunction>


<cffunction name="setPageInfo" access="private" returntype="void" hint="Generates the Link Info structure that is passed into the displayLinks Webskin">

	<cfset var stPageLink = "" />
	<cfset var i = "" />
	
	<cfset this.totalRecords = this.qRecordset.recordCount />

	<cfset this.totalPages = 1 />
	<cfset this.firstPage = 1 />
	<cfset this.lastPage = 1 />
	

	<cfif this.totalRecords GT this.recordsPerPage>

		<cfset this.totalPages = (this.totalRecords - (this.totalRecords mod this.recordsPerPage)) / this.recordsPerPage />
		<cfif this.totalRecords mod this.recordsPerPage neq 0> 
			<cfset this.totalPages = this.totalPages + 1 />
		</cfif>
					
		<!--- If the current page is more than half way through the linked pages, then shift the first page forward  --->
		<cfset this.firstPage = this.currentPage - round((this.pageLinks - 1)/2) />
		<cfif this.firstPage LT 1> 
			<cfset this.firstPage = 1 />
		</cfif>
		
		<cfset this.lastPage = this.firstPage + this.pageLinks - 1 />

		<cfif this.lastPage GT this.totalPages> 
			<cfset this.lastPage = this.totalPages />
			<cfset this.firstPage = this.totalPages - this.pageLinks + 1 />
		</cfif>
		
		<cfif this.firstPage LT 1> 
			<cfset this.firstPage = 1 />
		</cfif>
		
	
	</cfif>	
	
	<cfif this.currentPage GT this.totalPages>
		<cfset this.currentPage = this.totalPages />
	</cfif>
	
	<!--- Determine the max records to display. Can be a maximum of the recordsPerPage --->
	<cfif this.maxRecordsToDisplay GT this.recordsPerPage>
		<cfset this.maxRecordsToDisplay = this.recordsPerPage />
	</cfif>
		
	<cfif this.maxRecordsToDisplay GT 0>
		<cfif this.maxRecordsToDisplay LT this.totalRecords>
			<cfset this.totalRecords = this.maxRecordsToDisplay />
		</cfif>
	</cfif>
		
	
	<cfset this.recordFrom = this.currentPage * this.recordsPerPage - this.recordsPerPage + 1 />
	<cfset this.recordTo = this.currentPage * this.recordsPerPage />
	<cfif this.recordTo GT this.totalRecords>
		<cfset this.recordTo = this.totalRecords />
	</cfif>
	
	<cfset this.currentRow = this.recordFrom />	

	<!--- SETUP ALL THE LINK INFO --->
	<cfset this.stLinks = structNew() />

	<cfif this.currentPage EQ 1>
		<cfif this.totalPages GT this.pageLinks>
			<cfset setLink(linkID="first", page="1", bDisabled=true) />
		<cfelse>
			<cfset setLink(linkID="first", page="1", bHidden="true") />
		</cfif>
		<cfset setLink(linkID="previous", page="1", bDisabled=true) />
	<cfelse>
		<cfif this.totalPages GT this.pageLinks>
			<cfset setLink(linkID="first", page="1") />
		<cfelse>
			<cfset setLink(linkID="first", page="1", bHidden="true") />
	   	</cfif>
	   	<cfset setLink(linkID="previous", page="#this.currentPage-1#") />
	</cfif>		

	
	<cfloop from="#this.firstPage#" to="#this.lastPage#" index="i">
		<cfif i EQ this.currentPage>
			<cfset setLink(linkID="#i#", page="#i#", bCurrent="true") />
		<cfelse>
			<cfset setLink(linkID="#i#", page="#i#") />
		</cfif>
		
	</cfloop>


	<cfif this.currentPage * this.recordsPerPage LT this.totalRecords>
		<cfset setLink(linkID="next", page="#this.currentPage+1#") />

		<cfif this.totalPages GT this.pageLinks>
			<cfset setLink(linkID="last", page="#this.totalPages#") />
		<cfelse>
			<cfset setLink(linkID="last", page="#this.totalPages#", bHidden="true") />
		</cfif>
	<cfelse>
		<cfset setLink(linkID="next", page="#this.totalRecords#", bDisabled="true") />
		<cfif this.totalPages GT this.pageLinks>
			<cfset setLink(linkID="last", page="#this.totalPages#", bDisabled="true") />
		<cfelse>
			<cfset setLink(linkID="last", page="#this.totalPages#", bHidden="true") />
		</cfif>
	</cfif>

</cffunction>


<cffunction name="setLink" access="private" returntype="void" output="false" hint="Sets up a link keyed by the linkID">
	<cfargument name="linkID" required="true" type="any" hint="Can be either first, last, next, previous or a page number" />
	<cfargument name="page" default="0" />
	<cfargument name="bHidden" default="false" hint="Hiding a link means that it should not be rendered because it is not required." />
	<cfargument name="bDisabled" default="false" hint="If a link is disabled, it means that it should be rendered but no link link attached because we are currently on the page it links too." />
	<cfargument name="bCurrent" default="false" hint="If a link is current, it means that it should be rendered, HIGHLIGHTED, but no link link attached because we are currently on the page it links too." />
	
	<cfset stLink = structNew() />
	
	<cfparam name="this.stLinks" default="#structNew()#" />
	<cfparam name="this.stLinks.aPages" default="#arrayNew(1)#" />
	
	
	<!--- IF ARGUMENTS.PAGE EQ 0 IT MEANS THE LINK IS NOT USED AND SO WE RETURN AN EMPTY STRUCT --->
	<cfif arguments.page NEQ 0>
		<cfif isNumeric(arguments.linkID)>
			<cfset stLink.defaultLinktext = numberFormat(linkID) />
		<cfelse>
			<cfset stLink.defaultLinktext = application.fapi.getResource(key="pagination.#arguments.linkID#@text", default="#UCase(arguments.linkID)#") />
		</cfif>
		
		<cfset stLink.class = "" />
	
		<cfset stLink.bHidden = arguments.bHidden />
		<cfset stLink.bCurrent = arguments.bCurrent />
		<cfif arguments.bCurrent>
			<cfset stLink.bDisabled = true />
			<cfset stLink.class = listAppend(stLink.class, "p-current", " ") />
		<cfelse>
			<cfset stLink.bDisabled = arguments.bDisabled />
		</cfif>
		<cfset stLink.page = arguments.page />
		<cfset stLink.href = getPaginationLinkHREF(arguments.page) />
		<cfset stLink.onclick = getPaginationLinkOnClick(arguments.page) />

	</cfif>
	

	<cfswitch expression="#arguments.linkID#">
	<cfcase value="first">
		<cfset stLink.class = listAppend(stLink.class, "p-first", " ") />
		<cfset this.stLinks.stFirst = stLink />
	</cfcase>
	<cfcase value="last">
		<cfset stLink.class = listAppend(stLink.class, "p-last", " ") />
		<cfset this.stLinks.stLast = stLink />
	</cfcase>
	<cfcase value="next">
		<cfset stLink.class = listAppend(stLink.class, "p-next", " ") />
		<cfset this.stLinks.stNext = stLink />
	</cfcase>
	<cfcase value="previous">
		<cfset stLink.class = listAppend(stLink.class, "p-previous", " ") />
		<cfset this.stLinks.stPrevious = stLink />
	</cfcase>
	<cfdefaultcase>
		<cfif not isNumeric(arguments.linkID)>
			<cfthrow message="The linkID must be either 'first', 'last', 'next', 'previous' or a page number" />
		</cfif>
		
		<cfset stLink.class = listAppend(stLink.class, "p-link", " ") />
		
		<cfset arrayAppend(this.stLinks.aPages, stLink)>
		
	</cfdefaultcase>
	</cfswitch>	

</cffunction>


<cffunction name="getPaginationLinkOnClick" access="private" output="false" returntype="string" hint="Returns the javascript onclick string for the pagination Link">
	<cfargument name="page" required="true" />
	
	<cfset var result = "" />

	<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
	
	
	<!--- ENSURE WE ARE DOING A FORM SUBMISSION AND THAT WE ARE CURRENTLY IN THE MIDDLE OF AN FT:FORM --->
	<cfif this.submissionType eq "form" and structKeyExists(Request, "farcryForm") and not structIsEmpty(request.farcryForm)>
		<skin:htmlHead library="ExtCoreJS" />
		
		<skin:htmlHead id="pageSubmitJS">
		<cfoutput>
		<script type="text/javascript">
		farcryps = function(page,formname,type,actionURL){
			if(type=='form'){					
				Ext.get(formname).dom.submit();
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
	
	
		<cfset result = "Ext.get('paginationpage#Request.farcryForm.Name#').dom.value=#arguments.page#;#Request.farcryForm.onSubmit#;return farcryps(arguments.page,'#Request.farcryForm.Name#','#this.submissionType#','#this.actionURL#');" />
	</cfif>
	
	<cfreturn result />
</cffunction>

<cffunction name="getPaginationLinkHREF" access="private" output="false" returntype="string" hint="Returns the HREF for the pagination Link">
	<cfargument name="page" required="true" />
	
	<cfset var result = "#this.actionURL#&amp;page#this.paginationID#=#arguments.page#" />
	
	<cfreturn result />
</cffunction>	



	
	
</cfcomponent>