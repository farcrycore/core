<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_reporting/getRecentObjects.cfm,v 1.9 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.9 $

|| DESCRIPTION || 
$Description: returns recent objects $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfif arguments.objectType eq "dmHTML">
	<!--- Get recent objects and nav parent --->
	<cfquery name="qGetObjects" datasource="#application.dsn#" maxrows="#arguments.numberOfObjects#">
	SELECT #arguments.objectType#.objectID,
                #arguments.objectType#.title,
                #arguments.objectType#.createdby,
                #arguments.objectType#.dateTimeCreated,
                dmNavigation_aObjectIDs.parentid as objectParent
	FROM #application.dbowner##arguments.objectType#,
             #application.dbowner#dmNavigation_aObjectIDs 
	WHERE dmNavigation_aObjectIDs.data = #arguments.objectType#.objectid
	ORDER BY #arguments.objectType#.dateTimeCreated DESC
	</cfquery>
<cfelse>
	<!--- Get recent objects --->
	<cfquery name="qGetObjects" datasource="#application.dsn#" maxrows="#arguments.numberOfObjects#">
	SELECT objectID, title, createdBy, dateTimeCreated
	FROM #application.dbowner##arguments.objectType#
	ORDER BY dateTimeCreated DESC
	</cfquery>
</cfif>

<cfset stRecentObjects = structNew()>

<cfloop query="qGetObjects">
    <cfscript>
    stTemp = structNew();
    stTemp.objectID = qGetObjects.objectID;
    stTemp.title = qGetObjects.title;
    stTemp.createdBy = qGetObjects.createdBy;
    stTemp.dateTimeCreated = qGetObjects.dateTimeCreated;
    if (arguments.objectType eq "dmHTML") stTemp.objectParent = qGetObjects.objectParent;

    o_profile = createObject("component", application.types.dmProfile.typePath);
    stProfile = o_profile.getProfile(userName=qGetObjects.createdBy);
    if (not structIsEmpty(stProfile)) stTemp.userEmail = stProfile.emailAddress; else stTemp.userEmail = "";

    stRecentObjects[qGetObjects.objectID] = stTemp;
    </cfscript>
</cfloop>