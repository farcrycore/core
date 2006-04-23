<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/versioning.cfc,v 1.11 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.11 $

|| DESCRIPTION || 
$Description: versioning cfc $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayName="Object Versioning" hint="Functions to handle versioning of objects">

<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">
	
	<cffunction name="archiveObject" access="public" returntype="struct" hint="Archives any farcry object">
		<cfargument name="objectID" type="uuid" required="true">
		<cfargument name="typename" type="string" required="false">
			
 		<cfinclude template="_versioning/archiveObject.cfm">
		
		<cfreturn stResult>
	</cffunction>

	<cffunction name="sendObjectLive" access="public" returntype="struct" hint="Sends a versioned object with draft live.Archives existing live object if it exists and deletes old live object">
		<cfargument name="objectID" type="uuid" required="true">
		<cfargument name="stDraftObject"  type="struct" required="true" hint="the draft stuct to be updated">
		<cfargument name="typename" type="string" required="false" hint="Providing typename avoids a type-lookup from the objectid, offering a slight performance increase.">
		<cfargument name="bCopyDraftContainers" type="boolean" required="false" default="true" hint="Containers configured for the draft object will be copied when the object is sent live.">
		
 		<cfinclude template="_versioning/sendObjectLive.cfm">
		
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="rollbackArchive" access="public" returntype="struct" hint="Sends a archived object live and archives current version">
		<cfargument name="objectID" type="uuid" required="true">
		<cfargument name="archiveID"  type="uuid" required="true" hint="the archived object to be sent back live">
		<cfargument name="typename" type="string" required="false">
		
 		<cfinclude template="_versioning/rollbackArchive.cfm">
		
		<cfreturn stResult>
	</cffunction>
	
	<cffunction name="getVersioningRules" access="public" returntype="struct" hint="Returns a structure of boolean rules concerning the editing of farcry objects">
		<cfargument name="objectID" type="uuid" required="true">
		<cfargument name="typename" type="string" required="false">
		
 		<cfinclude template="_versioning/versioningRules.cfm">
						
		<cfreturn stRules>
	</cffunction>	 
	
	<cffunction name="getArchives" access="public" returntype="query" hint="returns all archives for a given object">
		<cfargument name="objectID" type="uuid" required="true">

 		<cfinclude template="_versioning/getArchives.cfm">
		
		<cfreturn qArchives>
	</cffunction>
	
	<cffunction name="getArchiveDetail" access="public" returntype="query" hint="returns one archive">
		<cfargument name="objectID" type="uuid" required="true">

 		<cfinclude template="_versioning/getArchiveDetail.cfm">
		
		<cfreturn qArchives>
	</cffunction>
	
	<cffunction name="checkEdit" access="public" hint="See if we can edit this object">
		<cfargument name="stRules" type="struct" required="true">
		<cfargument name="stObj" type="struct" required="true">
		
 		<cfinclude template="_versioning/checkEdit.cfm">
	
	</cffunction>
	
	<!--- Approval emails --->
	<cffunction name="approveEmail_approved" access="public" hint="Sends out email informing lastupdated user that object has been approved">
		<cfargument name="objectId" type="UUID" required="true" hint="The ObjectId of object that has had status changed">
		<cfargument name="comment" type="string" required="true" hint="Comments that were entered when status was changed">
		
 		<cfinclude template="_versioning/approveEmail_approved.cfm">
	</cffunction>
	
	<cffunction name="approveEmail_pending" access="public" hint="Sends out email to list of approvers to approve/decline object">
		<cfargument name="objectId" type="UUID" required="true" hint="The ObjectId of object that has had status changed">
		<cfargument name="comment" type="string" required="true" hint="Comments that were entered when status was changed">
		<cfargument name="lApprovers" type="string" required="true" hint="List of approvers to send email to" default="all">
		
 		<cfinclude template="_versioning/approveEmail_pending.cfm">
	</cffunction>
	
	<cffunction name="approveEmail_draft" access="public" hint="Sends out email informing lastupdated user that object has been sent back to draft">
		<cfargument name="objectId" type="UUID" required="true" hint="The ObjectId of object that has had status changed">
		<cfargument name="comment" type="string" required="true" hint="Comments that were entered when status was changed">
		
 		<cfinclude template="_versioning/approveEmail_draft.cfm">
	</cffunction>

	<cffunction name="approveEmail_approved_dd" access="public" hint="Sends out email informing lastupdated user that object has been approved">
		<cfargument name="objectId" type="UUID" required="true" hint="The ObjectId of object that has had status changed">
		<cfargument name="comment" type="string" required="true" hint="Comments that were entered when status was changed">
		<cfargument name="lApprovers" type="string" required="true" hint="List of approvers to send email to" default="all">
		
 		<cfinclude template="_versioning/approveEmail_approved_dd.cfm">
	</cffunction>
	
	<cffunction name="approveEmail_pending_dd" access="public" hint="Sends out email to list of approvers to approve/decline object">
		<cfargument name="objectId" type="UUID" required="true" hint="The ObjectId of object that has had status changed">
		<cfargument name="comment" type="string" required="true" hint="Comments that were entered when status was changed">
		
 		<cfinclude template="_versioning/approveEmail_pending_dd.cfm">
	</cffunction>
	
	<cffunction name="approveEmail_draft_dd" access="public" hint="Sends out email informing lastupdated user that object has been sent back to draft">
		<cfargument name="objectId" type="UUID" required="true" hint="The ObjectId of object that has had status changed">
		<cfargument name="comment" type="string" required="true" hint="Comments that were entered when status was changed">
		
 		<cfinclude template="_versioning/approveEmail_draft_dd.cfm">
	</cffunction>
	
	<cffunction name="checkIsDraft" access="public" returntype="query" hint="Checks to see if object is an underlying draft object">
		<cfargument name="objectId" type="UUID" required="true" hint="The ObjectId of object to be checked">
		<cfargument name="type" type="string" required="true" hint="Object type to be checked">
		<cfargument name="dsn" type="string" default="#application.dsn#" required="true" hint="Database DSN">
		
 		<cfinclude template="_versioning/checkIsDraft.cfm">
		
		<cfreturn qCheckIsDraft>
	</cffunction>
</cfcomponent>