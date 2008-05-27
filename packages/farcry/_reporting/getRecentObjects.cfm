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