<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Displays the Pagination Links --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!--------------------------------------------- 
AVAILABLE INFORMATION
------------------------------------------------>
<!--- 
getQuery()			Get the start page of the pagination loop
getTotalRecords()	Return the number of records in the entire pagination set
getPageFrom()		Get the start page of the pagination loop
getPageTo() 		Get the end page of the pagination loop
getCurrentPage() 	Get the current page
getTotalPages() 	Get the total number of pages
getFirstPage() 		Get the first page in the pagination loop
getLastPage() 		Get the last page in the pagination loop
getRecordFrom() 	Get the first row of the recordset for the current page of the pagination.
getRecordTo() 		Get the last row of the recordset for the current page of the pagination.
getCurrentRow() 	Get the current row of the recordset for the current page of the pagination.
 --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!------------------ 
START WEBSKIN
 ------------------>

<!--- INCLUDE THE CSS IN THE HEADER --->
<skin:loadCSS id="farcry-pagination" />


<!--- OUTPUT THE MARKUP FOR THE PAGINATOR --->
<cfif getPageTo() GT 1>
	<cfoutput>
	<div class="paginator-wrap">
		<div class="paginator">	
			#renderLink(linkid="previous", linkText="< previous")#
			
			<cfloop from="#getPageFrom()#" to="#getPageTo()#" index="i">
				#renderLink(linkid=i)#
			</cfloop>
			
			#renderLink(linkid="next", linkText="next >")#
		</div>
	</div>
	</cfoutput>	
</cfif>


<cfsetting enablecfoutputonly="false">