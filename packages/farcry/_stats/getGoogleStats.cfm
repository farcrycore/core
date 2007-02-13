<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_stats/getGoogleStats.cfm,v 1.2 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: Shows referers$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">

<!--- get maxrows if not defined --->
<cfif arguments.maxRows eq "all">
	<cfquery datasource="#arguments.dsn#" name="qMax">
		SELECT count(logid) as maxrows
		FROM #application.dbowner#stats
	</cfquery>
	<cfset arguments.maxrows = qMax.maxrows>
</cfif>

<!--- get downloads from stats --->
<cfquery datasource="#arguments.dsn#" name="qRawStats" maxrows="#arguments.maxRows#">
	SELECT referer, count(logId) as count_referers
	FROM #application.dbowner#stats
	WHERE referer like '%google.com%'
	<cfif arguments.dateRange neq "all">
		AND logDateTime > #dateAdd("#arguments.dateRange#",-1,now())#
	</cfif>
	GROUP By referer
	ORDER BY count_referers DESC
</cfquery>

<!--- create return query --->
<cfset qGetGoogleStats = queryNew("keywords,referer,referals")>

<!--- initiate counter --->
<cfset counter = 0>

<!--- loop over raw stats and pull out key words --->
<cfif qRawStats.recordcount>
	<cfloop query="qRawStats">
		<cfscript>
			// based on  Matthew Fusfield's UDF (http://www.cflib.org/udf.cfm?ID=585)
			StartPos=ReFindNoCase('q=.',referer);
		
			if (StartPos GT 0) {
				EndString=mid(referer,StartPos+2,Len(referer));
				Keywords=ReReplaceNoCase(EndString,'&.*','','ALL');
				Keywords=URLDecode(Keywords);
				}
			
			// add row to query
			temp = queryAddRow(qGetGoogleStats, 1);
			temp = querySetCell(qGetGoogleStats, "keywords", Keywords);
			temp = querySetCell(qGetGoogleStats, "referer", qRawStats.referer);
			temp = querySetCell(qGetGoogleStats, "referals", qRawStats.count_referers);
			
			// update counter
			counter = counter + 1;
			if (counter eq arguments.maxRows and arguments.maxRows neq "all")
				break;
		</cfscript>
	</cfloop>
</cfif>