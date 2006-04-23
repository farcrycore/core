<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/dmHTML.cfc,v 1.23.2.1 2005/12/02 05:13:46 guy Exp $
$Author: guy $
$Date: 2005/12/02 05:13:46 $
$Name: milestone_3-0-1 $
$Revision: 1.23.2.1 $

|| DESCRIPTION || 
$Description: dmHTML Content Type. Forms the basis of the content framework of the site.  HTML objects include containers and static information. $
$TODO: <whatever todo's needed -- can be inline also>$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->

<cfcomponent extends="types" displayname="HTML Page" hint="Forms the basis of the content framework of the site.  HTML objects include containers and static information." bSchedule="1" bUseInTree="1" bFriendly="1">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty name="aObjectIDs" type="array" hint="Holds objects to be displayed at this particular node.  Can be of mixed types." required="no" default="">
<cfproperty name="aRelatedIDs" type="array" hint="Holds object pointers to related objects.  Can be of mixed types." required="no" default="">
<cfproperty name="Title" type="nstring" hint="Title of object.  *perhaps this should be deprecated for object label*" required="no" default="">
<cfproperty name="Teaser" type="longchar" hint="Teaser text." required="no" default="">
<cfproperty name="Body" type="longchar" hint="Main body of content." required="no" default="">
<cfproperty name="displayMethod" type="string" hint="Display method to render this HTML object with." required="yes" default="display">
<cfproperty name="metaKeywords" type="nstring" hint="HTML head section metakeywords." required="no" default="">
<cfproperty name="extendedmetadata" type="longchar" hint="HTML head section for extended keywords." required="no" default="">
<cfproperty name="commentlog" type="longchar" hint="Workflow comment log." required="no" default="">
<cfproperty name="versionID" type="uuid" hint="objectID of live object - used for versioning" required="no" default="">
<cfproperty name="teaserImage" type="string" hint="UUID of image to display in teaser" required="no" default="">
<cfproperty name="reviewDate" type="date" hint="The date for which the object will be reviewed" required="no" default="">
<cfproperty name="status" type="string" hint="Status of the node (draft, pending, approved)." required="yes" default="draft">
<!------------------------------------------------------------------------
object methods 
------------------------------------------------------------------------->	
<cffunction name="edit" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfinclude template="_dmhtml/edit.cfm">
</cffunction>

<cffunction name="display" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfinclude template="_dmhtml/display.cfm">
</cffunction>

<cffunction name="deleteRelatedIds" hint="Deletes references to a given uuid in the dmHTML_relatedIds table">
	<cfargument name="objectid" required="yes" type="uuid">
	<cfargument name="dsn" required="no" default="#application.dsn#">
	<cfargument name="dbowner" required="no" default="#application.dbowner#">
	
	<cfset var q = ''>
	<cfquery name="q" datasource="#arguments.dsn#">
		DELETE FROM #application.dbowner#dmHTML_aRelatedIDs
		WHERE objectid = '#arguments.objectid#'
	</cfquery>
	
</cffunction>
</cfcomponent>

