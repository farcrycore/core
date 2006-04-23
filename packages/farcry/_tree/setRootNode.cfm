<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_tree/setRootNode.cfm,v 1.8 2003/04/11 01:29:27 brendan Exp $
$Author: brendan $
$Date: 2003/04/11 01:29:27 $
$Name: b131 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: setRootNode Function $
$TODO: $

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
	if(NOT rootNodeExists(typename=stArgs.typename, dsn=stArgs.dsn))
	{	
		sql = "
		  insert nested_tree_objects
		  (ObjectID, ParentID, ObjectName, TypeName, Nleft, Nright, Nlevel)
		  values  ('#stArgs.objectid#',null, '#stArgs.objectName#','#stArgs.typeName#',1, 2, 0)" ; 
		query(sql=sql, dsn=stArgs.dsn);
	}
	else
	{
		stTmp.bSucess = 'False';
		stTmp.message = "Root node insertion failes.";
	}
		
</cfscript>


<cfset stReturn=stTmp>

<cfsetting enablecfoutputonly="no">