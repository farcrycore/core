<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_tree/moveBranch.cfm,v 1.10 2003/07/26 03:44:31 paul Exp $
$Author: paul $
$Date: 2003/07/26 03:44:31 $
$Name: b131 $
$Revision: 1.10 $

|| DESCRIPTION || 
$Description: deleteBranch Function $
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="No">

<cfparam name="stArgs.pos" default="1"><!--- note: this param is optional. If not supplied branch will be moved to oldest child 
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
		q = getParentID(objectID=stArgs.objectID, dsn=stArgs.dsn);
		source_parentid = q.parentID;
		
		sql = "select objectID from nested_tree_objects where parentid = '#stArgs.parentid#'";
		q = query(sql=sql,dsn=stArgs.dsn);
		destChildrenCount = q.recordCount;

		
			
		// get the left and right of the object. this span defines the branch (object including its descendants). Also get typename, 
		//to differentiate between trees (there may be more than one tree, and we don't want to change the values of the other trees)
		sql = "select nleft, nright, typename from nested_tree_objects where objectid = '#stArgs.objectid#'";
		q = query(sql=sql, dsn=stArgs.dsn);
		//dump(q);
		
		
		nleft = q.nleft;
		nright = q.nright;
		typename = q.typename;
	   
		//-- keep the branch (object and descendants of the object) ids safe in a temp table
		sql = "
		select objectid 
		from nested_tree_objects
		where nleft between #nleft# and #nright#
		and typename = '#typename#'";
		
		qBranchIDs = query(sql=sql, dsn=stArgs.dsn);
		
	
		//check destination is not a descendant of the source node
		sql = "
			select count(*) AS ObjCount from qBranchIDs where objectid = '#stArgs.parentid#'";
		q = queryofquery(sql);	
		
		if (q.objCount GT 0)
		{
			throwerror(detail = 'The destination is part of the branch you are trying to move. This move is impossible.', errorcode='Move Branch');
		}	
		
		
		//-- get the number of branch members. Each one has 2 positions: left and right, so times it by 2  	
		/*sql = "
			select count(*)* 2 as objCount from qBranchIDs";
		q = queryofquery(sql);*/
		count = qBranchIds.recordCount * 2;	
	
		if (NOT source_parentid IS stArgs.parentid)
		{
			sql = "
				update nested_tree_objects
				set parentid = '#stArgs.parentid#'
				where objectid = '#stArgs.objectid#'"; 
			query(sql=sql, dsn=stArgs.dsn);
			arrayAppend(aSQL,sql);	
		
			//check the level of the new parent. if its level is different than that of the original parent, change levels of 
			//object and all its descendants
					
			sql = "
			select nlevel from nested_tree_objects 
			where objectid = '#stArgs.parentid#'";
			
			q = query(sql=sql, dsn=stArgs.dsn);
			dest_parent_level = q.nlevel;
			
			sql = "
				select nlevel from nested_tree_objects 
				where objectid = '#source_parentid#'";
			q = query(sql=sql, dsn=stArgs.dsn);
			source_parent_level = q.nlevel;
		
			//fix the levels of the branch that is moving
			leveldiff = dest_parent_level - source_parent_level;
			
			sql = "
				update nested_tree_objects 
				set nlevel = (nlevel + #leveldiff#)
				where nleft between #nleft# and #nright#
				and typename = '#typename#'";
			query(sql=sql, dsn=stArgs.dsn);
			arrayAppend(aSQL,sql);	
		}    
		
		//contract the old parent and greater by this number, excluding the branch. 	
	
		/*sql = "select objectid from qbranchids";
		q = queryofquery(sql);
		vl = quotedValueList(q.objectid);*/
		
		sql = "
			update nested_tree_objects 				
			set	nleft = (nleft - #count#)
			where nleft > #nleft# and objectid not in
			(#quotedValueList(qBranchIds.objectid)#)
			and typename = '#typename#'";
		//dump(sql);	
		query(sql=sql, dsn=stArgs.dsn);	
		arrayAppend(aSQL,sql);
		
		sql = "
			update nested_tree_objects 				
			set	nright = (nright - #count#)
			where nright > #nleft# and objectid not in
			(#quotedValueList(qBranchIds.objectid)#)
			and typename = '#typename#'";
		//dump(sql);	
		query(sql=sql, dsn=stArgs.dsn);
		arrayAppend(aSQL,sql);	
		/*sql = "select objectid,objectname,nlevel,nleft,nright from nested_tree_objects where objectid = '#stArgs.parentID#'";
		qpar = query(sql=sql, dsn=stArgs.dsn);	
		dump(qpar);*/
		
	
		// if pos is 1 or less, assume it is 1. This means we move the branch to the top position amongst the siblings 
		// of the specified destination parent. 
		if (stArgs.pos LT 2)
		{	
			sql = "select nleft + 1 AS nleft from nested_tree_objects where objectid = '#stArgs.parentid#'";
			q = query(sql=sql, dsn=stArgs.dsn);
			dest_left = q.nleft;
		}	
		else
		{
			//work out the left hand value of the new child, by getting the right of the next older sibling, and adding one to it
			//make a temp table, put the right hand value of the first child of the parent into it
			rowindex = 1;
			sql = "
				select #rowindex# AS seq, min(nright) AS nright 
				FROM nested_tree_objects where parentID = '#stArgs.parentid#' AND objectID <> '#stArgs.objectid#'";
			qTemp = query(sql=sql, dsn=stArgs.dsn); 	
			//smoke up some sequence numbers for the latter
			for (i = 1;i LTE qTemp.recordCount;i=i+1)
			{
				querySetCell(qTemp,'seq',i,i);
			}
			//dump(qtemp); 
			
			minr = 1; 
			
			while (minr GT 0)
			{
				sql = "select nright from qTemp";
				q = queryofquery(sql);
				sql = "
					select	min(nright) AS minr 
					from nested_tree_objects where parentid = '#stArgs.parentID#' and objectid <> '#stArgs.objectid#'
					and nright not in (#quotedValueList(qTemp.nright)#)";
				q = query(sql=sql, dsn=stArgs.dsn);	
				
				
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
			//dump(qTemp);	
			sql = "
				select nright + 1 AS destLeft from qTemp where seq = #stArgs.pos# - 1";
			q = queryofquery(sql);	
			
			dest_left = q.destLeft;
		}//end if
	 
		// expand the new parent and lower siblings if they exist, and greater by the same number as we contracted the old parent 
		// by, excluding the branch. 
		
		/*sql = "
		select objectid from qBranchIds";
		q = queryofquery(sql);
		vl = quotedValueList(q.ObjectID);*/
		//dump(qBranchIds);
		
		
		
		
		sql = "
		update nested_tree_objects 
		set	nright = nright + #count#
		where nright > #dest_left#
		and objectid not in (#quotedValueList(qBranchIds.objectid)#)
		and typename = '#typename#'";
		//dump(sql);
		query(sql=sql, dsn=stArgs.dsn);
		arrayAppend(aSQL,sql);
		
		//sql = "select objectid,objectname,nlevel,nleft,nright from nested_tree_objects where objectid = '#stArgs.parentID#'";
		//qpar = query(sql=sql, dsn=stArgs.dsn);	
		//dump(qpar);
	
		// deal with the parent's right hand value if it is a new parent, and has a different level 
		if (NOT source_parentid IS  stArgs.parentid)
		{
			//get children count for dest node - if no children, we need  to expand parent
			
			
			if (NOT source_parent_level IS dest_parent_level OR NOT destChildrenCount )
			{
				sql = "
				update nested_tree_objects
				set 	nright = nright + #count#
				where objectid = '#stArgs.parentid#'";
				query(sql=sql, dsn=stArgs.dsn);
				arrayAppend(aSQL,sql);
			}
		}
		
		
		
			
		sql = "
			update nested_tree_objects 				
			set	nleft = nleft + #count#
			where nleft >= #dest_left#
			and objectid not in (#quotedValueList(qBranchIds.objectid)#)
			and typename = '#typename#'";
		query(sql=sql, dsn=stArgs.dsn);
		arrayAppend(aSQL,sql);	
	
		// change the nlefts and nrights of the branch itself
		diff = dest_left - nleft;
		
		sql = "
			update nested_tree_objects 
			set	nleft = (nleft + #diff#),
			nright = (nright + #diff#)
			where 	objectid in (#quotedValueList(qBranchIds.objectid)#)";  
		query(sql=sql, dsn=stArgs.dsn);
		arrayAppend(aSQL,sql);
		//Fixing a problem where when moving to bottom, the parent node nright value does not get correctly updated
		if (source_parentid IS  stArgs.parentid)
		{   
			sql = "select objectid, objectname from nested_tree_objects
					where parentid =  '#stArgs.parentid#'
					order by nleft";
					
			qChildren = query(sql=sql,dsn=stArgs.dsn);
			
			if(stArgs.pos EQ qChildren.recordCount)
			{
			
			sql = "
				update nested_tree_objects
				set 	nright = nright + #count#
				where objectid = '#stArgs.parentid#'";
			
			query(sql=sql, dsn=stArgs.dsn);
			arrayAppend(aSQL,sql);
			}
		}
		stTmp.aSQL = aSQL;
	</cfscript>
	
	<!--- update friendly urls --->
	<cfif application.config.plugins.fu>
		<!--- Create an instance of the component --->
		<cfobject component="#application.packagepath#.farcry.fu" name="fu">
		<!--- call create method --->
		<cfset fu.createALL()>	
	</cfif>
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