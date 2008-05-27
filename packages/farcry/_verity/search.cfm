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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_verity/search.cfm,v 1.8 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-0 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: Verity search$


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