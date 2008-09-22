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
$Header: /cvs/farcry/core/packages/farcry/_tree/setYoungest.cfm,v 1.14 2005/10/28 04:10:04 paul Exp $
$Author: paul $
$Date: 2005/10/28 04:10:04 $
$Name: milestone_3-0-1 $
$Revision: 1.14 $

|| DESCRIPTION || 
$Description: setYoungest Function $


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
	// escape any single quotes
	arguments.objectName = replace(arguments.objectName,"'","''","ALL");
	// make youngest child (child is inserted in tree under parent in extreme right pos)
	stReturn = structNew();
	sql = "
	select max(nright) AS nright from #arguments.dbowner#nested_tree_objects where parentid = '#arguments.parentid#'";
	q = scriptQuery(sql=sql, dsn=arguments.dsn);
	maxr = q.nRight;
	qCHildren = getChildren(objectid=arguments.parentid,dsn=arguments.dsn);
		   
	//if user has inadvertantly tried to insert youngest child when they should have used only child, try running the following:
	if (NOT qChildren.recordcount)
		setOldest(parentID=arguments.parentID, objectID=arguments.objectID, objectName=arguments.objectName, typeName=arguments.typeName, dsn=arguments.dsn);
	else {
		//first make room. move other nodes up by 2, where they are greater than the right hand of the youngest existing child
		sql = "
		update #arguments.dbowner#nested_tree_objects
		set nright = nright + 2 
		where nright > #maxr#
		and typeName = '#arguments.typeName#'";
		query(sql=sql, dsn=arguments.dsn);
		
		sql = "
		update #arguments.dbowner#nested_tree_objects
		set nleft = nleft + 2
		where nleft > #maxr#
		and typeName = '#arguments.typeName#'";
		query(sql=sql, dsn=arguments.dsn);
		
		sql = "		
			select nlevel
			from #arguments.dbowner#nested_tree_objects 
			where objectid = '#arguments.parentid#'";
		q = scriptQuery(sql=sql, dsn=arguments.dsn);	
		pLevel = q.nlevel;	
		
		switch (application.dbType)
			{
				case "ora":
				{
					sql = "
					insert into nested_tree_objects (ObjectID, ParentID, ObjectName, TypeName, Nleft, Nright, Nlevel)
					values ('#arguments.objectid#', '#arguments.parentid#', '#arguments.objectName#', '#arguments.typeName#', #maxr# + 1, #maxr# + 2,  #plevel# + 1)";
					break;
				}
				
				case "mysql":
				{
					sql = "
					insert nested_tree_objects (ObjectID, ParentID, ObjectName, TypeName, Nleft, Nright, Nlevel)
					values 	('#arguments.objectid#', '#arguments.parentid#', '#arguments.objectName#', '#arguments.typeName#', #maxr# + 1, #maxr# + 2,  #plevel# + 1)";
					break;
				}
				
				case "postgresql":
				{
					sql = "
					insert into nested_tree_objects (ObjectID, ParentID, ObjectName, TypeName, Nleft, Nright, Nlevel)
					values 	('#arguments.objectid#', '#arguments.parentid#', '#arguments.objectName#', '#arguments.typeName#', #maxr# + 1, #maxr# + 2,  #plevel# + 1)";
					break;
				}
				
				default:
				{
					sql = "
					insert #arguments.dbowner#nested_tree_objects (ObjectID, ParentID, ObjectName, TypeName, Nleft, Nright, Nlevel)
					select 	'#arguments.objectid#', '#arguments.parentid#', '#arguments.objectName#', '#arguments.typeName#', #maxr# + 1, #maxr# + 2,  #plevel# + 1";
				}
			}
			
		query(sql=sql, dsn=arguments.dsn);		
		
	}	

</cfscript>

<!--- set return variable --->
<cfset stReturn=stTmp>

<cfsetting enablecfoutputonly="no">