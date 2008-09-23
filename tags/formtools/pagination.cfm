<cfsetting enablecfoutputonly="true" />
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
<!---
|| DESCRIPTION || 
$Description:  -- This is a subtag that will add the links to enable the user to scroll through the entire recordset $

|| Syntax Sample 
<cf_pagination 
		totalRecords = "100"
		currentPage="2"
		pageLinks="8"
		recordsPerPage="10" />

|| DEVELOPER ||
$Developer: Matthew Bryant (mat@daemon.com.au) $
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />


<cfif thistag.executionMode eq "Start">

	<!--- optional attributes --->
	<cfparam name="attributes.Top" default="true">
	<cfparam name="attributes.Bottom" default="true">
	<cfparam name="attributes.htmlFirst" default="&laquo;">
	<cfparam name="attributes.htmlPrevious" default="&lt;">
	<cfparam name="attributes.htmlNext" default="&gt;">
	<cfparam name="attributes.htmlLast" default="&raquo;">
	<cfparam name="attributes.bShowResultTotal" default="false" type="boolean" /><!--- Shows the details of the current rendered records instead of the page details --->
	<cfparam name="attributes.bShowPageDropdown" default="false" type="boolean" /><!--- uses a dropdown instead of links. --->
	<cfparam name="attributes.paginationID" default="" /><!--- Keeps track of the page the user is currently on in session against this key. --->
	<cfparam name="attributes.CurrentPage" default="0" />
	<cfparam name="attributes.maxRecordsToDisplay" default="0" type="numeric">
	<cfparam name="attributes.totalRecords" default="0" type="numeric">
	<cfparam name="attributes.pageLinks" default="10" type="numeric">
	<cfparam name="attributes.recordsPerPage" default="1" type="numeric">
	<cfparam name="attributes.submissionType" default="url" type="string">
	<cfparam name="attributes.actionURL" default="" type="string">
	<cfparam name="attributes.typename" default="" type="string">
	

	<cfparam name="attributes.scrollPrefix" default="" type="string" />
	<cfparam name="attributes.scrollSuffix" default="" type="string" />
	<cfparam name="attributes.renderType" default="list" type="string" />
	
	
	<cfparam name="attributes.Step" default="1" type="numeric">
	
	
	<cfif not isDefined("attributes.qRecordSet") or not isQuery(attributes.qRecordSet)>
		<cfabort showerror="you must pass a recordset into pagination." />
	</cfif>

	<!--- import function libraries --->
	<cfinclude template="/farcry/core/webtop/includes/utilityFunctions.cfm" >
	<cfset oFormtoolUtil = createObject("component", "farcry.core.packages.farcry.formtools") />
	
	<cfset attributes.currentPage = oFormtoolUtil.getCurrentPaginationPage(paginationID=attributes.paginationID, currentPage=attributes.currentPage) />

	<cfif attributes.totalRecords GT attributes.qRecordSet.recordCount>
		<!--- This means we have passed in only the page of recordset information we need for rendering --->
		<cfset attributes.startRow = 1 />
		<cfset attributes.endRow = attributes.recordsPerPage />
			
	<cfelse>
		<!--- This means that we have passed in an entire recordset and not just the page of relevent data --->
		<cfset attributes.totalRecords = attributes.qRecordSet.recordCount />
		<cfset attributes.startRow = attributes.currentPage * attributes.recordsPerPage - attributes.recordsPerPage + 1 />
		<cfif attributes.StartRow GT attributes.totalRecords>
			<cfset attributes.startRow = 1 />
		</cfif>
		
		<cfset attributes.endRow = attributes.currentPage * attributes.recordsPerPage />
	</cfif>

	<!--- Determine the max records to display. Can be a maximum of the recordsPerPage --->
	<cfif attributes.maxRecordsToDisplay GT attributes.recordsPerPage>
		<cfset attributes.maxRecordsToDisplay = attributes.recordsPerPage />
	</cfif>
		
	<cfif attributes.maxRecordsToDisplay GT 0>
		<cfset attributes.endRow = attributes.startRow + attributes.maxRecordsToDisplay - 1 />
		<cfif attributes.maxRecordsToDisplay LT attributes.totalRecords>
			<cfset attributes.totalRecords = attributes.maxRecordsToDisplay />
		</cfif>
	</cfif>

	<!--- Make sure the end row is not more than the recordcount --->
	<cfif attributes.endRow GT attributes.qRecordSet.recordcount>
		<cfset attributes.endRow = attributes.qRecordSet.recordcount />
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
			
			/*
			TODO: MODIUS Determine if step is still valid
			if(len(attributes.step)){
				if(pTotalPages GTE (attributes.recordsPerPage * attributes.pageLinks)){attributes.step = attributes.pageLinks;}
				else attributes.step = 1;
			} 
			*/
		}
	</cfscript>
	
	
	<!--- pagination scroll --->
	<cfoutput>#attributes.scrollprefix#</cfoutput>
				
	<cfsavecontent variable="caller.paginationHTML">
		<cfif bShowPaginate>
			<cfoutput>#DisplayPaginationScroll(actionURL="#attributes.actionURL#", bShowResultTotal="#attributes.bShowResultTotal#",bShowPageDropdown="#attributes.bShowPageDropdown#", renderType="#attributes.renderType#")#</cfoutput>
			
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

	<!--- /pagination scroll --->
	<cfoutput>#attributes.scrollSuffix#</cfoutput>

	
</cfif>

<cfif thistag.executionMode eq "End">

	<!--- pagination scroll --->
	<cfoutput>#attributes.scrollPrefix#</cfoutput>
					
	<cfif attributes.Bottom>	
		<cfoutput>#caller.paginationHTML#</cfoutput>
	</cfif>
	
	<!--- /pagination scroll --->
	<cfoutput>#attributes.scrollSuffix#</cfoutput>

</cfif>

<!----------------------------------------------- 
user defined functions
- for generating pagination scroll 
------------------------------------------------>
<cffunction name="displayPaginationScroll" access="private" output="false" returntype="string">
	
	<cfparam name="arguments.actionURL" default="" type="string" />
	<cfparam name="arguments.bShowResultTotal" default="true" type="boolean" />
	<cfparam name="arguments.bShowPageDropdown" default="false" type="boolean" />
	<cfparam name="arguments.renderType" default="list" type="string" />
	
	
	
	<cfif NOT len(trim(arguments.actionURL))>
		
		<cfscript>
			stURL = Duplicate(url);
			stURL = filterStructure(stURL,'Page');
			stURL = filterStructure(stURL,'updateapp');
			queryString=structToNamePairs(stURL);
		</cfscript>
		
		<cfset arguments.actionURL = "#cgi.script_name#?#queryString#" />
	
	<cfelse>
	
		<!--- if there is an actionURL passed, we'll append a ? so 'page' can be appended by pagination.cfm --->
		<cfif NOT find("?", arguments.actionURL)>
			<cfset arguments.actionURL = arguments.actionURL & "?" />
		</cfif>
	
	</cfif>
	
		
	<cfset fromRecord = attributes.currentPage * attributes.recordsPerPage - attributes.recordsPerPage + 1 />
	<cfset toRecord = attributes.currentPage * attributes.recordsPerPage />
	<cfif toRecord GT attributes.totalRecords>
		<cfset toRecord = attributes.totalRecords />
	</cfif>
	
	
	<cfsavecontent variable="scrollinnards">
	

		<cfif bShowPaginate AND pTotalPages GT 1>
			<skin:htmlHead library="prototypelite" />
			
			<cfoutput>
			<script type="text/javascript">
			paginationSubmission = function(page){
				<cfif attributes.submissionType EQ "form">
					$('paginationpage').value=page;
					#Request.farcryForm.onSubmit#				
					$('#Request.farcryForm.Name#').submit();
				<cfelseif attributes.submissionType eq "url">
					window.location = '#arguments.actionURL#&page=' + page;
				<cfelse>
					// No js code nothing
				</cfif>
			}
	
			</script>
			</cfoutput>
			
		</cfif>	
		
	
		<!--- required for JS pagination --->
		<cfoutput><input type="hidden" name="paginationpage" id="paginationpage" value="" /></cfoutput>
	
		<cfswitch expression="#arguments.renderType#">
		
			<cfcase value="inline">
				
				<cfoutput><div class="pagination"></cfoutput>			


					<cfif arguments.bShowResultTotal>
						<cfoutput><h4>Displaying #fromRecord#-#toRecord# of #attributes.totalRecords# results</h4></cfoutput>
					<cfelse>
						<cfoutput><h4>Page #attributes.currentPage# of #pTotalPages#</h4></cfoutput>
					</cfif>
								
					<cfoutput><p></cfoutput>
					
						<cfif attributes.currentPage EQ 1>
							<cfif pTotalPages GT attributes.pageLinks>
								<cfoutput><span><strong>#attributes.htmlFirst#</strong></span></cfoutput>
							</cfif>
							<cfoutput><span><strong>#attributes.htmlPrevious#</strong></span></cfoutput>
						<cfelse>
							<cfif pTotalPages GT attributes.pageLinks>
								<cfoutput><a href="#arguments.actionURL#&amp;page=1" #IIF(attributes.submissionType neq "link",DE('onclick="javascript:paginationSubmission(1);return false;"'),DE(""))#>#attributes.htmlFirst#</a></cfoutput>
						   	</cfif>
						   	<cfoutput><a href="#arguments.actionURL#&amp;page=#attributes.currentPage-1#" #IIF(attributes.submissionType neq "link",DE('onclick="javascript:paginationSubmission(#attributes.currentPage-1#);return false;"'),DE(""))#>#attributes.htmlPrevious#</a></cfoutput>
						</cfif>		
						
						<cfif arguments.bShowPageDropdown>
							<cfoutput>
							<select name="paginationDropdown" onchange="javascript:paginationSubmission(this.value);return false;">
								<cfloop from="#pFirstPage#" to="#pLastPage#" index="i" step="#attributes.step#">
									<option value="#i#" <cfif attributes.currentPage EQ i>selected</cfif> >&nbsp;#i#&nbsp;</option>
								</cfloop>
							</select>
							</cfoutput>
						<cfelse>
							
							<cfloop from="#pFirstPage#" to="#pLastPage#" index="i" step="#attributes.step#">
							    <cfif attributes.currentPage EQ i>
									<cfoutput><span class="current-page">#i#</span></cfoutput>
							   <cfelse>
							   	<cfoutput><a href="#arguments.actionURL#&amp;page=#i#" #IIF(attributes.submissionType neq "link",DE('onclick="javascript:paginationSubmission(#i#);return false;"'),DE(""))#>#i#</a></cfoutput>	   
							    </cfif>
							</cfloop>
						</cfif>


					
						<cfif attributes.currentPage * attributes.recordsPerPage LT attributes.totalRecords>
						
						   	<cfoutput><a href="#arguments.actionURL#&amp;page=#attributes.currentPage+1#" #IIF(attributes.submissionType neq "link",DE('onclick="javascript:paginationSubmission(#attributes.currentPage+1#);return false;"'),DE(""))#>#attributes.htmlNext#</a></cfoutput>
						   <cfif pTotalPages GT attributes.pageLinks>
							   <cfoutput><a href="#arguments.actionURL#&amp;page=#pTotalPages#" #IIF(attributes.submissionType neq "link",DE('onclick="javascript:paginationSubmission(#pTotalPages#);return false;"'),DE(""))#>#attributes.htmlLast#</a></cfoutput>
						   	</cfif>
						<cfelse>
							<cfoutput><span>#attributes.htmlNext#</span></cfoutput>
							<cfif pTotalPages GT attributes.pageLinks>
								<cfoutput><span>#attributes.htmlLast#</span></cfoutput>
						   	</cfif>
						</cfif>
				
					<cfoutput></p></cfoutput>
	
				
					
								
				<cfoutput>
				</div>
				</cfoutput>
								
			</cfcase>
			
			<cfdefaultcase>
				
				<cfoutput><div class="ruleContentVanilla"><div class="ruleListPagination"></cfoutput>
				
				<cfif arguments.bShowResultTotal>
					<cfoutput><div class="pageDetails"><h2>Displaying <strong>#fromRecord#-#toRecord#</strong> of <strong>#attributes.totalRecords#</strong> results</h2></div></cfoutput>
				<cfelse>
					<cfoutput><div class="pageDetails"><h2>Displaying page <strong>#attributes.currentPage#</strong> of <strong>#pTotalPages#</strong> pages</h2></div></cfoutput>
				</cfif>
				
				<cfoutput><div class="pageList"><ul></cfoutput>			
				<cfif attributes.currentPage EQ 1>
					<cfif pTotalPages GT attributes.pageLinks>
						<cfoutput><li><a href="javascript:void(0)">#attributes.htmlFirst#</a></li></cfoutput>
					</cfif>
					<cfoutput><li><a href="javascript:void(0)">#attributes.htmlPrevious#</a></li></cfoutput>
				<cfelse>
					<cfif pTotalPages GT attributes.pageLinks>
						<cfoutput><li><a href="#arguments.actionURL#&amp;page=1" #IIF(attributes.submissionType neq "link",DE('onclick="javascript:paginationSubmission(1);return false;"'),DE(""))#>#attributes.htmlFirst#</a></li></cfoutput>
				   	</cfif>
				   	<cfoutput><li><a href="#arguments.actionURL#&amp;page=#attributes.currentPage-1#" #IIF(attributes.submissionType neq "link",DE('onclick="javascript:paginationSubmission(#attributes.currentPage-1#);return false;"'),DE(""))#>#attributes.htmlPrevious#</a></li></cfoutput>
				</cfif>		
				
				<cfloop from="#pFirstPage#" to="#pLastPage#" index="i">
				    <cfif attributes.currentPage EQ i>
						<cfoutput><li class="active"><a href="javascript:void(0)">#i#</a></li></cfoutput>
				   <cfelse>
				   	<cfoutput><li><a href="#arguments.actionURL#&amp;page=#i#" #IIF(attributes.submissionType neq "link",DE('onclick="javascript:paginationSubmission(#i#);return false;"'),DE(""))#>#i#</a></li></cfoutput>	   
				    </cfif>
				</cfloop>
			
				<cfif attributes.currentPage * attributes.recordsPerPage LT attributes.totalRecords>
				
				   	<cfoutput><li><a href="#arguments.actionURL#&amp;page=#attributes.currentPage+1#" #IIF(attributes.submissionType neq "link",DE('onclick="javascript:paginationSubmission(#attributes.currentPage+1#);return false;"'),DE(""))#>#attributes.htmlNext#</a></li></cfoutput>
				   <cfif pTotalPages GT attributes.pageLinks>
					   <cfoutput><li><a href="#arguments.actionURL#&amp;page=#pTotalPages#" #IIF(attributes.submissionType neq "link",DE('onclick="javascript:paginationSubmission(#pTotalPages#);return false;"'),DE(""))#>#attributes.htmlLast#</a></li></cfoutput>
				   	</cfif>
				<cfelse>
					<cfoutput><li><a href="javascript:void(0)">#attributes.htmlNext#</a></li></cfoutput>
					<cfif pTotalPages GT attributes.pageLinks>
						<cfoutput><li><a href="javascript:void(0)">#attributes.htmlLast#</a></li></cfoutput>
				   	</cfif>
				</cfif>
			
				<cfoutput>
					</ul>
				</div>
				</cfoutput>
				
				<cfoutput></div></div><br class="clearer" /></cfoutput>
			</cfdefaultcase>	
		
		</cfswitch>
	</cfsavecontent>
	
	
	<cfreturn scrollinnards />
</cffunction>

<cfsetting enablecfoutputonly="false" />