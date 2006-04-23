<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/dmCSS.cfc,v 1.8 2003/09/10 23:46:11 brendan Exp $
$Author: brendan $
$Date: 2003/09/10 23:46:11 $
$Name: b201 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: dmCSS type $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent extends="types" displayname="CSS" hint="CSS objects influence the look and feel of the website" bUseInTree="1" >
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty name="title" type="nstring" hint="Meaningful reference title for file" required="no" default=""> 
<cfproperty name="filename" type="string" hint="The name of the CSS file to be used" required="no" default="">  
<cfproperty name="description" type="longchar" hint="A description of the file to be uploaded" required="No" default=""> 

<!--- Object Methods --->

<cffunction name="edit" access="public">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfinclude template="_dmCSS/edit.cfm">
</cffunction>

</cfcomponent>