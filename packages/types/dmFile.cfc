<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/dmFile.cfc,v 1.11 2003/09/12 06:42:49 brendan Exp $
$Author: brendan $
$Date: 2003/09/12 06:42:49 $
$Name: b201 $
$Revision: 1.11 $

|| DESCRIPTION || 
$Description: dmFile type $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent extends="types" displayname="File"  hint="File objects" bUseInTree="1">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty name="title" type="nstring" hint="Meaningful reference title for file" required="no" default=""> 
<cfproperty name="filename" type="string" hint="The name of the file to be uploaded" required="no" default="">  
<cfproperty name="filepath" type="string" hint="The location of the file on the webserver" required="no" default="">  
<cfproperty name="description" type="longchar" hint="A description of the file to be uploaded" required="No" default=""> 

<!--- Object Methods --->

<cffunction name="edit" access="public">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfinclude template="_dmFile/edit.cfm">
</cffunction>

<cffunction name="display" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfinclude template="_dmFile/display.cfm">
</cffunction>

<cffunction name="delete" access="public" hint="Specific delete method for dmFile. Removes physical files from ther server.">
	<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
	
	<!--- get object details --->
	<cfset stObj = getData(arguments.objectid)>
	<cfinclude template="_dmFile/delete.cfm">
</cffunction>	

</cfcomponent>