<cfsetting enablecfoutputonly="yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_verity/deleteFromCollection.cfm,v 1.2 2005/07/25 09:37:33 geoff Exp $
$Author: geoff $
$Date: 2005/07/25 09:37:33 $
$Name: milestone_3-0-0 $
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