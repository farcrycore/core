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
$Header: /cvs/farcry/core/packages/farcry/_tree/setRootNode.cfm,v 1.12 2005/10/28 04:19:06 paul Exp $
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
		scriptQuery(sql=sql, dsn=arguments.dsn);
	}
	else
	{
		stTmp.bSucess = 'False';
		stTmp.message = "Root node insertion failes.";
	}
		
</cfscript>

<cfset stProperties = structNew() />
<cfset stProperties.objectid = arguments.objectid />
<cfset stProperties.typename = arguments.typename />
<cfset stProperties.alias = 'root' />

<cfset stResult = createObject("component", application.stcoapi[arguments.typename].packagepath).createData(stproperties="#stproperties#") />

<cfset stReturn=stTmp>

<cfsetting enablecfoutputonly="no">