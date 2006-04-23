<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/ui/admin/Attic/getCountDescendants.cfm,v 1.1 2003/04/11 06:17:54 brendan Exp $
$Author: brendan $
$Date: 2003/04/11 06:17:54 $
$Name: b131 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: gets the count of all the descendants of a given object in the nested tree objects table, so that you can 
reset the left and right hand values$
$TODO: $

|| DEVELOPER ||
$Developer: Daniel Morphett (daniel@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting enablecfoutputonly="Yes">

<cfif not IsDefined("attributes.objectID") or not IsDefined("attributes.datasource") or not IsDefined("attributes.r_count") >
    <cfabort showerror="missing attribute. can't do it">
</cfif>

<cfquery name="qGetLevel" datasource="#attributes.datasource#">
	SELECT nlevel 
	FROM #application.dbowner#nested_tree_objects
	WHERE objectid = '#attributes.objectID#'
</cfquery>
<cfquery name="qGetMaxLevel" datasource="#attributes.datasource#">
	SELECT max(nlevel) as maxlvl
	FROM #application.dbowner#nested_tree_objects
	WHERE typename = (
        select typename from nested_tree_objects 
        where objectid = '#attributes.objectID#'
        )
</cfquery>

<!--- build query statement, based on the level of the object and the maximum depth of the tree --->
<cfscript>
    selectStatement = "select ";
    fromStatement = "from #application.dbowner#nested_tree_objects n" & qGetLevel.nlevel & " ";
    whereStatement = "where n" & qGetLevel.nlevel & ".objectid = '" & attributes.objectID & "'";
    for(i=qGetLevel.nlevel; i lte qGetMaxLevel.maxlvl; i = i + 1) {
        selectStatement = selectStatement & "count(distinct n" & i + 1 & ".objectID) + " ;
        fromStatement = fromStatement & "left join nested_tree_objects n" & i + 1 & " on n" & i &".objectid = n" & i + 1 & ".parentid ";
    }
    // whip off the trailing plus sign
    selectStatement = left(selectStatement, len(selectStatement)-2);
    // add an alias so that we can reference the output
    selectStatement = selectStatement & "as descCount ";
    queryStatement = selectStatement & fromStatement & whereStatement;
</cfscript>

<!--- execute it --->
<cfquery name="qGetDescendantCount" datasource="#attributes.datasource#">
	#preservesinglequotes(querystatement)#
</cfquery>

<cfset "caller.#attributes.r_count#" = qGetDescendantCount.descCount>

<cfsetting enablecfoutputonly="No">