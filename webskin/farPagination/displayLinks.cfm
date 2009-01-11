<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Displays the Pagination Links --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!------------------ 
START WEBSKIN
 ------------------>

<skin:htmlHead id="paginationCSS">
<cfoutput>
<style type="text/css">
.pagination {background: ##f2f2f2;color:##666;padding: 4px 2px 4px 7px;border: 1px solid ##ddd;margin: 0 0 1.5em}
.pagination p {position:relative;text-align:right}

.pagination p span {text-decoration:none;background:##fff;padding:2px 5px;border: 1px solid ##ccc;color:##ccc;}

.pagination p a:link, 
.pagination p a:visited, 
.pagination p a:hover, 
.pagination p a:active {
	text-decoration:none;background:##fff;padding:2px 5px;border: 1px solid ##ccc;color:##777;
}
.pagination p a:hover,
.pagination p .p-current{
	background:##c00;color:##fff
}

.pagination * {margin:0}
.pagination h4 {margin-top:-1.4em;padding:0;border:none}
</style>
</cfoutput>
</skin:htmlHead>

<cfoutput>
	<div class="pagination">	
		
		<p>
			<skin:buildPaginationLink stLink="#getLink('first')#" linkText="1" />			
			<skin:buildPaginationLink stLink="#getLink('previous')#" linkText="<<" />
			
			<cfloop from="#getPageFrom()#" to="#getPageTo()#" index="i">
				<skin:buildPaginationLink stLink="#getLink(i)#" />
			</cfloop>
			
			<skin:buildPaginationLink stLink="#getLink('next')#" linkText=">>" />
			<skin:buildPaginationLink stLink="#getLink('last')#" linkText="#getTotalPages()#" />
		</p>
		<h4>Page #getCurrentPage()# of #getTotalPages()#</h4>
	</div>
</cfoutput>		

<cfsetting enablecfoutputonly="false">