<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_tree/setOldest.cfm,v 1.13 2005/10/28 04:17:51 paul Exp $
$Author: paul $
$Date: 2005/10/28 04:17:51 $
$Name: milestone_3-0-1 $
$Revision: 1.13 $

|| DESCRIPTION || 
$Description: setOldest Function $


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
						update #arguments.dbowner#nested_tree_objects
						set nright = nright + 2 
						where nright > (select nleft from #arguments.dbowner#nested_tree_objects where objectid = '#arguments.parentid#' and typename = '#arguments.typename#')
						and typename = '#arguments.typeName#'";
					query(sql=sql, dsn=arguments.dsn);	
					
					sql = "
						update #arguments.dbowner#nested_tree_objects
						set nleft = nleft + 2
						where nleft > (select nleft from nested_tree_objects where objectid = '#arguments.parentid#' and typename = '#arguments.typename#')
						and typename = '#arguments.typeName#'";
					query(sql=sql, dsn=arguments.dsn);	
					break;
				}
				
				case "mysql":
				{
					tempsql = "select nleft from #arguments.dbowner#nested_tree_objects where objectid = '#arguments.parentid#' and typename = '#arguments.typename#'";
					tempResult = query(sql=tempsql, dsn=arguments.dsn);
					sql = "
						update nested_tree_objects
						set nright = nright + 2 
						where nright > #tempResult.nleft#
						and typename = '#arguments.typeName#'";
					query(sql=sql, dsn=arguments.dsn);	
					
					tempsql = "select nleft from #arguments.dbowner#nested_tree_objects where objectid = '#arguments.parentid#' and typename = '#arguments.typename#'";
					tempResult = query(sql=tempsql, dsn=arguments.dsn);
					
					sql = "
						update #arguments.dbowner#nested_tree_objects
						set nleft = nleft + 2
						where nleft > #tempResult.nleft#
						and typename = '#arguments.typeName#'";
					query(sql=sql, dsn=arguments.dsn);	
					break;
				}
				
				 case "postgresql":
				{
					tempsql = "select nleft from #arguments.dbowner#nested_tree_objects where objectid = '#arguments.parentid#' and typename = '#arguments.typename#'";
					tempResult = query(sql=tempsql, dsn=arguments.dsn);
					sql = "
						update #arguments.dbowner#nested_tree_objects
						set nright = nright + 2 
						where nright > #tempResult.nleft#
						and typename = '#arguments.typeName#'";
					query(sql=sql, dsn=arguments.dsn);	
					
					tempsql = "select nleft from #arguments.dbowner#nested_tree_objects where objectid = '#arguments.parentid#' and typename = '#arguments.typename#'";
					tempResult = query(sql=tempsql, dsn=arguments.dsn);
					
					sql = "
						update #arguments.dbowner#nested_tree_objects
						set nleft = nleft + 2
						where nleft > #tempResult.nleft#
						and typename = '#arguments.typeName#'";
					query(sql=sql, dsn=arguments.dsn);	
					break;
				}
				
				default:
				{
					sql = "
						update #arguments.dbowner#nested_tree_objects
						set nright = nright + 2 
						where nright > (select nleft from #arguments.dbowner#nested_tree_objects where objectid = '#arguments.parentid#' and typename = '#arguments.typename#')
						and typename = '#arguments.typeName#'";
					query(sql=sql, dsn=arguments.dsn);	
					
					sql = "
						update #arguments.dbowner#nested_tree_objects
						set nleft = nleft + 2
						where nleft > (select nleft from #arguments.dbowner#nested_tree_objects where objectid = '#arguments.parentid#' and typename = '#arguments.typename#')
						and typename = '#arguments.typeName#'";
					query(sql=sql, dsn=arguments.dsn);	
				}
			}
		
		
		sql = "
			select nleft, nlevel
			from #arguments.dbowner#nested_tree_objects 
			where objectid = '#arguments.parentid#'";
		q = query(sql=sql, dsn=arguments.dsn);
		
		pleft = q.nleft;
		plevel = q.nlevel;
		
		switch (application.dbType)
			{
				case "ora":
				{
					sql = "
					insert into #arguments.dbowner#nested_tree_objects (ObjectID, ParentID, ObjectName, TypeName, Nleft, Nright, Nlevel)
					values ('#arguments.objectid#', '#arguments.parentid#', '#arguments.objectName#', '#arguments.typeName#', #pleft# + 1, #pleft# + 2,  #plevel# + 1)";
					break;
				}
				
				case "mysql":
				{
					sql = "
					insert nested_tree_objects (ObjectID, ParentID, ObjectName, TypeName, Nleft, Nright, Nlevel)
					values ('#arguments.objectid#', '#arguments.parentid#', '#arguments.objectName#', '#arguments.typeName#', #pleft# + 1, #pleft# + 2,  #plevel# + 1)";	
					break;
				}
				
				case "postgresql":
				{
					sql = "
					insert into nested_tree_objects (ObjectID, ParentID, ObjectName, TypeName, Nleft, Nright, Nlevel)
					values ('#arguments.objectid#', '#arguments.parentid#', '#arguments.objectName#', '#arguments.typeName#', #pleft# + 1, #pleft# + 2,  #plevel# + 1)";	
					break;
				}
				
				default:
				{
					sql = "
					insert #arguments.dbowner#nested_tree_objects (ObjectID, ParentID, ObjectName, TypeName, Nleft, Nright, Nlevel)
					select 	'#arguments.objectid#', '#arguments.parentid#', '#arguments.objectName#', '#arguments.typeName#', #pleft# + 1, #pleft# + 2,  #plevel# + 1";
				}
			}
		query(sql=sql, dsn=arguments.dsn);		
		</cfscript>

		<cfcatch>
			<!--- set negative result --->
			<cfset stTmp.bSucess = "false">
			<cfset stTmp.message = cfcatch>
			<cfdump var="#cfcatch#"><cfabort>
		</cfcatch>

</cftry>

<cfset stReturn=stTmp>

<cfsetting enablecfoutputonly="no">