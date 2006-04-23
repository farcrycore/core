<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_tree/setOldest.cfm,v 1.7 2003/04/14 02:03:13 brendan Exp $
$Author: brendan $
$Date: 2003/04/14 02:03:13 $
$Name: b131 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: setOldest Function $
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<!--- set positive result --->
<cfset stTmp.bSucess = "true">
<cfset stTmp.message = "Oldest or only child node inserted.">

<cftry> 

	<cfscript>
		//make only child or oldest child (child is inserted in tree under parent in extreme left pos)
		// first make room. move other nodes up by 2
		stReturn = structNew();
		switch (application.dbType)
			{
				case "ora":
				{
					sql = "
						update nested_tree_objects
						set nright = nright + 2 
						where nright > (select nleft from nested_tree_objects where objectid = '#stArgs.parentid#' and typename = '#stArgs.typename#')
						and typename = '#stArgs.typeName#'";
					query(sql=sql, dsn=stArgs.dsn);	
					
					sql = "
						update nested_tree_objects
						set nleft = nleft + 2
						where nleft > (select nleft from nested_tree_objects where objectid = '#stArgs.parentid#' and typename = '#stArgs.typename#')
						and typename = '#stArgs.typeName#'";
					query(sql=sql, dsn=stArgs.dsn);	
					break;
				}
				
				case "mysql":
				{
					tempsql = "select nleft from nested_tree_objects where objectid = '#stArgs.parentid#' and typename = '#stArgs.typename#'";
					tempResult = query(sql=tempsql, dsn=stArgs.dsn);
					sql = "
						update nested_tree_objects
						set nright = nright + 2 
						where nright > #tempResult.nleft#
						and typename = '#stArgs.typeName#'";
					query(sql=sql, dsn=stArgs.dsn);	
					
					tempsql = "select nleft from nested_tree_objects where objectid = '#stArgs.parentid#' and typename = '#stArgs.typename#'";
					tempResult = query(sql=tempsql, dsn=stArgs.dsn);
					
					sql = "
						update nested_tree_objects
						set nleft = nleft + 2
						where nleft > #tempResult.nleft#
						and typename = '#stArgs.typeName#'";
					query(sql=sql, dsn=stArgs.dsn);	
					break;
				}
				
				default:
				{
					sql = "
						update nested_tree_objects
						set nright = nright + 2 
						where nright > (select nleft from nested_tree_objects where objectid = '#stArgs.parentid#' and typename = '#stArgs.typename#')
						and typename = '#stArgs.typeName#'";
					query(sql=sql, dsn=stArgs.dsn);	
					
					sql = "
						update nested_tree_objects
						set nleft = nleft + 2
						where nleft > (select nleft from nested_tree_objects where objectid = '#stArgs.parentid#' and typename = '#stArgs.typename#')
						and typename = '#stArgs.typeName#'";
					query(sql=sql, dsn=stArgs.dsn);	
				}
			}
		
		
		sql = "
			select nleft, nlevel
			from nested_tree_objects 
			where objectid = '#stArgs.parentid#'";
		q = query(sql=sql, dsn=stArgs.dsn);
		
		pleft = q.nleft;
		plevel = q.nlevel;
		
		switch (application.dbType)
			{
				case "ora":
				{
					sql = "
					insert nested_tree_objects (ObjectID, ParentID, ObjectName, TypeName, Nleft, Nright, Nlevel)
					select 	'#stArgs.objectid#', '#stArgs.parentid#', '#stArgs.objectName#', '#stArgs.typeName#', #pleft# + 1, #pleft# + 2,  #plevel# + 1";
					break;
				}
				
				case "mysql":
				{
					sql = "
					insert nested_tree_objects (ObjectID, ParentID, ObjectName, TypeName, Nleft, Nright, Nlevel)
					values ('#stArgs.objectid#', '#stArgs.parentid#', '#stArgs.objectName#', '#stArgs.typeName#', #pleft# + 1, #pleft# + 2,  #plevel# + 1)";	
					break;
				}
				
				default:
				{
					sql = "
					insert nested_tree_objects (ObjectID, ParentID, ObjectName, TypeName, Nleft, Nright, Nlevel)
					select 	'#stArgs.objectid#', '#stArgs.parentid#', '#stArgs.objectName#', '#stArgs.typeName#', #pleft# + 1, #pleft# + 2,  #plevel# + 1";
				}
			}
		query(sql=sql, dsn=stArgs.dsn);		
		</cfscript>

		<cfcatch>
			<!--- set negative result --->
			<cfset stTmp.bSucess = "false">
			<cfset stTmp.message = cfcatch>
		</cfcatch>

</cftry>

<cfset stReturn=stTmp>

<cfsetting enablecfoutputonly="no">