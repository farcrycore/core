<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/dmLink.cfc,v 1.11.2.1 2005/12/02 05:13:46 guy Exp $
$Author: guy $
$Date: 2005/12/02 05:13:46 $
$Name: milestone_3-0-1 $
$Revision: 1.11.2.1 $

|| DESCRIPTION || 
$Description: dmLink type $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent extends="types" displayname="Link" hint="A way of linking to external pages" bSchedule="1" bUseInTree="1" bFriendly="1">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty name="title" type="nstring" hint="Meaningful reference title for link" required="no" default=""> 
<cfproperty name="teaser" type="longchar" hint="A brief description of the link" required="no" default="">  
<cfproperty name="link" type="string" hint="Url of link" required="no" default=""> 
<cfproperty name="commentlog" type="longchar" hint="Workflow comment log." required="no" default=""> 
<cfproperty name="status" type="string" hint="Status of the node (draft, pending, approved)." required="yes" default="draft">
<cfproperty name="displayMethod" type="string" hint="Display method to render this link object with." required="yes" default="displaypage">

<!--- Object Methods --->

<cffunction name="edit" access="public">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfinclude template="_dmLink/edit.cfm">
</cffunction>

<cffunction name="display" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfinclude template="_dmLink/display.cfm">
</cffunction>

</cfcomponent>