<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_tree/setChild.cfm,v 1.10 2005/10/28 04:10:04 paul Exp $
$Author: paul $
$Date: 2005/10/28 04:10:04 $
$Name: milestone_3-0-1 $
$Revision: 1.10 $

|| DESCRIPTION || 
$Description: setChild Function $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: @parentid char(35), -- the nav object that is the parent$
$in: @objectid char(35),  -- the child to be inserted$
$in: @objectName  varchar(255), -- the child object label$
$in: @typeName varchar(255), -- the object type$
$in: @pos int -- the position the new child will take amongst the siblings. 1 = extreme left, 2 = second from left etc.$
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<!--- set positive result --->
<cfset stTmp.bSucess = "true">
<cfset stTmp.message = "Child node inserted.">

<cftry> 
	<cfscript>

	//if @pos < 2, we will assume they meant to put it 1, which means user has specified the child should go in at the extreme left. use the proc we already have for this
    if (arguments.pos LT 2) 
	     setOldest(parentid=arguments.parentid, objectid=arguments.objectid, objectName=arguments.objectName, typeName=arguments.typeName, dsn=arguments.dsn);
	// the following case is: user has specified child should go in at extreme right, or has specified an out-of-range position. 
    // If it is out-of-range, give them the benefit of the doubt and put it in at the extreme right. Use the proc we already have for this
    else if (arguments.pos GTE numberOfNodesAtObjectLevel(objectID=arguments.parentid, dsn=arguments.dsn))
		setYoungest(parentid=arguments.parentid, objectid=arguments.objectid, objectName=arguments.objectName, typeName=arguments.typeName, dsn=arguments.dsn);
   	else
	{
		rowIndex = 1;
    	
      	// make a temp table, put the right hand value of the first child of the parent into it
    	sql = "
			select #rowindex# AS seq, min(nright) as nright
  		    from #arguments.dbowner#nested_tree_objects where parentid = '#arguments.parentid#'";
    	qNrightSeq = query(sql=sql, dsn=arguments.dsn);
    	minr = 1; // dummy value to start loop
    
    	// each iteration of the following loop inserts the next youngest child's right hand value into the temp table until we run 
    	// out of kids
		while (minr GT 0)
		{
			sql = "select nright FROM qNrightSeq";
			q = queryofquery(sql=sql);
			
			sql = "
			select  min(nright) AS minr 
			from #arguments.dbowner#nested_tree_objects where parentid = '#arguments.parentid#'
			and nright not in (#quotedValueList(q.nright)#)";
			q = query(sql=sql, dsn=arguments.dsn);
		
			if (q.recordCount)
			{
				rowindex = rowindex + 1;
				queryAddRow(qNrightSeq);
				querySetCell(qNrightSeq,'seq',rowindex,rowindex);
				querySetCell(qNrightSeq,'nright',q.minr,rowindex);
				
			}
		}
    	// now get the right hand value from the temp table that is directly before the position we want to insert the new child at
		sql = 
			"select nright from qNrightSeq
			where seq = #arguments.pos# - 1";
		q = queryofquery(sql=sql);	
		maxr = q.nright;
	   
		
		//first make room. move other nodes up by 2, where they are greater than the right hand of the older sibling of the new child
		sql = 
			"update #arguments.dbowner#nested_tree_objects
			set nright = nright + 2 
			where nright > #maxr#
			and typename = '#arguments.typename#'";
		query(sql=sql, dsn=arguments.dsn);
		sql = "
			update #arguments.dbowner#nested_tree_objects
			set nleft = nleft + 2
			where nleft > #maxr#
			and typename = '#arguments.typename#'";
		query(sql=sql, dsn=arguments.dsn);
		sql = "
			select nlevel
			from #arguments.dbowner#nested_tree_objects 
			where objectid = '#arguments.parentid#'";
		q = query(sql=sql, dsn=arguments.dsn);		
		pLevel = q.Plevel;	
		
		sql ="
		   insert #arguments.dbowner#nested_tree_objects (ObjectID, ParentID, ObjectName, TypeName, Nleft, Nright, Nlevel)
		  values ('#arguments.objectid#', '#arguments.parentid#', '#arguments.objectName#', '#arguments.typeName#', #maxr# + 1, #maxr# + 2,  #plevel# + 1)";  
		query(sql=sql, dsn=arguments.dsn);	  
	}
	</cfscript>
	
	<cfcatch>
		<!--- set negative result --->
		<cfset stTmp.bSucess = "false">
		<cfset stTmp.message = cfcatch.detail>
	</cfcatch>

</cftry> 

<!--- set return variable --->
<cfset stReturn=stTmp>

<cfsetting enablecfoutputonly="no">