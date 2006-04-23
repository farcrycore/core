<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/tree.cfc,v 1.49 2005/10/28 04:19:30 paul Exp $
$Author: paul $
$Date: 2005/10/28 04:19:30 $
$Name: milestone_3-0-0 $
$Revision: 1.49 $

|| DESCRIPTION ||
$Description: nested tree cfc $


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
	<cfargument name="dbowner" required="false" type="string" default="#application.dbowner#">
	<cfset var stTmp = structNew()>
	<cfset var stReturn = structNew()>
	<cfset var sql = ''>
	<cfset var q = ''>
	<cfset var oldleft = ''>
	<cfset var typename = ''>
	<cfset var nLeftSql = ''>
	<cfset var qNLeft = ''>
	<cfset var count = ''>
	<cfinclude template="_tree/deleteBranch.cfm">
	<cfreturn stReturn>
</cffunction>

<cffunction name="deleteTree" output="No">
	<cfargument name="typename" type="string" required="true">
	<cfargument name="dsn" type="string" required="false" default="#application.dsn#">
	<cfargument name="dbowner" required="no" type="string" default="#application.dbowner#">
	<cfquery datasource="#arguments.dsn#">
		delete from #arguments.dbowner#nested_tree_objects
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
	<cfargument name="dbowner" required="no" type="string" default="#application.dbowner#">
	<cfset var parentID = ''>
	<cfset var qnode = ''>
	<cfset var rowindex = 1>
	<cfset var qParentIDs = ''>
	<cfset var sql = ''>
	<cfset var ancestors = ''>
	<cfset var q = ''>
	<cfset var objID = ''>
	<cfset var nLev = -1>
	<cfset var qSelf = ''>
	<cfinclude template="_tree/getAncestors.cfm">
	<cfreturn qReturn>
</cffunction>

<cffunction name="getChildren" access="public" returntype="query" hint="Get children of the specified node." output="No">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	<cfargument name="objectid" required="yes" type="UUID">
	<cfargument name="dbowner" required="no" type="string" default="#application.dbowner#">
	<cfset var sql = ''>
	<cfset var qChildren = ''>
	<cfset var qReturn = ''>
	<cfinclude template="_tree/getChildren.cfm">
	<cfreturn qReturn>
</cffunction>

<!--- 
	<cffunction name="getDescendants" access="public" returntype="query" hint="Get the entire branch" output="yes">
	<cfargument name="objectid" required="yes" type="UUID">
	<cfargument name="depth" required="false" type="string" default="0">
	<cfargument name="lColumns" required="false" type="string">
	<cfargument name="aFilter" required="false" type="array">
	<cfargument name="dsn" required="false" type="string" default="#application.dsn#">
	<cfargument name="bIncludeSelf" required="false" type="boolean" default="0" hint="set this to 1 if you want to include the objectid you are passing">
	<cfset var qreturn = "">
	<cfset var sql = structNew()>
	<cfset var nlevel = 34567890> <!--- unlikely that we should ever have a table this deep --->
	<cfset var q = ''>
	<cfset var i = 1>
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
</cffunction> --->

<cffunction name="getDescendants" access="public" output="false" returntype="query" hint="Get the entire branch with the option to hide empty nodes from the results">
    <cfargument name="objectid" required="yes" type="UUID" />
    <cfargument name="depth" required="false" type="string" default="0" />
    <cfargument name="lColumns" required="false" type="string" default="" />
    <cfargument name="aFilter" required="false" type="array" default="#arrayNew(1)#" />
    <cfargument name="dsn" required="false" type="string" default="#application.dsn#" />
    <cfargument name="bIncludeSelf" required="false" type="boolean" default="0" hint="set this to 1 if you want to include the objectid you are passing" />
    <cfargument name="bHideEmptyNodes" required="false" type="boolean" hint="Hides empty nodes from results." default="0" />
    <cfargument name="l404Check" required="false" type="string" default="externalLink,dmHTML,dmLink,dmInclude,dmFlash,dmImage,dmFile" />
    <cfargument name="dbowner" required="false" type="string" default="#application.dbowner#" />
	<cfset var qreturn = "" />
    <cfset var sql = structNew() />
    <cfset var nlevel = 0 /> <!--- unlikely that we should ever have a table this deep --->
    <cfset var q = '' />
    <cfset var i = 1 />
    <cfset var columns = "" />
	<cfset var stLocal = StructNew()>

    <!--- Get descendants of supplied object, optionally to a supplied depth (1 = 1 level down, etc)
    returns a recordset of ids and labels, in order of "birth". If no rowcount, no descendants
    get details of node passed in --->

    <cfquery datasource="#arguments.dsn#" name="q">
     SELECT nleft, nright, typename, nlevel
     FROM #arguments.dbowner#nested_tree_objects
     where objectid = '#arguments.objectid#'
    </cfquery>

    <!--- determine additional columns --->
    <cfset columns = "" />
    <cfif len(arguments.lColumns)>
      <cfset columns = "," & arguments.lColumns />
    </cfif>

	<cfif q.typename EQ "categories">
		<cfset stLocal.primaryKeyField = "categoryid">
	<cfelse>
		<cfset stLocal.primaryKeyField = "objectid">
	</cfif>
    <cfif q.recordCount>
    	<!--- set reset nlevel based on arguments.depth --->
   		<cfset nlevel = q.nlevel + arguments.depth />
		<cfif StructKeyExists(Application.config.general, "categoryCacheTimespan") AND Application.config.general.categoryCacheTimespan NEQ "0">
			<cfset stLocal.cachewithinTime = CreateTimeSpan(0,Application.config.general.categoryCacheTimespan,0,0)>
		<cfelse>
			<cfset stLocal.cachewithinTime = 0>
		</cfif>

<cfsavecontent variable="stLocal.sql"><cfoutput>
SELECT	ntm.objectid,ntm.parentid,ntm.typename,ntm.nleft,ntm.nright,ntm.nlevel,ntm.ObjectName #columns#
FROM 	#arguments.dbowner#nested_tree_objects ntm
 INNER JOIN #arguments.dbowner##q.typename# t ON t.#stLocal.primaryKeyField# = ntm.objectid
	AND ntm.nleft<cfif arguments.bIncludeSelf>>=<cfelse>></cfif>#q.nleft#
	AND ntm.nleft < #q.nright#
	AND ntm.typename = '#q.typename#'<cfif arguments.depth GT 0>
	AND ntm.nlevel <= #nlevel#</cfif>
	<cfif arrayLen(arguments.afilter)><cfloop from="1" to="#arrayLen(arguments.afilter)#" index="i">
	AND #replace(arguments.afilter[i],"''","'","all")#</cfloop></cfif>
ORDER BY ntm.nleft</cfoutput>
</cfsavecontent>

		<cfif stLocal.cachewithinTime EQ 0>
<cfquery datasource="#arguments.dsn#" name="qReturn">#preservesinglequotes(stLocal.sql)#</cfquery>
		<cfelse>
<cfquery datasource="#arguments.dsn#" name="qReturn" cachedwithin="#stLocal.cachewithinTime#">#preservesinglequotes(stLocal.sql)#</cfquery>
		</cfif>

    <cfelse>
      <cfthrow message="#arguments.objectid# is not a valid objectID for getDescendants()">
    </cfif>
	
    <cfreturn qReturn />
  </cffunction>

<cffunction name="getSiblings" access="public" returntype="query" hint="Get siblings for the node specified.  That is, all nodes with the same parent." output="yes">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	<cfargument name="objectid" required="yes" type="UUID">
	<cfargument name="lColumns" required="no" type="string" default="">
	<cfargument name="aFilter" required="no" type="array" default="#arrayNew(1)#">
	<cfargument name="bIncludeSelf" required="no" type="boolean" default="0" hint="set this to 1 if you want to include the objectid you are passing">
	<cfset var qParent = ''>
	<cfset var temp = ''>
	<cfset var qReturn = ''>
	<cfinclude template="_tree/getSiblings.cfm">
	<cfreturn qReturn>
</cffunction>
<cffunction name="getNode" access="public" returntype="query" hint="Gets any given node in the nested tree model" output="No">
	<cfargument name="objectid" required="yes" type="UUID">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	<cfargument name="dbowner" required="false" type="string" default="#application.dbowner#">
	<cfset var q = ''>
	<cfquery name="q" datasource="#arguments.dsn#">
		SELECT * from #arguments.dbowner#nested_tree_objects where objectid = '#arguments.objectid#'
	</cfquery>
	<cfreturn q>
</cffunction>
<cffunction name="getSecondaryNav" access="public" returntype="query" hint="Get the Secondary Nav" output="No">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	<cfargument name="objectid" required="yes" type="UUID">
	<cfargument name="dbowner" required="false" type="string" default="#application.dbowner#">
	<cfset var q = ''>
	<cfset var nlevel = ''>
	<cfset var sql = ''>
	<cfset var nleft = ''>
	<cfset var nright = ''>
	<cfset var qReturn = ''>
	<cfset var leaf = ''>
	<cfset var qParent = ''>
	<cfset var parent = ''>
	<cfset var grandpa = ''>
	<cfset var secondaryNav = ''>
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
	<cfargument name="dbowner" required="false" type="string" default="#application.dbowner#">
	<cfset var q = ''>
	<cfquery datasource="#arguments.dsn#" name="q">
		select parentid from #arguments.dbowner#nested_tree_objects
    	where objectid  = '#arguments.objectid#'
	</cfquery>
	<cfreturn q>
</cffunction>
<cffunction name="getRootNode" access="public" returntype="query" hint="Get root node for the specified typename." output="No">
	<cfargument name="dsn" required="false" type="string" default="#application.dsn#">
	<cfargument name="typename" required="yes" type="string">
	<cfargument name="dbowner" required="false" type="string" default="#application.dbowner#">
	
	<cfset var qRoot = ''>
	<cfset var qReturn = ''>
	<cfinclude template="_tree/getRootNode.cfm">
	<cfreturn qReturn>
</cffunction>

<cffunction name="moveBranch" access="public" returntype="struct" hint="Prune and graft a node and the branch beneath it." output="No">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	<cfargument name="objectid" required="yes" type="UUID" hint="The object that is at the head of the branch to be moved.">
	<cfargument name="parentid" required="yes" type="UUID" hint="The node to which it will be attached as a child. Note this function attaches the node as an only child or as the first child to the left of a group of siblings.">
	<cfargument name="pos" required="false" default="1" type="numeric" hint="The position in the tree">
	<cfargument name="dbowner" required="no" type="string" default="#application.dbowner#">
	
	<cfset var aSQL = arrayNew(1)>
	<cfset var bExpandDest = 1>
	<cfset var count = ''>
	<cfset var destChildrenCount = ''>
	<cfset var dest_left = ''>
	<cfset var dest_parent_level = ''>
	<cfset var diff = ''>	
	<cfset var i = 1>
	<cfset var minr = 1>
	<cfset var nleft = ''>
	<cfset var nright = ''>
	<cfset var q = ''>
	<cfset var qChildren = ''>
	<cfset var qTemp = ''>
	<cfset var rowindex = 1>
	<cfset var stTmp = structNew()>
	<cfset var stReturn = structNew()>
	<cfset var sql = ''>
	<cfset var source_parentid = ''>
	<cfset var typename = ''>
	
	<cfinclude  template="_tree/moveBranch.cfm">
	<cfreturn stReturn>
</cffunction>

<cffunction name="numberOfNodesAtObjectLevel" hint="The number of nodes at the same level as an object" output="No">
	<cfargument name="objectid" required="true" type="uuid">
    <cfargument name="dsn" required="no" type="string" default="#application.dsn#">
	<cfargument name="dbowner" required="no" type="string" default="#application.dbowner#">
	<cfset var q = ''>
	<cfset var sql = ''>
	<cfset var objCount = 0>
	<cfscript>
	sql = "select count(*) + 1 AS objCount from #arguments.dbowner#nested_tree_objects where parentid = '#arguments.objectid#'";
	q = query(sql=sql, dsn=arguments.dsn);
	objCount = q.objCount;
	</cfscript>
	<cfreturn objCount>
</cffunction>

<cffunction name="rootNodeExists" hint="Checks to see if a root node of a given type already exists" output="No">
	<cfargument name="typename" required="true">
    <cfargument name="dsn" required="false" type="string" default="#application.dsn#">
	<cfargument name="dbowner" required="false" type="string" default="#application.dbowner#">
	<cfset var bRootNodeExists = false>
	<cfset var q = ''>
	<cfset var sql = ''>
	<cfscript>
	bRootNodeExists = false;
	sql = "select * from #arguments.dbowner#nested_tree_objects where nlevel = 0 and typename = '#arguments.typename#'";
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
	<cfargument name="dbowner" required="false" type="string" default="#application.dbowner#">
	
	<cfset var stTmp = structNew()>
	<cfset var stReturn = structNew()>
	<cfset var sql = ''>

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
	<cfargument name="dbowner" required="no" type="string" default="#application.dbowner#">
	
	<cfset var rowindex = 1>	
	<cfset var stTmp = structNew()>
	<cfset var stReturn = structNew()>
	<cfset var sql = ''>
	<cfset var q = ''>
	<cfset var qNrightSeq = ''>
	<cfset var minr = 1>
	<cfset var maxr = ''>
	<cfset var plevel = ''>
	
	<cfinclude template="_tree/setChild.cfm">

	<cfreturn stReturn>
</cffunction>

<cffunction name="setOldest" access="public" returntype="struct" hint="Set node as only or oldest child. That is, a child that appears first in the list of children under the parent (ie. the oldest). Use only for new objects" output="No">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	<cfargument name="parentid" required="yes" type="UUID">
	<cfargument name="objectid" required="yes" type="UUID">
	<cfargument name="objectname" required="yes" type="string">
	<cfargument name="typename" required="yes" type="string">
	<cfargument name="dbowner" required="no" type="string" default="#application.dbowner#">
	
	<cfset var stTmp = structNew()>
	<cfset var stReturn = structNew()>
	<cfset var sql = ''>
	<cfset var q = ''>
	<cfset var tempsql = ''>
	<cfset var tempResult = ''>
	<cfset var pleft = ''>
	<cfset var plevel = ''>

	<cfinclude template="_tree/setOldest.cfm">

	<cfreturn stReturn>
</cffunction>

<cffunction name="setYoungest" access="public" returntype="struct" hint="Set node as youngest child. That is, a child that appears last in the list of children under the parent (ie. the youngest)." output="No">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	<cfargument name="parentid" required="yes" type="UUID">
	<cfargument name="objectid" required="yes" type="UUID">
	<cfargument name="objectname" required="yes" type="string">
	<cfargument name="typename" required="yes" type="string">
	<cfargument name="dbowner" required="no" type="string" default="#application.dbowner#">

	<cfset var qChildren = ''>
	<cfset var stTmp = structNew()>
	<cfset var stReturn = structNew()>
	<cfset var sql = ''>
	<cfset var q = ''>
	<cfset var maxr = ''>
	<cfset var plevel = ''>

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
	<cfargument name="dbowner" required="yes" type="string" default="#application.dbowner#">
	
	<cfset var sql = ''>
	<cfset var q = ''>
	<cfset var vlObjectID = ''>
	<cfset var bloodline = ''>
	<cfset var qReturn = ''>

	<cfinclude template="_tree/getBloodLine.cfm">
	<cfreturn qReturn>
</cffunction>

<cffunction name="getLeaves" access="public" returntype="array" hint="Gets the leaf objects of the nodes passed in">
	<cfargument name="lNodeIds" type="string" required="true" hint="list of node ids, can be a single node id or just one">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	<cfargument name="dbowner" required="false" type="string" default="#application.dbowner#">
	
	<cfset var q=0>
	<cfset var aObjs = arraynew(1)>
	<cfset var stObj = structnew()>
	<cfquery datasource="#arguments.dsn#" name="q">
		SELECT r.* 
		FROM         
	 		#arguments.dbOwner#dmNavigation_aObjectIDs o INNER JOIN 
        	refObjects r ON r.objectid = o.data 
		WHERE  o.objectid IN ('#ListChangeDelims(arguments.lNodeIds,"','",",")#')
	</cfquery>
	<cfloop query="q">
		<cfset sTypePath = evaluate("application.types.#q.TypeName#.typePath")>
		<cfset oType = createObject("component", "#sTypePath#")>
		<cfset stObj = oType.getData(q.ObjectID)>
		<cfset arrayappend(aObjs,stObj)>
	</cfloop>
	<cfreturn aObjs>
</cffunction>

<cffunction name="rebuildTree" access="public" returntype="numeric" hint="Fixes tree using parentid/objectid relationship. If nodes returned is 0 then no tree found for typename" output="No">
	<cfargument name="typename" required="yes" type="string" default="dmNavigation">
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	<cfargument name="dbowner" required="false" type="string" default="#application.dbowner#">
	<cfset var qRootNode = ''>
	<cfset var nNodes = 1>
	
	<cfquery name="qRootNode" datasource="#application.dsn#">
		select objectid
		from #arguments.dbowner#nested_tree_objects 
		where (parentid =  ''  or parentid is null) and typename = '#arguments.typename#'
	</cfquery>
	<cfdump var="#qRootNode#">

	
	<cfif qRootNode.recordcount>
		<cfset nNodes = fixBranch(qRootNode.objectid,2,1,arguments.dsn)>
		<!--- Everything below has been updated, now update root --->
		<cfquery name="qUpdateChild" datasource="#arguments.dsn#">
			UPDATE #arguments.dbowner#nested_tree_objects set nLeft = 1, nRight = #nNodes#, nLevel = 0
			WHERE objectid = '#qRootNode.objectid#'
		</cfquery>	
	</cfif>
	<cfreturn nNodes>
</cffunction>

<cffunction name="fixBranch" access="public" returntype="numeric" hint="Fixes tree from passed root node down. Returns number of nodes below it." output="No">
	<cfargument name="parentid" required="yes" type="string">
	<cfargument name="nLeft" required="yes" type="numeric">
	<cfargument name="nLevel" required="yes" type="numeric">	
	<cfargument name="dsn" required="yes" type="string" default="#application.dsn#">
	<cfset var nRight = 0>
	<cfset var nNewLeft = 0>
	<cfset var nReturn = "">
	
	<cfset var qChildren = ''>

	<cfset arguments.dsn = "#application.dsn#">

	<cfinclude template="_tree/fixBranch.cfm">
	<cfreturn nReturn>
</cffunction>
</cfcomponent>