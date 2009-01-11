<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Displays the Pagination Links --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/plugins/farcryShop/tags" prefix="pag" />

<!------------------ 
START WEBSKIN
 ------------------>

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

<cfoutput>
	<div class="pagination">	
		
		<p>
			<cfif getFirstPage() GT 1>
				<pag:buildPaginationLink stLink="#getLink('first')#" linkText="1" />...
			</cfif>
			
			<cfloop from="#getPageFrom()#" to="#getPageTo()#" index="i">
				<pag:buildPaginationLink stLink="#getLink(i)#" />
			</cfloop>
			
			<cfif getLastPage() LT getTotalPages()>
				...<pag:buildPaginationLink stLink="#getLink('last')#" linkText="#getTotalPages()#" />
			</cfif>
			
			
			
			<pag:buildPaginationLink stLink="#getLink('previous')#" linkText="<<" />
			<pag:buildPaginationLink stLink="#getLink('next')#" linkText=">>" />
		</p>
		<h4>Page #getCurrentPage()# of #getTotalPages()#</h4>
	</div>
</cfoutput>		

<cfoutput>
	<div class="pagination">	
		
		<p>
			<pag:buildPaginationLink stLink="#getLink('first')#" />
			<pag:buildPaginationLink stLink="#getLink('previous')#" linkText="<<" />
			
			<cfloop from="#getPageFrom()#" to="#getPageTo()#" index="i">
				<pag:buildPaginationLink stLink="#getLink(i)#" />
			</cfloop>			
			
			<pag:buildPaginationLink stLink="#getLink('next')#" linkText=">>" />			
			<pag:buildPaginationLink stLink="#getLink('last')#" />
		</p>
		<h4>Page #getCurrentPage()# of #getTotalPages()#</h4>
	</div>
</cfoutput>			


<cfsetting enablecfoutputonly="false">