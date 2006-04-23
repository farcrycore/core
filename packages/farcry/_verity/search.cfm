<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_verity/search.cfm,v 1.6 2004/06/02 01:12:00 brendan Exp $
$Author: brendan $
$Date: 2004/06/02 01:12:00 $
$Name: milestone_2-2-1 $
$Revision: 1.6 $

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
<cfset qResults = queryNew("title,key,score,summary,custom1,custom2")>

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
		<cfset queryAddRow(qResults, 1)>
		<cfif trim(qFirstResults.title) eq "">
			<cfset querySetCell(qResults, "title", "(no title available)")>
		<cfelse>
			<cfset querySetCell(qResults, "title", trim(qFirstResults.title))>	
		</cfif>
		<cfset querySetCell(qResults, "key", qFirstResults.key)>
		<cfset querySetCell(qResults, "score", "#NumberFormat(qFirstResults.score*100)#%")>
		<cfset querySetCell(qResults, "summary", "#textHighlight(htmleditformat(HTMLStripper(qFirstResults.summary)), arguments.searchString)#")>
		<cfset querySetCell(qResults, "custom1", qFirstResults.custom1)>
		<cfset querySetCell(qResults, "custom2", qFirstResults.custom2)>
	</cfloop>
	<cfcatch></cfcatch>
</cftry>