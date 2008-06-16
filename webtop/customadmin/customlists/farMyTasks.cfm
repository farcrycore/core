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
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| DESCRIPTION ||
$Description: Workflow Task Definitions. $

|| DEVELOPER ||
$Developer: Matthew Bryant (mbryant@daemon.com.au) $
--->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<!--- set up page header --->
<admin:header title="Workflow Task Definitions" />

<cfoutput><h1>My Tasks</h1></cfoutput>

<cfquery datasource="#application.dsn#" name="qMyTasks">
SELECT * FROM farWorkflow
WHERE bWorkflowComplete = 0
AND bActive = 1
AND objectid IN (
	SELECT parentID from farWorkFlow_aTaskIDs
	WHERE data IN (
		SELECT objectid from farTask
		WHERE bComplete = 0 
		AND taskDefID IN (
			SELECT parentID FROM farTaskDef_aRoles
			WHERE data IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#application.security.getCurrentRoles()#">)
		)
		and (
			userID = ''
			OR userID = '#session.dmProfile.objectid#'
		)
	)
 ) 
</cfquery>

<cfloop query="qMyTasks">
	<skin:view objectid="#qMyTasks.objectid#" typename="farWorkflow" template="displayTeaserLinkToOverview" />
</cfloop>

<admin:footer />