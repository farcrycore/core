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
<skin:htmlHead id="pagination-css">
<cfoutput>
<style type="text/css">
.paginator-wrap {text-align:center;margin-bottom:20px;margin-top:20px;}
.paginator {font-size:12px;padding-top:10px;margin-left:auto;margin-right:auto;color:##aaa;}
.paginator a {padding:2px 6px;border:solid 1px ##ddd;background:##fff;text-decoration:none;color:##aaa;}
.paginator span.p-first {margin-right:20px;padding:4px 8px;background:##fff;color:##aaa;}
.paginator a.p-first {margin-right:20px;padding:2px 6px;border:solid 1px ##ddd;background:##fff;}
.paginator span.p-last {margin-left:20px;padding:4px 8px;background:##fff;color:##aaa;}
.paginator a.p-last	{margin-left:20px;padding:2px 6px;border:solid 1px ##ddd;background:##fff;}
.paginator span.p-previous {margin-right:20px;padding:4px 8px;background:##fff;color:##aaa;}
.paginator a.p-previous {margin-right:20px;padding:2px 6px;border:solid 1px ##ddd;background:##fff;}
.paginator span.p-next {margin-left:20px;padding:4px 8px;background:##fff;color:##aaa;}
.paginator a.p-next {margin-left:20px;padding:2px 6px;border:solid 1px ##ddd;background:##fff;}
.paginator span.p-page{
	background:##FFFFFF none repeat scroll 0 0;
	color:##ff0000;
	font-size:12px;
	font-weight:bold;
	padding:4px 8px;
	vertical-align:top;}	
.paginator a.p-page{padding:2px 6px;
	border-color:##ddd;
	font-weight:normal;
	font-size:12px;
	vertical-align:top;
	background:##fff;
	}
.paginator a:hover {color:##fff;background:##0063DC;border-color:##036;text-decoration:none;}
</style>
</cfoutput>
</skin:htmlHead>

<!--- OUTPUT THE MARKUP FOR THE PAGINATOR --->
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


<cfsetting enablecfoutputonly="false">