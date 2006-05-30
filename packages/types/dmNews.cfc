<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/dmNews.cfc,v 1.20.2.1 2005/12/02 05:13:46 guy Exp $
$Author: guy $
$Date: 2005/12/02 05:13:46 $
$Name: milestone_3-0-1 $
$Revision: 1.20.2.1 $

|| DESCRIPTION || 
$Description: dmNews Type $
TODO: working on potential versioning/generic admin replacement 20050602GB

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $

--->
<cfcomponent extends="farcry.farcry_core.packages.types.versions" displayname="News" hint="Dynamic news data" bSchedule="1" bFriendly="1">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty name="aObjectIds" type="array" hint="Mixed type children objects that sit underneath this object" required="no" default="" 
	ftJoin="dmImage"
	ftLibraryPickListClass="thumbNailsWrap"
	ftLibrarySelectedListClass="thumbNailsWrap"	ftLibrarySelectedListStyle="margin-left:10px;"
	ftLibraryAddNewMethod="ftEdit">
<cfproperty name="aRelatedIDs" type="array" hint="Holds object pointers to related objects.  Can be of mixed types." required="no" default="" 
	ftJoin="dmFile"
	ftLibraryPickListClass="thumbNailsWrap"
	ftLibrarySelectedListClass="thumbNailsWrap"	ftLibrarySelectedListStyle="margin-left:10px;"
	ftLibraryAddNewMethod="AddNew">
<cfproperty name="publishDate" type="date" hint="The date that a news object is sent live and appears on the public website" required="no" default="" ftDefaultType="Evaluate" ftDefault="now()" ftType="datetime" ftDateFormatMask="dd mmm yyyy" ftTimeFormatMask="hh:mm tt" ftToggleOffDateTime="true">
<cfproperty name="expiryDate" type="date" hint="The date that a news object is removed from the web site" required="no" default="" ftDefaultType="Evaluate" ftDefault="DateAdd('d', 5, now())" ftType="datetime" ftDateFormatMask="dd mmm yyyy" ftTimeFormatMask="hh:mm tt" ftToggleOffDateTime="true">
<cfproperty name="Title" type="nstring" hint="Title of object.  *perhaps this should be deprecated for object label*" required="no" default="">
<cfproperty name="Teaser" type="longchar" hint="Teaser text." required="no" default="">
<cfproperty name="Body" type="longchar" hint="Main body of content." required="no" default="" ftType="RichText">
<cfproperty name="source" type="string" hint="source of the information contained in the content" required="no" default="">
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
	<cfinclude template="_dmNews/edit.cfm">
</cffunction>

<!--- <cffunction name="renderObjectOverview" hint="just over riding edit overview for now">
	<cfargument name = "ObjectId">
</cffunction> --->
</cfcomponent>



