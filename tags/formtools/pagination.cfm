
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

|| Syntax Sample 
<cf_pagination 
		totalRecords = "100"
		currentPage="2"
		pageLinks="8"
		recordsPerPage="10" />

|| DEVELOPER ||
$Developer: Matthew Bryant (mat@bcreative.com.au)$

|| ATTRIBUTES ||
$in:  $
--->



<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >


<cfif thistag.executionMode eq "Start">

	<!--- optional attributes --->
	<cfparam name="attributes.Step" default="1" type="numeric">
	<cfparam name="attributes.Top" default="true">
	<cfparam name="attributes.Bottom" default="true">
	<cfparam name="attributes.htmlFirst" default="&laquo;">
	<cfparam name="attributes.htmlPrevious" default="&lt;">
	<cfparam name="attributes.htmlNext" default="&gt;">
	<cfparam name="attributes.htmlLast" default="&raquo;">
	<cfparam name="attributes.bShowResultTotal" default="true" type="boolean" />
	<cfparam name="attributes.bShowPageDropdown" default="true" type="boolean" />
	<cfparam name="attributes.paginationID" default="" />	
	<cfparam name="attributes.CurrentPage" default="0" />
	<cfparam name="attributes.maxPages" default="0" type="numeric">
	<cfparam name="attributes.totalRecords" default="0" type="numeric">
	<cfparam name="attributes.pageLinks" default="0" type="numeric">
	<cfparam name="attributes.recordsPerPage" default="1" type="numeric">
	<cfparam name="attributes.submissionType" default="url" type="string">
	<cfparam name="attributes.actionURL" default="#cgi.SCRIPT_NAME#" type="string">
	
	<cfif not isDefined("attributes.qRecordSet") or not isQuery(attributes.qRecordSet)>
		<cfabort showerror="you must pass a recordset into pagination." />
	</cfif>
	<cfif not isDefined("attributes.typename") or not len(attributes.typename)>
		<cfabort showerror="you must pass a typename into pagination." />
	</cfif>

	<!--- import function libraries --->
	<cfinclude template="/farcry/core/admin/includes/utilityFunctions.cfm" >
	<cfset oFormtoolUtil = createObject("component", "farcry.core.packages.farcry.formtools") />
	
	<cfset attributes.currentPage = oFormtoolUtil.getCurrentPaginationPage(paginationID=attributes.paginationID, currentPage=attributes.currentPage) />

	<cfif attributes.totalRecords GT attributes.qRecordSet.recordCount>
		<!--- This means we have passed in only the page of recordset information we need for rendering --->
		<cfset attributes.startRow = 1 />
		<cfset attributes.endRow = attributes.recordsPerPage />
		<cfif attributes.endRow GT attributes.qRecordSet.recordcount>
			<cfset attributes.endRow = attributes.qRecordSet.recordcount />
		</cfif>
			
	<cfelse>
		<!--- This means that we have passed in an entire recordset and not just the page of relevent data --->
		<cfset attributes.totalRecords = attributes.qRecordSet.recordCount />
		<cfset attributes.startRow = attributes.currentPage * attributes.recordsPerPage - attributes.recordsPerPage + 1 />
		<cfif attributes.StartRow GT attributes.totalRecords>
			<cfset attributes.startRow = 1 />
		</cfif>
		
		<cfset attributes.endRow = attributes.currentPage * attributes.recordsPerPage />
		<cfif attributes.endRow GT attributes.qRecordSet.recordcount>
			<cfset attributes.endRow = attributes.qRecordSet.recordcount />
		</cfif>
	</cfif>
	
	<cfscript>
		bShowPaginate = true;
		bShowDropDown = true;
		if(attributes.totalRecords LTE attributes.recordsPerPage){
			bShowPaginate = false;
		}
		
		if(bShowPaginate){
			pTotalPages = (attributes.totalRecords - (attributes.totalRecords mod attributes.recordsPerPage)) / attributes.recordsPerPage;
			if (attributes.totalRecords mod attributes.recordsPerPage neq 0){
				pTotalPages = pTotalPages + 1;
			}
						
			pFirstPage = attributes.currentPage - round((attributes.pageLinks - 1)/2) ;
			if(pFirstPage LT 1){
				pFirstPage = 1;
			}
			
			pLastPage = pFirstPage + attributes.pageLinks - 1;
			
			if(pLastPage GT pTotalPages){
					pFirstPage = pTotalPages - attributes.pageLinks - 1;
					pLastPage = pTotalPages;
			}
			
			if(pFirstPage LT 1){
				pFirstPage = 1;
			}
			
			if(pTotalPages LT attributes.step){
				bShowDropDown = false;
			}
			
			if(len(attributes.step)){
				if(pTotalPages GTE (attributes.recordsPerPage * attributes.pageLinks)){attributes.step = attributes.pageLinks;}
				else attributes.step = 1;
			}
			
		}
	</cfscript>
	
		
	<cfoutput>
	<div class="ruleContentVanilla">
		<div class="ruleListPagination">
	</cfoutput>
				
				
	<cfsavecontent variable="caller.paginationHTML">
		<cfif bShowPaginate>
			<cfoutput>#DisplayPaginationScroll(actionURL="#attributes.actionURL#", bShowResultTotal="#attributes.bShowResultTotal#",bShowPageDropdown="#attributes.bShowPageDropdown#")#</cfoutput>
			
		<cfelse>
			
			<cfif attributes.bShowResultTotal>
				<cfif attributes.totalRecords GT 0>
					<cfoutput><div class="pageDetails"><h2>Displaying <strong>1-#attributes.totalRecords#</strong> of <strong>#attributes.totalRecords#</strong> results</h2></div></cfoutput>
				<cfelse>
					<cfoutput><div class="pageDetails"><h2><strong>0</strong> records found.</h2></div></cfoutput>			
				</cfif>	
			</cfif>
		</cfif>
	</cfsavecontent>
		
	<cfif attributes.Top>	
		<cfoutput>#caller.paginationHTML#</cfoutput>
	</cfif>
	<!--- 			
	<cfif attributes.Top and bShowPaginate>
		<cfoutput>#DisplayPaginationScroll(bShowResultTotal="#attributes.bShowResultTotal#",bShowPageDropdown="#attributes.bShowPageDropdown#")#</cfoutput>
	</cfif>

	<cfif not bShowPaginate AND attributes.bShowResultTotal>
		<cfif attributes.totalRecords GT 0>
			<cfoutput><div class="pageDetails"><h2>Displaying <strong>1-#attributes.totalRecords#</strong> of <strong>#attributes.totalRecords#</strong> results</h2></div></cfoutput>
		<cfelse>
			<cfoutput><div class="pageDetails"><h2><strong>0</strong> records found.</h2></div></cfoutput>			
		</cfif>	
	</cfif> 
	 --->
	<cfoutput>	
	</div>
		</div>
	<br class="clearer" />
	</cfoutput>
	
	

		
	
</cfif>

<cfif thistag.executionMode eq "End">

	<cfoutput>
	<div class="ruleContentVanilla">
		<div class="ruleListPagination">
	</cfoutput>
					
	<cfif attributes.Bottom>	
		<cfoutput>#caller.paginationHTML#</cfoutput>
	</cfif>
	
	<cfoutput>	
		</div>
	</div>
	<br class="clearer" />
	</cfoutput>
</cfif>

<!--- user defined function, for generating pagination scroll --->
<cffunction name="displayPaginationScroll" access="private" output="false" returntype="string">
	
	<cfparam name="arguments.actionURL" default="#cgi.SCRIPT_NAME#" type="string" />
	<cfparam name="arguments.bShowResultTotal" default="true" type="boolean" />
	<cfparam name="arguments.bShowPageDropdown" default="true" type="boolean" />
	
	<cfscript>
		stURL = Duplicate(url);
		stURL = filterStructure(stURL,'Page');
		queryString=structToNamePairs(stURL);
	</cfscript>
		
	<cfset fromRecord = attributes.currentPage * attributes.recordsPerPage - attributes.recordsPerPage + 1 />
	<cfset toRecord = attributes.currentPage * attributes.recordsPerPage />
	<cfif toRecord GT attributes.totalRecords>
		<cfset toRecord = attributes.totalRecords />
	</cfif>

	<cfif pTotalPages GT 1>
		<cfif not isDefined("request.paginationpageInputFieldRendered")>
			<cfset request.inhead.prototypelite = 1>
			
			<cfsavecontent variable="jsPagination">
								
				<cfoutput>
				<script type="text/javascript">
				function paginationSubmission (page) {
					<cfif attributes.submissionType EQ "form">
						$('paginationpage').value=page;
						$('#Request.farcryForm.Name#').submit();
					<cfelse>
						window.location = '#arguments.actionURL#?#queryString#&page=' + page;
					</cfif>
				}
				</script>
				</cfoutput>
			</cfsavecontent>
			
			<cfhtmlhead text="#jsPagination#">
			
			<cfset request.paginationpageInputFieldRendered = 1 />
		</cfif>			
	</cfif>
	
	<cfsavecontent variable="scrollinnards">
		<!--- required for JS pagination --->
		<cfoutput><input type="hidden" name="paginationpage" id="paginationpage" value="" /></cfoutput>
		
		<cfif arguments.bShowResultTotal>
			<cfoutput><div class="pageDetails"><h2>Displaying <strong>#fromRecord#-#toRecord#</strong> of <strong>#attributes.totalRecords#</strong> results</h2></div></cfoutput>
		</cfif>
		
		<cfoutput><div class="pageList"><ul></cfoutput>			
		<cfif attributes.currentPage EQ 1>
			<cfif pTotalPages GT attributes.pageLinks>
				<cfoutput><li><a href="##">#attributes.htmlFirst#</a></li></cfoutput>
			</cfif>
			<cfoutput><li><a href="##">#attributes.htmlPrevious#</a></li></cfoutput>
		<cfelse>
			<cfif pTotalPages GT attributes.pageLinks>
				<cfoutput><li><a href="#arguments.actionURL#?#queryString#&amp;page=1" onclick="javascript:paginationSubmission(1);return false;">#attributes.htmlFirst#</a></li></cfoutput>
		   	</cfif>
		   	<cfoutput><li><a href="#arguments.actionURL#?#queryString#&amp;page=#attributes.currentPage-1#" onclick="javascript:paginationSubmission(#attributes.currentPage-1#);return false;">#attributes.htmlPrevious#</a></li></cfoutput>
		</cfif>		
		
		<cfloop from="#pFirstPage#" to="#pLastPage#" index="i">
		    <cfif attributes.currentPage EQ i>
				<cfoutput><li class="active"><a href="##">#i#</a></li></cfoutput>
		   <cfelse>
		   	<cfoutput><li><a href="#arguments.actionURL#?#queryString#&amp;page=#i#" onclick="javascript:paginationSubmission(#i#);return false;">#i#</a></li></cfoutput>	   
		    </cfif>
		</cfloop>
	
		<cfif attributes.currentPage * attributes.recordsPerPage LT attributes.totalRecords>
		
		   	<cfoutput><li><a href="#arguments.actionURL#?#queryString#&amp;page=#attributes.currentPage+1#" onclick="javascript:paginationSubmission(#attributes.currentPage+1#);return false;">#attributes.htmlNext#</a></li></cfoutput>
		   <cfif pTotalPages GT attributes.pageLinks>
			   <cfoutput><li><a href="#arguments.actionURL#?#queryString#&amp;page=#pTotalPages#" onclick="javascript:paginationSubmission(#pTotalPages#);return false;">#attributes.htmlLast#</a></li></cfoutput>
		   	</cfif>
		<cfelse>
			<cfoutput><li><a href="##">#attributes.htmlNext#</a></li></cfoutput>
			<cfif pTotalPages GT attributes.pageLinks>
				<cfoutput><li><a href="##">#attributes.htmlLast#</a></li></cfoutput>
		   	</cfif>
		</cfif>
	
		<cfoutput>
			</ul>
		</div>
		</cfoutput>
	</cfsavecontent>
	
	<cfreturn scrollinnards />
</cffunction>

