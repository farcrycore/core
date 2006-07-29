<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/dmEvent.cfc,v 1.11.2.1 2005/12/02 05:13:46 guy Exp $
$Author: guy $
$Date: 2005/12/02 05:13:46 $
$Name: milestone_3-0-1 $
$Revision: 1.11.2.1 $

|| DESCRIPTION || 
$Description: dmEvent Type $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

--->
<cfcomponent extends="farcry.farcry_core.packages.types.versions" displayname="Events" hint="Dynamic events data" bSchedule="1" bFriendly="1">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty name="aObjectIDs" type="array" hint="Mixed type children objects that sit underneath this object" required="no" default="">
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
<cfproperty name="teaserImage" type="string" hint="UUID of image to display in teaser" required="no" default="">

<!------------------------------------------------------------------------
object methods 
------------------------------------------------------------------------->	
<cffunction name="edit" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = getData(arguments.objectid)>
	<cfinclude template="_dmEvent/edit.cfm">
</cffunction>

</cfcomponent>


