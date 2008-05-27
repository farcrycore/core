<cfsetting enablecfoutputonly="yes">
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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_verity/deleteFromCollection.cfm,v 1.2 2005/07/25 09:37:33 geoff Exp $
$Author: geoff $
$Date: 2005/07/25 09:37:33 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: deletes an object from a verity collection$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->
<cftry>
<!--- Get collection listings --->
<cfcollection action="LIST" name="qcollections">
<cfset stVerity=structNew()>
<cfloop query="qCollections">
	<cfscript>
	stTmp=structNew();
	stTmp.name=qCollections.name;
	stTmp.path=qCollections.path;
	stTmp.collection=qCollections.name;
	structInsert(stVerity, qCollections.name, stTmp);
	</cfscript>
</cfloop>		
<!--- delete from verity --->
	<cfif structKeyExists(stVerity, "#arguments.collection#")>
		<!--- set up query object to pass to verity --->
		<cfset qDelete = queryNew("objectid")>
		<cfset queryAddRow(qDelete,1)>
		<cfset querySetCell(qDelete,"objectid",arguments.objectid)>
		
		<cflock name="verity" timeout="60">
			<cfindex 
				collection="#arguments.collection#" 
		    	action="delete"
				type="custom"
				query="qDelete"
    			key="objectid">
		</cflock>		
	</cfif>	
	<cfcatch>
		<!--- suppress output but report issue --->
		<cftrace category="farcry.verity" type="warning" text="deleteFromCollection() failed." var="cfcatch.Detail" />
		<cflog application="true" file="farcry" type="warning" text="deleteFromCollection() failed; #cfcatch.Detail#" />
	</cfcatch>
</cftry>
<cfsetting enablecfoutputonly="no">