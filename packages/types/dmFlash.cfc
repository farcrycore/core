<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/dmFlash.cfc,v 1.13 2005/09/16 00:56:13 guy Exp $
$Author: guy $
$Date: 2005/09/16 00:56:13 $
$Name: milestone_3-0-1 $
$Revision: 1.13 $

|| DESCRIPTION || 
$Description: dmFlash type $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent extends="types" displayname="Flash" hint="Forms the basis of the content framework of the site.  Displays a flash movie in the page." bSchedule="1" bUseInTree="1">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty ftSeq="1" ftFieldSet="General Details" name="Title" type="nstring" hint="Title of object.  *perhaps this should be deprecated for object label*" required="no" default="">
<cfproperty ftSeq="2" ftFieldSet="General Details" name="Teaser" type="longchar" hint="Teaser text." required="no" default="">
<cfproperty ftSeq="3" ftFieldSet="General Details" name="displayMethod" type="string" hint="Display method to render this HTML object with." required="yes" default="display" ftType="webskin" ftPrefix="displayPage">
<cfproperty ftSeq="4" ftFieldSet="General Details" name="metaKeywords" type="nstring" hint="HTML head section metakeywords." required="no" default="">

<cfproperty ftSeq="10" ftFieldSet="Movie Details" name="flashMovie" type="string" hint="The name of the flash movie" required="No" default="" ftType="file" ftDestination="/dmFlash/flashMovie"> 
<cfproperty ftSeq="11" ftFieldSet="Movie Details" name="flashVersion" type="string" hint="version of flash player required" required="No" default="6,0,0,0">
<cfproperty ftSeq="12" ftFieldSet="Movie Details"  name="flashParams" type="string" hint="paremeters to be passed to flash movie" required="No" default="">
<cfproperty ftSeq="13" ftFieldSet="Movie Details"  name="flashHeight" type="numeric" hint="height of flash movie in pixels" required="No" default="0">
<cfproperty ftSeq="14" ftFieldSet="Movie Details"  name="flashWidth" type="numeric" hint="width of flash movie in pixels" required="No" default="0">
<cfproperty ftSeq="15" ftFieldSet="Movie Details"  name="flashQuality" type="string" hint="The quality of the flash movie" required="no" default="high"> 
<cfproperty ftSeq="16" ftFieldSet="Movie Details"  name="flashAlign" type="string" hint="The alignment of the flash movie" required="no" default="center"> 
<cfproperty ftSeq="17" ftFieldSet="Movie Details"  name="flashBgcolor" type="string" hint="The background colour of the flash movie" required="no" default="##FFFFFF"> 
<cfproperty ftSeq="18" ftFieldSet="Movie Details"  name="flashLoop" type="boolean" hint="Whether or not to loop over flash movie" required="yes" default="0" ftType="list" ftList="1:true,0:false"> 
<cfproperty ftSeq="19" ftFieldSet="Movie Details"  name="flashPlay" type="boolean" hint="Play flash movie straight away?" required="yes" default="1" ftType="list" ftList="1:true,0:false"> 
<cfproperty ftSeq="20" ftFieldSet="Movie Details"  name="flashMenu" type="boolean" hint="Display options menu in flash movie" required="yes" default="0" ftType="list" ftList="1:true,0:false"> 

<cfproperty name="bLibrary" type="boolean" hint="Flag to indictae if in file library or not" required="no" default="1">
<cfproperty name="commentlog" type="longchar" hint="Workflow comment log." required="no" default="">
<cfproperty name="status" type="string" hint="Status of movie - draft,pending or approved" required="No" default="">

<!------------------------------------------------------------------------
object methods 
------------------------------------------------------------------------->	
<!--- <cffunction name="edit" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfinclude template="_dmFlash/edit.cfm">
</cffunction>

<cffunction name="display" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfinclude template="_dmFlash/display.cfm">
</cffunction>

<cffunction name="delete" access="public" hint="Specific delete method for dmFlash. Removes physical files from ther server." returntype="struct">
	<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
	
	<!--- get object details --->
	<cfset var stObj = getData(arguments.objectid)>
	<cfset var stReturn = StructNew()>
	<cfset stReturn.bSuccess = 1>
	<cfset stReturn.message = "dmFlash item successfully dleted.">
	
	<cfinclude template="_dmFlash/delete.cfm">
	<cfreturn stReturn>
</cffunction> --->

</cfcomponent>