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
$Header: /cvs/farcry/core/packages/farcry/_tree/getBloodLine.cfm,v 1.21 2005/10/28 03:24:04 paul Exp $
$Author: paul $
$Date: 2005/10/28 03:24:04 $
$Name: p300_b113 $
$Revision: 1.21 $

|| DESCRIPTION ||
$Description: getBloodline Function $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">
<cfif arguments.maxdepth gt 0>
   <cfset maxDepth =  "and nlevel <= #arguments.maxdepth#">
<cfelse>
   <cfset maxDepth =  "">
</cfif>
<cfscript>
	// allow joining to tables that dont have an objectID field
	if(jointable EQ "categories")
		joinTableObjectIDField = "categoryID";
	else
		joinTableObjectIDField = "objectID";

	// put all the objectids of the ancestors, plus the objectid of the object in question,
	qTemp = getAncestors(objectID=arguments.objectID, dsn=arguments.dsn);

	sql = "select objectid, objectname, nlevel 	from #arguments.dbowner#nested_tree_objects where objectid = '#arguments.objectid#'";
	q = query(sql=sql, dsn=arguments.dsn);

	queryAddRow(qTemp);
	querySetCell(qTemp,'objectid',q.objectid);
	querySetCell(qTemp,'objectname',q.objectname);
	querySetCell(qTemp,'nlevel',q.nlevel);


	if (isDefined("arguments.status") AND len(arguments.status))
		statusClause = "where j.status in ('#ListChangeDelims(arguments.Status,"','",",")#')";

	else
		statusClause = "where 1 = 1";
	levelsabove = arguments.levelsabove + 1;

	sql = "select objectid from qTemp order by nlevel desc";
	q = queryOfQuery(sql,levelsabove+1);
	vlParentID = quotedvalueList(q.objectid); //value list of objectids

	sql = "select  objectid from qTemp	order by nlevel desc";
	q = queryOfQuery(sql,levelsabove);
	vlObjectID = quotedValueList(q.objectid);

	//this gets the levels right
	//build query
	// Changed by bowden to use (+) syntax rather than inner join.
    //    Oracle didn't support the join syntax until version 9
	if (application.dbtype is "ora") {
		sql = "select distinct nto.*, j.objectid
				from #arguments.dbowner#nested_tree_objects nto
					, #arguments.dbowner##arguments.joinTable# j
		#statusClause#
		and nto.objectid = j.#joinTableObjectIDField# (+)
		and ( nto.parentid in (#vlParentID#)
		or nto.objectid in (#vlObjectID#)	)
		#maxDepth#
		order by nto.nleft";
	} else {
		sql = "select distinct nto.*, j.objectid from #arguments.dbowner#nested_tree_objects nto
		inner join #arguments.dbowner##arguments.joinTable# j on nto.objectid = j.#joinTableObjectIDField# #statusClause#
		and ( nto.parentid in (#vlParentID#)
		or nto.objectid in (#vlObjectID#)	)
		#maxDepth#
		order by nto.nleft";
	}

	bloodline = query(sql=sql, dsn=arguments.dsn);
</cfscript>

<!--- set return variable --->
<cfset qReturn=bloodline>

<cfsetting enablecfoutputonly="no">