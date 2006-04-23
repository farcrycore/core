<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_tree/setYoungest.cfm,v 1.6 2003/04/14 00:33:41 brendan Exp $
$Author: brendan $
$Date: 2003/04/14 00:33:41 $
$Name: b131 $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: setYoungest Function $
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: @parentid char(35), -- the nav object that is the parent$
$in: @typeName varchar(255), -- the object type$
$in: @objectName  varchar(255), -- the object label$
$in: @objectid char(35)  -- the child to be inserted$
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<!--- set positive result --->
<cfset stTmp.bSucess = "true">
<cfset stTmp.message = "Node inserted as youngest child.">

<cfscript>
	// make youngest child (child is inserted in tree under parent in extreme right pos)
	stReturn = structNew();
	sql = "
	select max(nright) AS nright from nested_tree_objects where parentid = '#stArgs.parentid#'";
	q = query(sql=sql, dsn=stArgs.dsn);
	maxr = q.nRight;
	
	   
	//if user has inadvertantly tried to insert youngest child when they should have used only child, try running the following:
	if (maxr EQ '')	setOldest(parentID=stArgs.parentID, objectID=stArgs.objectID, objectName=stArgs.objectName, typeName=stArgs.typeName, dsn=stArgs.dsn);
	else {
		//first make room. move other nodes up by 2, where they are greater than the right hand of the youngest existing child
		sql = "
		update nested_tree_objects
		set nright = nright + 2 
		where nright > #maxr#
		and typeName = '#stArgs.typeName#'";
		query(sql=sql, dsn=stArgs.dsn);
		
		sql = "
		update nested_tree_objects
		set nleft = nleft + 2
		where nleft > #maxr#
		and typeName = '#stArgs.typeName#'";
		query(sql=sql, dsn=stArgs.dsn);
		
		sql = "		
			select nlevel
			from nested_tree_objects 
			where objectid = '#stArgs.parentid#'";
		q = query(sql=sql, dsn=stArgs.dsn);	
		pLevel = q.nlevel;	
		
		switch (application.dbType)
			{
				case "ora":
				{
					sql = "
					insert nested_tree_objects (ObjectID, ParentID, ObjectName, TypeName, Nleft, Nright, Nlevel)
					select 	'#stArgs.objectid#', '#stArgs.parentid#', '#stArgs.objectName#', '#stArgs.typeName#', #maxr# + 1, #maxr# + 2,  #plevel# + 1";
					break;
				}
				
				case "mysql":
				{
					sql = "
					insert nested_tree_objects (ObjectID, ParentID, ObjectName, TypeName, Nleft, Nright, Nlevel)
					values 	('#stArgs.objectid#', '#stArgs.parentid#', '#stArgs.objectName#', '#stArgs.typeName#', #maxr# + 1, #maxr# + 2,  #plevel# + 1)";
					break;
				}
				
				default:
				{
					sql = "
					insert nested_tree_objects (ObjectID, ParentID, ObjectName, TypeName, Nleft, Nright, Nlevel)
					select 	'#stArgs.objectid#', '#stArgs.parentid#', '#stArgs.objectName#', '#stArgs.typeName#', #maxr# + 1, #maxr# + 2,  #plevel# + 1";
				}
			}
			
		query(sql=sql, dsn=stArgs.dsn);		
		
	}	

</cfscript>

<!--- set return variable --->
<cfset stReturn=stTmp>

<cfsetting enablecfoutputonly="no">