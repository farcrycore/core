<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_tree/setRootNode.cfm,v 1.12 2005/10/28 04:19:06 paul Exp $
$Author: paul $
$Date: 2005/10/28 04:19:06 $
$Name: milestone_3-0-1 $
$Revision: 1.12 $

|| DESCRIPTION || 
$Description: setRootNode Function $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au) $

|| ATTRIBUTES ||
$in: @objectid char(35), -- object UUID$
$in: @objectname varchar(255), -- object label$
$in: @typename varchar(255) -- object typ$
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<!--- set positive result --->
<cfset stTmp.bSucess = "true">
<cfset stTmp.message = "Root node inserted.">

<cfscript>
	stTmp.bSucess = 'true';
	stTmp.message = "Root node inserted.";
	if(NOT rootNodeExists(typename=arguments.typename, dsn=arguments.dsn))
	{	
		sql = "
		  insert into #arguments.dbowner#nested_tree_objects
		  (ObjectID, ParentID, ObjectName, TypeName, Nleft, Nright, Nlevel)
		  values  ('#arguments.objectid#',null, '#arguments.objectName#','#arguments.typeName#',1, 2, 0)" ; 
		query(sql=sql, dsn=arguments.dsn);
	}
	else
	{
		stTmp.bSucess = 'False';
		stTmp.message = "Root node insertion failes.";
	}
		
</cfscript>


<cfset stReturn=stTmp>

<cfsetting enablecfoutputonly="no">