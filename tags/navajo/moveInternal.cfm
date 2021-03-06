<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">
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
$Header: /cvs/farcry/core/tags/navajo/moveInternal.cfm,v 1.21 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.21 $

|| DESCRIPTION || 
$Description: $


|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: url.objectId$
$in: url.direction$
$out:$
--->
<!--- set long timeout for template to prevent data-corruption on incomplete tree.moveBranch() --->
<cfsetting requesttimeout="90">

<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj" />
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4" />
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry" />

<cfinclude template="/farcry/core/webtop/includes/cfFunctionWrappers.cfm">

<cfparam name="url.objectId">
<cfparam name="url.direction">

<q4:contentobjectget objectId="#url.objectId#" r_stObject="stobj">

<cfscript>
	typename = stObj.typename;
	oNav = createObject("component", application.types.dmNavigation.typePath);
	if (stObj.typename IS 'dmNavigation')
	{
		qGetParent = application.factory.oTree.getParentID(objectID = stObj.objectID);
		parentObjectID = qGetParent.parentID;	
	}
	else
	{
		// likely to be a parent object with aObjects property (eg. dmHTML, dmNews)
		qGetParent = oNav.getParent(objectid=stObj.objectID);
		parentObjectID = qGetParent.parentID;
	}	
	//get permissions for this action
	iState = 1; //temp till i implement cfc dmsec
</cfscript>

<!--- get parent object --->
<q4:contentobjectget objectId="#parentObjectId#" r_stObject="stParentObject">

<!--- 
<cftry> --->
<!--- exclusive lock tree.moveBranch() to prevent corruption --->
<cflock name="moveBranchNTM" type="EXCLUSIVE" timeout="3" throwontimeout="Yes">

<cfif iState NEQ 1><cfoutput>
<script type="text/javascript">
	alert("#application.rb.getResource('sitetree.messages.noModifyNodePermission@text','You do not have permission to modify the node.')#");
</script></cfoutput>
<cfelse>
	<cfif len(parentObjectID)>
		<cfif stObj.typename IS "dmnavigation">
			<cfset qGetChildren = application.factory.oTree.getChildren(dsn=application.dsn,objectid=parentObjectID) />
			<cfset bottom = qGetChildren.recordCount />
			<cfloop query="qGetChildren">
				<cfif qGetChildren.objectid[currentrow] IS stObj.objectID>
					<cfset thisPosition = currentrow />
					<cfbreak />
				</cfif>
			</cfloop>
			
			<!--- get the new position --->
			<cfif url.direction is "up" AND thisPosition NEQ 1>
				<cfset newPosition = thisPosition - 1 />
			<cfelseif url.direction is "down" AND thisPosition LT bottom>
				<cfset newPosition = thisPosition + 1 />
			<cfelseif url.direction is "top">
				<cfset newPosition = 1 />
			<cfelseif url.direction eq "bottom">
				<cfset newPosition = bottom />
			</cfif>
			
			<!--- make the move --->
			<cfset application.factory.oTree.moveBranch(dsn=application.dsn,objectid=stobj.objectid,parentid=parentobjectid,pos=newposition) />
			<farcry:logevent object="#url.objectid#" type="sitetree" event="movenode" notes="Object moved to child position #newposition#" />

		<cfelse>
			<cfset key = "aObjectIds" />
		
			<!--- find the position of the object within the parent that we are moving  --->
			<cfset pos = ListFind(ArrayToList(stParentObject[key]), stobj.objectID) />
		
			<!--- find the objects new position  --->
			<cfif url.direction EQ "up" AND pos NEQ 1>
				<cfset newPos = pos - 1 />
				<cfset arraySwap( stParentObject[key], pos, newPos ) />
			<cfelseif url.direction eq "down" AND (pos lt ArrayLen(stParentObject[key]))>
				<cfset newPos = pos + 1 />
				<cfset arraySwap( stParentObject[key], pos, newPos ) />
			<cfelseif url.direction eq "top">
				<cfset newPos = 1 />
				<cfset arrayDeleteAt( stParentObject[key], pos ) />
				<cfset arrayInsertAt( stParentObject[key], newPos, url.objectID ) />
			<cfelseif url.direction eq "bottom">
				<cfset newPos = ArrayLen(stParentObject[key]) />
				<cfset arrayDeleteAt( stParentObject[key], pos ) />
				<cfset arrayAppend( stParentObject[key], url.objectID ) />
			</cfif>
			
			<!--- update the object --->
			<cfset stParentObject.datetimecreated = createODBCDate("#datepart('yyyy',stParentObject.datetimecreated)#-#datepart('m',stParentObject.datetimecreated)#-#datepart('d',stParentObject.datetimecreated)#") />
			<cfset stParentObject.datetimelastupdated = createODBCDate(now()) />
			<cfset oType = createobject("component", application.types[stParentObject.typename].typePath) />
			<cfset oType.setData(stProperties=stParentObject,auditNote="object moved to child position #newpos#") />
			
			<farcry:logevent objectid="#url.objectid#" type="sitetree" event="movenode" notes="Object moved to child position #newpos#" />

		</cfif>
	</cfif>

</cfif>

</cflock>


<cfsetting enablecfoutputonly="No">