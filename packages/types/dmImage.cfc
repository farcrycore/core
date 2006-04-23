<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/dmImage.cfc,v 1.12 2004/03/17 03:49:41 brendan Exp $
$Author: brendan $
$Date: 2004/03/17 03:49:41 $
$Name: milestone_2-2-1 $
$Revision: 1.12 $

|| DESCRIPTION || 
$Description: dmImage type $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent extends="types" displayname="Image" hint="Image objects" bUseInTree="1">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty name="title" type="nstring" hint="Image title." required="no" default=""> 
<cfproperty name="alt" type="nstring" hint="Alternate text" required="no" default="" > 
<cfproperty name="width" type="nstring" hint="Image width" required="no" default="">  
<cfproperty name="height" type="nstring" hint="Image height" required="no" default="">  
<cfproperty name="imagefile" type="string" hint="The image file to be uploaded" required="No" default="">
<cfproperty name="thumbnail" type="string" hint="The name of the thumbnail image to be uploaded" required="no" default="">  
<cfproperty name="optimisedImage" type="string" hint="The name of the optimised image to be uploaded" required="no" default="">  
<cfproperty name="originalImagePath" type="string" hint="The location in the filesystem where the original image is stored." required="No" default=""> 
<cfproperty name="thumbnailImagePath" editHandler="void" type="string" hint="The location in the filesystem where the thumbnail image is stored." required="no" default=""> 
<cfproperty name="optimisedImagePath" editHandler="void" type="string" hint="The location in the filesystem where the optimized image is stored." required="no" default=""> 

<!--- Object Methods --->

<cffunction name="edit" access="public">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	
	<cfinclude template="_dmImage/edit.cfm">
</cffunction>

<cffunction name="display" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfinclude template="_dmImage/display.cfm">
</cffunction>

<cffunction name="delete" access="public" hint="Specific delete method for dmImage. Removes physical files from ther server.">
	<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
	
	<!--- get object details --->
	<cfset stObj = getData(arguments.objectid)>
	<cfinclude template="_dmImage/delete.cfm">
</cffunction>

<cffunction name="checkForExisting" access="public" output="No" returntype="struct" hint="Checks to see if an existing image object already uses that name">
	<cfargument name="filename" required="yes" type="string" hint="Filename of the new image being uploaded">
	<cfargument name="dsn" required="no" type="string" default="#application.dsn#">
	<cfargument name="dbowner" required="no" type="string" default="#application.dbowner#">
	
	<cfset var stCheck = structNew()>
	<cfset var newFileName = "">
	<cfset var qCheck = "">
	
	<!--- prepare filename --->
	<cfset newFileName = listLast(replace(arguments.filename,"\","/","all"),"/")>
	
	<!--- check if existing objects use the same filename --->
	<cfquery name="qCheck" datasource="#arguments.dsn#">
		select objectid
		from #arguments.dbowner#dmImage
		where imagefile = '#newFileName#' or 
			thumbnail = '#newFileName#' or 
			optimisedImage = '#newFileName#'
	</cfquery>
	
	<!--- if query returned an object it means another object is using the same image name --->
	<cfif qCheck.recordcount>
		<cfset stCheck.bExists = 1>
		<cfset stCheck.fileName = newFileName>
	<cfelse>
		<cfset stCheck.bExists = 0>
	</cfif>
	
	<cfreturn stCheck>
</cffunction>

</cfcomponent>