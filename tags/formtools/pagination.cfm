
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
		pagesLink="8"
		recordsPerPage="10" />

|| DEVELOPER ||
$Developer: Matthew Bryant (mat@bcreative.com.au)$

|| ATTRIBUTES ||
$in:  $
--->

<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.Step" default="1" type="numeric">
	
	<cfparam name="attributes.Top" default="true">
	<cfparam name="attributes.Bottom" default="true">
	<cfparam name="attributes.htmlFirst" default="first page">
	<cfparam name="attributes.htmlPrevious" default="prev page">
	<cfparam name="attributes.htmlNext" default="next page">
	<cfparam name="attributes.htmlLast" default="last page">
	
	
	<cfparam name="attributes.maxPages" default="0" type="numeric">
	
	<cfparam name="attributes.totalRecords" default="0" type="numeric">
	<cfparam name="attributes.currentPage" default="1" type="numeric">
	<cfparam name="attributes.pagesLink" default="0" type="numeric">
	<cfparam name="attributes.recordsPerPage" default="1" type="numeric">

	<cfinclude template="/farcry/farcry_core/admin/includes/utilityFunctions.cfm" >
	
	
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
						
			pFirstPage = attributes.currentPage - round((attributes.pagesLink - 1)/2) ;
			if(pFirstPage LT 1){
				pFirstPage = 1;
			}
			
			pLastPage = pFirstPage + attributes.pagesLink - 1;
			
			if(pLastPage GT pTotalPages){
					pFirstPage = pTotalPages - attributes.pagesLink - 1;
					pLastPage = pTotalPages;
			}
			
			if(pFirstPage LT 1){
				pFirstPage = 1;
			}
			
			if(pTotalPages LT attributes.step){
				bShowDropDown = false;
			}
			
			if(len(attributes.step) GT 0){
				if(pTotalPages GTE (attributes.recordsPerPage * attributes.pagesLink)){attributes.step = attributes.pagesLink;}
				else attributes.step = 1;
			}
			
			
			
		}
	</cfscript>
	

	
	<cfif attributes.Top and bShowPaginate>
		<cfoutput>#DisplayPaginationScroll()#</cfoutput>
	</cfif>

	<cfif not bShowPaginate>
		<cfif attributes.totalRecords GT 0>
			<cfoutput><h4>Displaying 1-#attributes.totalRecords# of #attributes.totalRecords# results</h4></cfoutput>
		<cfelse>
			<cfoutput><h4><strong>0</strong> records found.</h4></cfoutput>			
		</cfif>
		

	</cfif> 
	
</cfif>

<cfif thistag.executionMode eq "End">
	<cfif attributes.Bottom and bShowPaginate>
		<cfoutput>#DisplayPaginationScroll()#</cfoutput>
	</cfif>
</cfif>



<cffunction name="DisplayPaginationScroll" access="private" output="true" returntype="string">
	<cfscript>
		stURL = Duplicate(url);
		stURL = filterStructure(stURL,'Page');
		queryString=structToNamePairs(stURL);
	</cfscript>
		<cfsavecontent variable="cssPagi">
<style type="text/css">
	
   .pagination {border-top: 1px solid ##AEBAD0;color:##666;padding: 8px 0;float:left;width:100%} 

   .pagination p {float:right;width:auto;margin:0} 

   .pagination p a:link, .pagination p a:visited, .pagination p a:hover, .pagination p a:active {text-decoration:none;background:##fff;padding:0 3px;float:left;display:block;border: 1px solid ##ccc;margin-left: 3px;font-weight:bold} 

   .pagination p a:hover {background:##0C4CCD;color:##fff} 

   .pagination p span {text-decoration:none;background:##fff;padding:0 3px;border: 1px solid ##ccc;color:##ccc;display:block;float:left;margin-left: 3px} 
	
   .pagination p a:link, .pagination p a:visited, .pagination p a:hover, .pagination p a:active 
{
    text-decoration: none;
    background-color: rgb(255, 255, 255);
    background-image: none;
    background-repeat: repeat;
    background-attachment: scroll;
    -x-background-x-position: 0%;
    -x-background-y-position: 0%;
    -moz-background-clip: -moz-initial;
    -moz-background-origin: -moz-initial;
    -moz-background-inline-policy: -moz-initial;
    padding-top: 0pt;
    padding-right-value: 3px;
    padding-bottom: 0pt;
    padding-left-value: 3px;
    padding-left-ltr-source: physical;
    padding-left-rtl-source: physical;
    padding-right-ltr-source: physical;
    padding-right-rtl-source: physical;
    float: left;
    display: block;
    border-top-width: 1px;
    border-right-width: 1px;
    border-bottom-width: 1px;
    border-left-width: 1px;
    border-top-style: solid;
    border-right-style: solid;
    border-bottom-style: solid;
    border-left-style: solid;
    border-top-color: rgb(204, 204, 204);
    border-right-color: rgb(204, 204, 204);
    border-bottom-color: rgb(204, 204, 204);
    border-left-color: rgb(204, 204, 204);
    margin-left-value: 3px;
    margin-left-ltr-source: physical;
    margin-left-rtl-source: physical;
    font-weight: bold;
}

.pagination p a:link, .pagination p a:visited, .pagination p a:hover, .pagination p a:active  
{
    text-decoration: none;
    background-color: rgb(255, 255, 255);
    background-image: none;
    background-repeat: repeat;
    background-attachment: scroll;
    -x-background-x-position: 0%;
    -x-background-y-position: 0%;
    -moz-background-clip: -moz-initial;
    -moz-background-origin: -moz-initial;
    -moz-background-inline-policy: -moz-initial;
    padding-top: 0pt;
    padding-right-value: 3px;
    padding-bottom: 0pt;
    padding-left-value: 3px;
    padding-left-ltr-source: physical;
    padding-left-rtl-source: physical;
    padding-right-ltr-source: physical;
    padding-right-rtl-source: physical;
    float: left;
    display: block;
    border-top-width: 1px;
    border-right-width: 1px;
    border-bottom-width: 1px;
    border-left-width: 1px;
    border-top-style: solid;
    border-right-style: solid;
    border-bottom-style: solid;
    border-left-style: solid;
    border-top-color: rgb(204, 204, 204);
    border-right-color: rgb(204, 204, 204);
    border-bottom-color: rgb(204, 204, 204);
    border-left-color: rgb(204, 204, 204);
    margin-left-value: 3px;
    margin-left-ltr-source: physical;
    margin-left-rtl-source: physical;
    font-weight: bold;
}

.pagination p a:hover
{
    background-color: rgb(12, 76, 205);
    background-image: none;
    background-repeat: repeat;
    background-attachment: scroll;
    -x-background-x-position: 0%;
    -x-background-y-position: 0%;
    -moz-background-clip: -moz-initial;
    -moz-background-origin: -moz-initial;
    -moz-background-inline-policy: -moz-initial;
    color: rgb(255, 255, 255);
}
</style>
</cfsavecontent>
<cfhtmlhead text="#cssPagi#">
	
	
		<cfset fromRecord = attributes.currentPage * attributes.recordsPerPage - attributes.recordsPerPage + 1 />
		<cfset toRecord = attributes.currentPage * attributes.recordsPerPage />
		<cfif toRecord GT attributes.totalRecords>
			<cfset toRecord = attributes.totalRecords />
		</cfif>

			<cfoutput><h4>Displaying #fromRecord#-#toRecord# of #attributes.totalRecords# results</h4> Page</cfoutput>
			
			<cfif pTotalPages GT 1 and bShowDropDown>
				<cfoutput>
					<select name="page" onchange="javascript:window.location = '#cgi.SCRIPT_NAME#?#queryString#&page=' + this.value;"></cfoutput>
					<cfif attributes.step GT 1><cfoutput><option value="1"><cfif attributes.currentPage EQ 1><1><cfelse>1</cfif></option></cfoutput></cfif>
					
					
					<cfif attributes.step GT 1 AND 1 LT attributes.currentPage AND (1 + attributes.step) GT attributes.currentPage>
						<cfoutput><option value="" selected><#attributes.currentPage#></option></cfoutput>
					</cfif>
					
										
					<cfloop from="#attributes.step#" to="#pTotalPages#" index="i" step="#attributes.step#">
						<cfoutput><option value="#i#"<cfif attributes.currentPage EQ i> selected</cfif>><cfif attributes.currentPage EQ i><#i#><cfelse>#i#</cfif></option></cfoutput>
						
						<cfif attributes.step GT 1 AND i LT attributes.currentPage AND (i + attributes.step) GT attributes.currentPage>
							<cfoutput><option value="" selected><#attributes.currentPage#></option></cfoutput>
						</cfif>
					
					</cfloop>
				<cfoutput></select></cfoutput>
			<cfelse>
				<cfoutput><strong>#attributes.currentPage#</strong></cfoutput>
			</cfif>
			
			<cfoutput>of <strong>#pTotalPages#</strong></cfoutput> 
				

			<cfset paginationHTML = '<div class="pagination"><p>'>			
			<cfif attributes.currentPage EQ 1>
				<cfif pTotalPages GT attributes.pagesLink>
			   		<cfset paginationHTML = paginationHTML & '<span>' & attributes.htmlFirst &'</span>'>
				</cfif>
				<cfset paginationHTML = paginationHTML & '<span>' & attributes.htmlPrevious &'</span>'>
			<cfelse>
				<cfif pTotalPages GT attributes.pagesLink>
					<cfset paginationHTML = paginationHTML & '<a href="#cgi.SCRIPT_NAME#?#queryString#&page=1">' & attributes.htmlFirst &'</a>'>
			   	</cfif>
			   	<cfset paginationHTML = paginationHTML & '<a href="#cgi.SCRIPT_NAME#?#queryString#&page=#attributes.currentPage-1#"><strong>' & attributes.htmlPrevious &'</strong></a>'>
			</cfif>		
			

			<cfloop from="#pFirstPage#" to="#pLastPage#" index="i">
			    <cfif attributes.currentPage EQ i>
			       <cfset paginationHTML = paginationHTML & '<span>#i#</span>'>
			   <cfelse>
			        <cfset paginationHTML = paginationHTML & '<a href="#cgi.SCRIPT_NAME#?#queryString#&page=#i#">#i#</a>'>
			    </cfif>
			</cfloop>
		
		
			<cfif attributes.currentPage * attributes.recordsPerPage LT attributes.totalRecords>
			    <cfset paginationHTML = paginationHTML & '<a href="#cgi.SCRIPT_NAME#?#queryString#&page=#attributes.currentPage+1#"><strong>' & attributes.htmlNext &'</strong></a>'>
			   <cfif pTotalPages GT attributes.pagesLink>
			   		<cfset paginationHTML = paginationHTML & '<a href="#cgi.SCRIPT_NAME#?#queryString#&page=#pTotalPages#"><strong>' & attributes.htmlLast &'</strong></a>'>
			   	</cfif>
			<cfelse>
			   <cfset paginationHTML = paginationHTML & '<span>' & attributes.htmlNext &'</span>'>
				<cfif pTotalPages GT attributes.pagesLink>
			   		<cfset paginationHTML = paginationHTML & '<span>' & attributes.htmlLast &'</span>'>
			   	</cfif>
			</cfif>
			
		<cfset paginationHTML = paginationHTML & '</p></div>'>
		
		
		<cfoutput>#paginationHTML#</cfoutput>


	<cfoutput><br style="clear:both;" /></cfoutput>
	
</cffunction>

