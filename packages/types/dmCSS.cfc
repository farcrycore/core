<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/dmCSS.cfc,v 1.10 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-0 $
$Revision: 1.10 $

|| DESCRIPTION || 
$Description: dmCSS type $


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
<cfproperty name="title" type="nstring" hint="Meaningful reference title for file" required="no" default="" /> 
<cfproperty name="filename" type="string" hint="The name of the CSS file to be used" required="no" default="" />  
<cfproperty name="description" type="longchar" hint="A description of the file to be uploaded" required="No" default="" /> 
<cfproperty name="mediaType" type="string" hint="Specifies how a document is to be presented on different media" required="no" default="" />  
<cfproperty name="bThisNodeOnly" type="boolean" hint="Use css on this node only. No child inheritance" required="yes" default="0" />

<!--- Object Methods --->

<cffunction name="edit" access="public">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfinclude template="_dmCSS/edit.cfm">
</cffunction>

</cfcomponent>