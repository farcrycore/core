<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/dmEvent.cfc,v 1.3 2003/06/26 04:06:29 brendan Exp $
$Author: brendan $
$Date: 2003/06/26 04:06:29 $
$Name: b131 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: dmEvent Type $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

--->
<cfcomponent extends="types" displayname="Events" hint="Dynamic events data" bSchedule="1">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty name="aObjectIds" type="array" hint="Mixed type children objects that sit underneath this object" required="no" default="">
<cfproperty name="publishDate" type="date" hint="The date that a event object is sent live and appears on the public website" required="no" default="">
<cfproperty name="expiryDate" type="date" hint="The date that a event object is removed from the web site" required="no" default="">
<cfproperty name="startDate" type="date" hint="The start date of the event" required="no" default="">
<cfproperty name="endDate" type="date" hint="The end date of the event" required="no" default="">
<cfproperty name="Title" type="nstring" hint="Title of object." required="no" default="">
<cfproperty name="Location" type="nstring" hint="Location of event" required="no" default="">
<cfproperty name="Teaser" type="longchar" hint="Teaser text." required="no" default="">
<cfproperty name="Body" type="longchar" hint="Main body of content." required="no" default="">
<cfproperty name="displayMethod" type="string" hint="Display method to render." required="yes" default="display">
<cfproperty name="status" type="string" hint="Status of the node (draft, pending, approved)." required="yes" default="draft">
<cfproperty name="commentlog" type="longchar" hint="Workflow comment log." required="no" default="">

<!------------------------------------------------------------------------
object methods 
------------------------------------------------------------------------->	
<cffunction name="edit" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = getData(arguments.objectid)>
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_dmEvent/edit.cfm">
</cffunction>

</cfcomponent>

