<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/dmImage.cfc,v 1.23 2005/10/29 12:20:34 geoff Exp $
$Author: geoff $
$Date: 2005/10/29 12:20:34 $
$Name: milestone_3-0-0 $
$Revision: 1.23 $

|| DESCRIPTION || 
$Description: dmImage type $


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
<cfproperty name="bLibrary" type="numeric" hint="Flag to indictae if in file library or not" required="no" default="1">
<cfproperty name="bAutoGenerateThumbnail" type="numeric" hint="Flag to indicate if to automatically generate a thumbnail form the default image" required="no" default="1">
<cfproperty name="status" type="string" hint="Status of the node (draft, pending, approved)." required="yes" default="draft">
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

<cffunction name="delete" access="public" hint="Specific delete method for dmImage. Removes physical files from ther server." returntype="struct">
	<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
	
	<cfset var stLocal = StructNew()>
	<!--- get object details --->
	<cfset var stObj = getData(arguments.objectid)>
	<cfset var stReturn = StructNew()>

	<cfset stReturn.bSuccess = true>
	<cfset stReturn.message = "">
		
	<cfset stLocal.errormessage = "">
	<!--- check if image is associated with any content items --->
	<cfset stLocal.lrelatedContentTypes = "dmNews,dmNavigation,dmHtml,dmEvent">

	<cfloop index="stLocal.relatedContentType" list="#stLocal.lrelatedContentTypes#">
		<cfquery name="stLocal.qCheck" datasource="#application.dsn#">
		SELECT	objectid
		FROM	#application.dbowner##stLocal.relatedContentType#_aobjectids
		WHERE	data = '#arguments.objectid#'
		</cfquery>

		<cfif stLocal.qCheck.recordcount GTE 1>
			<cfset stReturn.bSuccess = false>
			<cfset stReturn.message = stReturn.message & "Sorry image [#stObj.label#] cannot be delete because it is associated to <strong>#stLocal.qCheck.recordcount# #stLocal.relatedContentType#</strong> item(s).<br />">
		</cfif>
	</cfloop>

	<cfif stReturn.bSuccess EQ true>
		<cfinclude template="_dmImage/delete.cfm">
	</cfif>
	<cfreturn stReturn>
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

<cffunction name="getURLImagePath" returntype="string" hint="returns the image path for either thumb, optimised or original - depending on what is passed in" access="public">
	<cfargument name="objectid" type="string" hint="Image Object id">
	<cfargument name="imageType" type="string" hint="thumb, optimised or original">
	
	<cfset var stObject = structnew()>
	<cfset stObject = getData(arguments.objectid)>

	<cfif not structIsEmpty(stObject)>
		<cfswitch expression="#lcase(imageType)#">
			<cfcase value="thumb">
				<cfreturn rendorURLImagePath(stObject.thumbnailImagePath, stObject.thumbnail)>
			</cfcase>
			<cfcase value="optimised">
				<cfreturn rendorURLImagePath(stObject.optimisedImagePath, stObject.optimisedImage)>
			</cfcase>
			<cfcase value="original">
				<cfreturn rendorURLImagePath(stObject.originalImagePath, stObject.imagefile)>
			</cfcase>
			<cfdefaultcase>
				<cfthrow message="You must pass either thumb, optimised or original for the imageType argument">
			</cfdefaultcase>
		</cfswitch>
	<cfelse>
		<cfthrow message="The image stObject must be a valid structure with values">
	</cfif>
</cffunction>

<cffunction name="rendorURLImagePath" returntype="string" access="private" hint="returns the thumb image path" output="false">
	<cfargument name="filePath" type="string" hint="file path of thumbnail" required="true">
	<cfargument name="fileName" type="string" hint="file name of thumbnail" required="true">
	
	<cfset imagePath="">
	<cfif len(filePath) and len(fileName)>
		<!--- change all backslashes to forward slashes --->
		<cfset filePath = replace(filePath, "\", "/", "all")>
		<cfset imagePos = listfindNoCase(filePath, "images", "/")>
		<!--- create a new imagepath string by looping over filePath as a list and getting all elements after and including "images" --->
		<cftry>
		<cfloop from="#imagePos#" to ="#listlen(filePath, '/')#" index="i">
			<cfset listElement = listgetAt(filePath, i, "/")>
			<cfset imagePath = "#imagePath#/#listElement#">
		</cfloop>
		<!--- add the file name onto the filepath --->
		<cfset imagePath="#imagePath#/#arguments.filename#">
		
		<cfcatch type="any">
			<cftrace type="error" text="Unable to determine imagepath. filepath: #arguments.filepath# filename: #arguments.filename#" category="dmimage">
		</cfcatch>
		</cftry>
	<cfelse>
		<cftrace category="dmImage" type="warning" text="The filePath or fileName passed to function rendorURLImagePath in dmImage.cfc is empty which will cause the image not to display">
	</cfif>
	<cfreturn imagePath>
</cffunction>

<cffunction name="setFriendlyURL" access="public" returntype="struct" hint="the default set friendly url for an object." output="false">
	<cfargument name="stProperties" required="true" type="struct">
	
	<cfset var stLocal = structnew()>
	<cfset stLocal.returnstruct = StructNew()>
	<cfset stLocal.returnstruct.bSuccess = 1>
	<cfset stLocal.returnstruct.message = "">
	
	<cfset stLocal.stFriendlyURL = StructNew()>
	<cfset stLocal.stFriendlyURL.objectid = arguments.stProperties.objectid>
	<cfset stLocal.stFriendlyURL.friendlyURL = "">
	<cfset stLocal.stFriendlyURL.querystring = "">
	<!--- 
			<cfset stLocal.objFU = CreateObject("component","#Application.packagepath#.farcry.fu")>
			<!--- used to retrieve default of where item is in tree --->
			<cfset stLocal.objNavigation = CreateObject("component","#Application.packagepath#.types.dmnavigation")>
	
			<!--- This determines the friendly url by where it sits in the navigation node  --->
			<cfset stLocal.qNavigation = stLocal.objNavigation.getParent(arguments.stProperties.objectid)>
	
			<cfif stLocal.qNavigation.recordcount>
				<cfset stLocal.stFriendlyURL.friendlyURL = stLocal.objFU.createFUAlias(stLocal.qNavigation.objectid)>
			<cfelse> <!--- generate friendly url based on content type --->
				<cfif StructkeyExists(application.types[arguments.stProperties.typename],"displayName")>
					<cfset stLocal.stFriendlyURL.friendlyURL = "/#application.types[arguments.stProperties.typename].displayName#">
				<cfelse>
					<cfset stLocal.stFriendlyURL.friendlyURL = "/#ListLast(application.types[arguments.stProperties.typename].name,'.')#">
				</cfif>
			</cfif>
	
			<cfset stLocal.stFriendlyURL.friendlyURL = stLocal.stFriendlyURL.friendlyURL & "/#arguments.stProperties.label#">
			<cfset stLocal.objFU.setFU(stLocal.stFriendlyURL.objectid, stLocal.stFriendlyURL.friendlyURL, stLocal.stFriendlyURL.querystring)>
	 --->
	<cfreturn stLocal.returnstruct>
</cffunction>
</cfcomponent>