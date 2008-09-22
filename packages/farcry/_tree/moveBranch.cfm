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
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_tree/moveBranch.cfm,v 1.19 2005/10/28 04:10:04 paul Exp $
$Author: paul $
$Date: 2005/10/28 04:10:04 $
$Name: milestone_3-0-1 $
$Revision: 1.19 $

|| DESCRIPTION || 
$Description: deleteBranch Function $


|| DEVELOPER ||
$Developer: Paul Harrison (paul@enpresiv.com) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="No">

<cfparam name="arguments.pos" default="1"><!--- note: this param is optional. If not supplied branch will be moved to oldest child 
                                        of destination parent --->

<!--- set positive result --->
<cfset stTmp.bSucess = "true">
<cfset stTmp.message = "Branch pruned and grafted.">

<!--- <cftry>  --->
<!--- 
@objectid char(35), 	-- the object that is at the head of the branch to be moved
@dest_parentid char(35)	-- the node to which it will be attached as a child. note that this proc attaches it 
						-- as an only child or as the first child to the left of a group of siblings
@pos int = 1	        -- the position to which it will be moved, amongst siblings. 1 = extreme left, 
				        -- 2 = second from left, etc. if this is not supplied, assume 1 
 --->
 

	<cfscript>
		 //get the source parentid
		aSQL=arrayNew(1); //this is just an array to hold a record of all sql statements - gonna keep it in till this move tree bizo is all gud
		stReturn = structNew();
		q = getParentID(objectID=arguments.objectID, dsn=arguments.dsn);
		source_parentid = q.parentID;
		
		sql = "select objectID from #arguments.dbowner#nested_tree_objects where parentid = '#arguments.parentid#'";
		q = scriptQuery(sql=sql,dsn=arguments.dsn);
		destChildrenCount = q.recordCount;

		qDestDescendants = getDescendants(objectid=arguments.parentid,dsn=application.dsn);
		// we dont want to expand the dest node, if the souce node is a descendant - just flagging this status here
		sql = "select objectid from qDestDescendants where objectid = '#arguments.objectid#'";
		q = queryOfQuery(sql);
		bExpandDest = 1;
		if (q.recordCount)
			bExpandDest = 0;
		//also checking to see if destination is a descendant of sources parent, if so, we wont want to expand parentid of source		
		qSourceParentDesc = getDescendants(objectid=source_parentid,dsn=arguments.dsn);
		q = queryOfQuery2('select objectid',qSourceParentDesc,"where objectid = '#arguments.parentid#'");
		if (q.recordCount)
				bExpandDest = 0;
			
		// get the left and right of the object. this span defines the branch (object including its descendants). Also get typename, 
		//to differentiate between trees (there may be more than one tree, and we don't want to change the values of the other trees)
		sql = "select nleft, nright, typename from #arguments.dbowner#nested_tree_objects where objectid = '#arguments.objectid#'";
		q = scriptQuery(sql=sql, dsn=arguments.dsn);
				
		nleft = q.nleft;
		nright = q.nright;
		typename = q.typename;
	   
		//-- keep the branch (object and descendants of the object) ids safe in a temp table
		sql = "
		select objectid 
		from #arguments.dbowner#nested_tree_objects
		where nleft between #nleft# and #nright#
		and typename = '#typename#'";
	
		
		qBranchIDs = scriptQuery(sql=sql, dsn=arguments.dsn);
			
		//check destination is not a descendant of the source node
		q = queryofquery2("select count(*) AS ObjCount",qBranchIDs,"where objectid = '#arguments.parentid#'");	
		
		if (q.objCount GT 0)
		{
			throwerror(detail = 'The destination is part of the branch you are trying to move. This move is impossible.', errorcode='Move Branch');
		}	
		
		
		//-- get the number of branch members. Each one has 2 positions: left and right, so times it by 2  	
		
		count = qBranchIds.recordCount * 2;	
	
		if (NOT source_parentid IS arguments.parentid)
		{
			sql = "
				update #arguments.dbowner#nested_tree_objects
				set parentid = '#arguments.parentid#'
				where objectid = '#arguments.objectid#'"; 
			query(sql=sql, dsn=arguments.dsn);
			arrayAppend(aSQL,sql);	
		
			//check the level of the new parent. if its level is different than that of the original parent, change levels of 
			//object and all its descendants
					
			sql = "
			select nlevel from #arguments.dbowner#nested_tree_objects 
			where objectid = '#arguments.parentid#'";
			
			q = scriptQuery(sql=sql, dsn=arguments.dsn);
			dest_parent_level = q.nlevel;
			
			sql = "
				select nlevel from #arguments.dbowner#nested_tree_objects 
				where objectid = '#source_parentid#'";
			q = scriptQuery(sql=sql, dsn=arguments.dsn);
			source_parent_level = q.nlevel;
		
			//fix the levels of the branch that is moving
			leveldiff = dest_parent_level - source_parent_level;
			
			sql = "
				update #arguments.dbowner#nested_tree_objects 
				set nlevel = (nlevel + #leveldiff#)
				where nleft between #nleft# and #nright#
				and typename = '#typename#'";
			query(sql=sql, dsn=arguments.dsn);
			arrayAppend(aSQL,sql);	
		}    
		
		//contract the old parent and greater by this number, excluding the branch. 	
			
		sql = "
			update #arguments.dbowner#nested_tree_objects 				
			set	nleft = (nleft - #count#)
			where nleft > #nleft#
			and typename = '#typename#'";
		//to deal with scenarios where there are no children
		if(qBranchIds.recordCount)	
			sql = sql & "and objectid not in (#quotedValueList(qBranchIds.objectid)#)";
		
		query(sql=sql, dsn=arguments.dsn);	
		arrayAppend(aSQL,sql);
		
		sql = "
			update #arguments.dbowner#nested_tree_objects 				
			set	nright = (nright - #count#)
			where nright > #nleft# 
			and typename = '#typename#'";
		//to deal with scenarios where there are no children
		if(qBranchIds.recordCount)	
			sql = sql & "and objectid not in (#quotedValueList(qBranchIds.objectid)#)";	
					
		query(sql=sql, dsn=arguments.dsn);
		arrayAppend(aSQL,sql);	
			
		// if pos is 1 or less, assume it is 1. This means we move the branch to the top position amongst the siblings 
		// of the specified destination parent. 
		if (arguments.pos LT 2)
		{	
			sql = "select nleft + 1 AS nleft from #arguments.dbowner#nested_tree_objects where objectid = '#arguments.parentid#'";
			q = scriptQuery(sql=sql, dsn=arguments.dsn);
			dest_left = q.nleft;
		}	
		else
		{
			//work out the left hand value of the new child, by getting the right of the next older sibling, and adding one to it
			//make a temp table, put the right hand value of the first child of the parent into it
			rowindex = 1;
			sql = "
				select #rowindex# AS seq, min(nright) AS nright 
				FROM #arguments.dbowner#nested_tree_objects where parentID = '#arguments.parentid#' AND objectID <> '#arguments.objectid#'";
			qTemp = scriptQuery(sql=sql, dsn=arguments.dsn); 	
			//smoke up some sequence numbers for the latter
			for (i = 1;i LTE qTemp.recordCount;i=i+1)
			{
				querySetCell(qTemp,'seq',i,i);
			}
			
			minr = 1; 
			
			while (minr GT 0)
			{
				sql = "select nright from qTemp";
				q = queryofquery2("select nright",qTemp);
				sql = "
					select	min(nright) AS minr 
					from #arguments.dbowner#nested_tree_objects where parentid = '#arguments.parentID#' and objectid <> '#arguments.objectid#'
					and nright not in (#quotedValueList(qTemp.nright)#)";
				q = scriptQuery(sql=sql, dsn=arguments.dsn);	
				
				
				if (q.recordcount AND len(q.minr))
				{ 	
					rowindex = qTemp.recordCount + 1;
					minr = q.minr;
					queryAddRow(qTemp);
					querySetCell(qTemp,'nright',minr);
					querySetCell(qTemp,'seq',rowindex);
				}
				else
					minr = -1;
				
			}//end while
			// now get the nright hand value from the temp table that is directly before the position we want to insert the new 
			// child at, and assign it (+1)to the var @dest_left
			q = queryofquery2("select nright + 1 AS destLeft",qTemp,"where seq = #arguments.pos# - 1");	
			
			dest_left = q.destLeft;
		}//end if
	 
		// expand the new parent and lower siblings if they exist, and greater by the same number as we contracted the old parent 
		// by, excluding the branch. 
						
		
		sql = "
		update #arguments.dbowner#nested_tree_objects 
		set	nright = nright + #count#
		where nright > #dest_left#
		and typename = '#typename#'";
		
		//to deal with scenarios where there are no children
		if(qBranchIds.recordCount)	
			sql = sql & "and objectid not in (#quotedValueList(qBranchIds.objectid)#)";
		
		//dump(sql);
		query(sql=sql, dsn=arguments.dsn);
		arrayAppend(aSQL,sql);
		
		//sql = "select objectid,objectname,nlevel,nleft,nright from nested_tree_objects where objectid = '#arguments.parentID#'";
		//qpar = scriptQuery(sql=sql, dsn=arguments.dsn);	
		//dump(qpar);
	
		// deal with the parent's right hand value if it is a new parent, and has a different level 
		if (NOT source_parentid IS  arguments.parentid)
		{
			//get children count for dest node - if no children, we need  to expand parent
						
			if ((NOT source_parent_level IS dest_parent_level OR NOT destChildrenCount) AND bExpandDest)
			{
				sql = "
				update #arguments.dbowner#nested_tree_objects
				set 	nright = nright + #count#
				where objectid = '#arguments.parentid#'";
				query(sql=sql, dsn=arguments.dsn);
				arrayAppend(aSQL,sql);
			}
		}
				
			
		sql = "
			update #arguments.dbowner#nested_tree_objects 				
			set	nleft = nleft + #count#
			where nleft >= #dest_left#
			and typename = '#typename#'";
		
		//to deal with scenarios where there are no children
		if(qBranchIds.recordCount)	
			sql = sql & "and objectid not in (#quotedValueList(qBranchIds.objectid)#)";	
			
		query(sql=sql, dsn=arguments.dsn);
		arrayAppend(aSQL,sql);	
	
		// change the nlefts and nrights of the branch itself
		diff = dest_left - nleft;
		
		//to deal with scenarios where there are no children
		if(qBranchIds.recordCount)	
		{
			sql = "
				update #arguments.dbowner#nested_tree_objects 
				set	nleft = (nleft + #diff#),
				nright = (nright + #diff#)
				where 	objectid in (#quotedValueList(qBranchIds.objectid)#)";  
					
			query(sql=sql, dsn=arguments.dsn);
			arrayAppend(aSQL,sql);
		}	
		//Fixing a problem where when moving to bottom, the parent node nright value does not get correctly updated
		if (source_parentid IS  arguments.parentid)
		{   
			sql = "select objectid, objectname from #arguments.dbowner#nested_tree_objects
					where parentid =  '#arguments.parentid#'
					order by nleft";
					
			qChildren = scriptQuery(sql=sql,dsn=arguments.dsn);
			
			if(arguments.pos EQ qChildren.recordCount)
			{
			
			sql = "
				update #arguments.dbowner#nested_tree_objects
				set 	nright = nright + #count#
				where objectid = '#arguments.parentid#'";
			
			query(sql=sql, dsn=arguments.dsn);
			arrayAppend(aSQL,sql);
			}
		}
		stTmp.aSQL = aSQL;
	</cfscript>
	
	
	<!--- 
 	<cfcatch>
		<!--- set negative result --->
		<Cfdump var="#cfcatch#">
		<cfset stTmp.bSucess = "false">
		<cfset stTmp.message = cfcatch.detail>
	</cfcatch>

</cftry> 
 --->
<!--- set return variable --->
<cfset stReturn=stTmp>

<cfsetting enablecfoutputonly="no">