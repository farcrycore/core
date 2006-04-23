<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_verity/search.cfm,v 1.5 2003/10/27 00:08:46 brendan Exp $
$Author: brendan $
$Date: 2003/10/27 00:08:46 $
$Name: b201 $
$Revision: 1.5 $

|| DESCRIPTION || 
$Description: Verity search$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<!--- create return query --->
<cfset qResults = queryNew("title,key,score,summary")>

<!--- perform search --->
<cftry>
	<cfsearch collection="#arguments.lCollections#" criteria="#arguments.searchString#" name="qFirstResults" maxrows="#arguments.maxRows#">
	<!--- log search --->
	<cfif not isdefined("url.startRow")>
		<cfset application.factory.oStats.logSearch(searchString=arguments.searchString,lcollections=arguments.lCollections,results=qFirstResults.recordcount)>
	</cfif>
	
	<!--- loop over results and prepare for display --->
	<cfloop query="qFirstResults">
		<!--- add row to query --->
		<cfset temp = queryAddRow(qResults, 1)>
		<cfif trim(qFirstResults.title) eq "">
			<cfset temp = querySetCell(qResults, "title", "(no title available)")>
		<cfelse>
			<cfset temp = querySetCell(qResults, "title", trim(qFirstResults.title))>	
		</cfif>
		<cfset temp = querySetCell(qResults, "key", qFirstResults.key)>
		<cfset temp = querySetCell(qResults, "score", "#NumberFormat(qFirstResults.score*100)#%")>
		<cfset temp = querySetCell(qResults, "summary", "#textHighlight(htmleditformat(HTMLStripper(qFirstResults.summary)), arguments.searchString)#")>
	</cfloop>
	<cfcatch></cfcatch>
</cftry>