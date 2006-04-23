<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/dmArchive.cfc,v 1.2 2003/09/10 23:46:11 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 23:46:11 $
$Name: b201 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: dmArchive type $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent extends="types" displayname="dmArchive handler" hint="archive objects">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty name="archiveID" type="UUID" hint="ID of archived entry" required="no" default=""> 
<cfproperty name="objectWDDX" type="longchar" hint="WDDX packet that defines the object being archived" required="no" default="">  

<!--- Object Methods --->

<cffunction name="edit" access="public">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfinclude template="_dmArchive/edit.cfm">
</cffunction>
	
</cfcomponent>