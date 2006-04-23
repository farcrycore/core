<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/tree.cfc,v 1.28 2003/10/26 23:32:52 brendan Exp $
$Author: brendan $
$Date: 2003/10/26 23:32:52 $
$Name: b201 $
$Revision: 1.28 $

|| DESCRIPTION ||
$Description: nested tree cfc $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayname="Nested Tree Model" hint="Database tree management based on Joe Celko's nested tree model.">

<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm"><!--- changed from /farcry/includes/etc dan --->

<cffunction name="deleteBranch" access="public" returntype="struct" hint="Delete a node and the branch beneath it." output="No">
	<cfargument name="dsn" required="no" type="string" default="#application.dsn#">
	<cfargument name="objectid" required="yes" type="UUID">

	<cfinclude template="_tree/deleteBranch.cfm">

	<cfreturn stReturn>
</cffunction>

<cffunction name="deleteTree" output="No">
	<cfargument name="typename" type="string" required="true">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">

	<cfquery datasource="#arguments.dsn#">
	delete from nested_tree_objects
    where typename = '#arguments.typename#'
	</cfquery>
</cffunction>

<cffunction name="deployTree" access="public" returntype="struct" hint="Deploy tree table for MSSQL7+." output="No">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">

	<cfinclude template="_tree/deployTreeTables.cfm">
	<cfreturn stReturn>
</cffunction>


<cffunction name="getAncestors" access="public" hint="Get a query of objects ordered from the root node to the current node." returntype="query" output="No">
	<cfargument name="objectid" required="yes" type="UUID">
	<cfargument name="bIncludeSelf" required="no" type="boolean" default="false">
	<cfargument name="dsn" required="no" type="string" default="#application.dsn#">
	<cfargument name="nLevel" required="no" type="numeric">
	<cfset  parentID = ''>
	<cfset  nlevel = -1>
	<cfset  rowindex = 1>

	<cfinclude template="_tree/getAncestors.cfm">

	<cfreturn qReturn>
</cffunction>



<cffunction name="getChildren" access="public" returntype="query" hint="Get children of the specified node." output="No">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	<cfargument name="objectid" required="yes" type="UUID">

	<cfinclude template="_tree/getChildren.cfm">

	<cfreturn qReturn>
</cffunction>


<cffunction name="getDescendants" access="public" returntype="query" hint="Get the entire branch" output="No">
	<cfargument name="objectid" required="yes" type="UUID">
	<cfargument name="depth" required="no" type="string" default="0">
	<cfargument name="lColumns" required="no" type="string">
	<cfargument name="aFilter" required="no" type="array">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	<cfargument name="bIncludeSelf" required="no" type="boolean" default="0" hint="set this to 1 if you want to include the objectid you are passing">
	<cfset var qreturn = "">
	<cfset var sql = structNew()>
	<cfset var nlevel = 34567890> <!--- unlikely that we should ever have a table this deep --->

	<cfscript>
	//get descendants of supplied object, optionally to a supplied depth (1 = 1 level down, etc)
	//returns a recordset of ids and labels, in order of "birth". If no rowcount, no descendants

	// get details of node passed in
	sql.statement = "
		SELECT nleft, nright, typename, nlevel
		from nested_tree_objects
		where objectid = '#arguments.objectid#'";
	q = query(sql=sql.statement, dsn=arguments.dsn);

	// set reset nlevel based on arguments.depth
	if (arguments.depth GT 0)
		nlevel = q.nlevel + arguments.depth ;

	if (isDefined("arguments.lcolumns") OR isDefined("arguments.aFilter")) {
		if (q.recordCount) {
			// determine additional columns
			sql.columns="";
			if (isDefined("arguments.lcolumns") AND len(arguments.lcolumns))
				sql.columns="," & arguments.lcolumns;
			// build filter
			sql.filter="";
			if (isDefined("arguments.aFilter") AND arraylen(arguments.aFilter)) {
				For (i=1;i LTE arraylen(arguments.aFilter); i=i+1) {
					sql.filter=sql.filter & 'AND ' & arguments.aFilter[i];
				}
			}
			sql.statement = "
				select n.objectid,n.parentid,n.typename,n.nleft,n.nright,n.nlevel,n.ObjectName #sql.columns#
				FROM nested_tree_objects n, #q.typename# t
				where
				t.objectid = n.objectid
				and nleft";
			if(arguments.bincludeself)
				sql.statement = sql.statement & ">= ";
			else
				sql.statement = sql.statement & "> ";
			sql.statement = sql.statement & "#q.nleft#
				and nleft < #q.nright#
				and typename = '#q.typename#'
				and nlevel <= #nlevel#
				#sql.filter#
				order by nleft";
			qReturn = query(sql=sql.statement, dsn=arguments.dsn);
			//dump(qReturn);
		} else {
			throwerror("#arguments.objectid# is not a valid objectID for getDescendants()");
		}
	} else {
	// efficient sql for minimal arguments
		if (q.recordCount) {
			sql.statement = "
				select * from nested_tree_objects
				where nleft";
			if(arguments.bincludeself)
				sql.statement = sql.statement & ">= ";
			else
				sql.statement = sql.statement & "> ";
			sql.statement = sql.statement & "  #q.nleft#
				and nleft < #q.nright#
				and typename = '#q.typename#'
				and nlevel <= #nlevel#
				order by nleft";
			qReturn = query(sql=sql.statement, dsn=arguments.dsn);
			//dump(qReturn);
		} else {
			qReturn = queryNew('objectid,parentid,typename,nleft,nright,nlevel,ObjectName');
		}
	}
	</cfscript>

	<cfreturn qReturn>
</cffunction>



<cffunction name="getSiblings" access="public" returntype="query" hint="Get siblings for the node specified.  That is, all nodes with the same parent." output="yes">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	<cfargument name="objectid" required="yes" type="UUID">
	<cfargument name="lColumns" required="no" type="string" default="">
	<cfargument name="aFilter" required="no" type="array" default="#arrayNew(1)#">

	<cfinclude template="_tree/getSiblings.cfm">

	<cfreturn qReturn>
</cffunction>



<cffunction name="getNode" access="public" returntype="query" hint="Gets any given node in the nested tree model" output="No">
	<cfargument name="objectid" required="yes" type="UUID">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">

	<cfquery name="q" datasource="#arguments.dsn#">
		SELECT * from nested_tree_objects where objectid = '#arguments.objectid#'
	</cfquery>
	<cfreturn q>
</cffunction>


<cffunction name="getSecondaryNav" access="public" returntype="query" hint="Get the Secondary Nav" output="No">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	<cfargument name="objectid" required="yes" type="UUID">

	<cfinclude template="_tree/getSecondaryNav.cfm">
	<!---
	qReturn
	nleft,
	nlevel,
	objectid,
	objectname
    ordered by nlevel
	--->
	<cfreturn qReturn>
</cffunction>

<cffunction name="getParentID" access="public" returntype="query" hint="Get an objects parent ID in the NTM" output="No">
	<cfargument name="objectid" type="string" required="true">
	<cfargument name="dsn" required="false" default="#application.dsn#">

	<cfquery datasource="#arguments.dsn#" name="q">
		select parentid from nested_tree_objects
    	where objectid  = '#arguments.objectid#'
	</cfquery>

	<cfreturn q>
</cffunction>


<cffunction name="getRootNode" access="public" returntype="query" hint="Get root node for the specified typename." output="No">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	<cfargument name="typename" required="yes" type="string">

	<cfinclude template="_tree/getRootNode.cfm">
	<cfreturn qReturn>
</cffunction>


<cffunction name="moveBranch" access="public" returntype="struct" hint="Prune and graft a node and the branch beneath it." output="No">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	<cfargument name="objectid" required="yes" type="UUID" hint="The object that is at the head of the branch to be moved.">
	<cfargument name="parentid" required="yes" type="UUID" hint="The node to which it will be attached as a child. Note this function attaches the node as an only child or as the first child to the left of a group of siblings.">
	<cfargument name="pos" required="false" default="1" type="numeric" hint="The position in the tree">

	<cfinclude  template="_tree/moveBranch.cfm">

	<cfreturn stReturn>
</cffunction>


<cffunction name="numberOfNodesAtObjectLevel" hint="The number of nodes at the same level as an object" output="No">
	<cfargument name="objectid" required="true" type="uuid">
    <cfargument name="dsn" required="no" type="string" default="#application.dsn#">

	<cfscript>
	sql = "select count(*) + 1 AS objCount from nested_tree_objects where parentid = '#arguments.objectid#'";
	q = query(sql=sql, dsn=arguments.dsn);
	objCount = q.objCount;
	</cfscript>
	<cfreturn objCount>

</cffunction>

<cffunction name="rootNodeExists" hint="Checks to see if a root node of a given type already exists" output="No">
	<cfargument name="typename" required="true">
    <cfargument name="dsn" required="false" type="string" default="#application.dsn#">

	<cfscript>
	bRootNodeExists = false;
	sql = "select * from nested_tree_objects where nlevel = 0 and typename = '#arguments.typename#'";
	q = query(sql=sql, dsn=arguments.dsn);
	if (q.recordCount) bRootNodeExists = true;
	</cfscript>

	<cfreturn bRootNodeExists>

</cffunction>

<cffunction name="setRootNode" access="public" returntype="struct" hint="Set root node for a specific object type." output="No">
	<cfargument name="dsn" required="no" type="string" default="#application.dsn#">
	<cfargument name="objectid" required="yes" type="UUID">
	<cfargument name="objectname" required="yes" type="string">
	<cfargument name="typename" required="yes" type="string">

	<cfinclude template="_tree/setRootNode.cfm">

	<cfreturn stTmp>
</cffunction>


<cffunction name="setChild" access="public" returntype="struct" hint="Set child node." output="No">
	<cfargument name="dsn" required="false" type="string" default="#application.dsn#">
	<cfargument name="parentid" required="yes" type="UUID" hint="The tree node that is the parent.">
	<cfargument name="objectid" required="yes" type="UUID" hint="The child node to be inserted.">
	<cfargument name="objectname" required="yes" type="string" hint="The child node object label.">
	<cfargument name="typename" required="yes" type="string" hint="The child node object type.">
	<cfargument name="pos" required="yes" type="numeric" hint="The position the new child node will take amongst the siblings. 1 = extreme left, 2 = second from left etc.">

	<cfinclude template="_tree/setChild.cfm">

	<cfreturn stReturn>
</cffunction>

<cffunction name="setOldest" access="public" returntype="struct" hint="Set node as only or oldest child. That is, a child that appears first in the list of children under the parent (ie. the oldest). Use only for new objects" output="No">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	<cfargument name="parentid" required="yes" type="UUID">
	<cfargument name="objectid" required="yes" type="UUID">
	<cfargument name="objectname" required="yes" type="string">
	<cfargument name="typename" required="yes" type="string">

	<cfinclude template="_tree/setOldest.cfm">

	<cfreturn stReturn>
</cffunction>

<cffunction name="setYoungest" access="public" returntype="struct" hint="Set node as youngest child. That is, a child that appears last in the list of children under the parent (ie. the youngest)." output="No">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	<cfargument name="parentid" required="yes" type="UUID">
	<cfargument name="objectid" required="yes" type="UUID">
	<cfargument name="objectname" required="yes" type="string">
	<cfargument name="typename" required="yes" type="string">

	<cfinclude template="_tree/setYoungest.cfm">

	<cfreturn stReturn>
</cffunction>


<cffunction name="getBloodLine" access="public" returntype="query" hint="Get the ancestors, the siblings of each older generation, the siblings and the children of a given objectid." output="No">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	<cfargument name="jointable" required="yes" type="string"><!--- the table to join to, so as to bring back other useful stuff (must have a field named objectid, to join on) --->
	<cfargument name="ObjectID" required="yes" type="string">
	<cfargument name="levelsabove" required="yes" type="numeric" default="2">
	<cfargument name="levelsbelow" required="no" type="numeric" default="1">
	<cfargument name="status" required="no" type="string" default=""><!--- if passed, will filter the joined table by the field in it named "status", by whatever value is passed in this param (so don't pass it if the table doesn't have a 'status' field)  --->

	<cfinclude template="_tree/getBloodLine.cfm">
	<cfreturn qReturn>
</cffunction>

</cfcomponent>