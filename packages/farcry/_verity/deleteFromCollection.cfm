<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_verity/deleteFromCollection.cfm,v 1.1 2003/09/24 02:26:55 brendan Exp $
$Author: brendan $
$Date: 2003/09/24 02:26:55 $
$Name: b201 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: deletes an object from a verity collection$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

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
<cftry>
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
	<cfcatch></cfcatch>
</cftry>