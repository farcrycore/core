<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2006, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: $
$Author: $
$Date: $
$Name: $
$Revision: $

|| DESCRIPTION || 
$Description: dmImage type $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $
--->
<cfcomponent extends="types" displayname="Image" hint="Image Media" bUseInTree="1">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty ftSeq="1" ftFieldset="General Details" name="title" type="nstring" hint="Image title." required="no" default="" blabel="true" ftlabel="Image Title" /> 
<cfproperty ftSeq="2" ftFieldset="General Details" name="alt" type="nstring" hint="Alternate text" required="no" default="" ftlabel="Alternative Text" /> 
<cfproperty ftSeq="5" ftFieldset="General Details" name="bLibrary" type="numeric" hint="Flag to indictae if in file library or not" required="no" default="1" ftType="boolean" ftlabel="Add to Library" />
<cfproperty ftSeq="6" ftFieldset="General Details" name="status" type="string" hint="Status of the node (draft, pending, approved)." required="yes" default="draft" ftlabel="Status" />

<!--- image file locations --->
<cfproperty ftSeq="10" ftFieldset="Image Files" name="SourceImage" type="string" hint="The URL location of the uploaded image" required="No" default="" ftType="Image" ftCreateFromSourceOption="false" ftDestination="/images/SourceImage" ftlabel="Source Image" />
<cfproperty ftSeq="11" ftFieldset="Image Files" name="StandardImage" type="string" hint="The URL location of the optimised uploaded image that should be used for general display" required="no" default="" ftType="Image" ftDestination="/images/StandardImage" ftImageWidth="600" ftImageHeight="600" ftAutoGenerateType="FitInside" ftSourceField="SourceImage" ftCreateFromSourceDefault="true" ftAllowUpload="true" ftlabel="Mid Size Image" />  
<cfproperty ftSeq="12" ftFieldset="Image Files" name="ThumbnailImage" type="string" hint="The URL location of the thumnail of the uploaded image that should be used in " required="no" default="" ftType="Image"  ftDestination="/images/ThumbnailImage" ftImageWidth="80" ftImageHeight="80" ftAutoGenerateType="Pad" ftPadColor="##000000" ftSourceField="SourceImage" ftCreateFromSourceDefault="true" ftAllowUpload="true" ftlabel="Thumbnail Image" />  

<!--- image categorisation --->
<cfproperty ftSeq="20" ftFieldset="Categorisation" name="imageCategory" type="string" hint="Image categorisation." required="no" default="" ftlabel="Category" fttype="category" ftalias="dmimage" ftselectmultiple="true" />

<!--- deprecated: legacy image properties --->
<cfproperty name="width" type="nstring" hint="Image width (blank for default)" required="no" default="">  
<cfproperty name="height" type="nstring" hint="Image height (blank for default)" required="no" default="">  
<cfproperty name="bAutoGenerateThumbnail" type="numeric" hint="Flag to indicate if to automatically generate a thumbnail form the default image" required="no" default="1" ftType="boolean">
<cfproperty name="imagefile" type="string" hint="The image file to be uploaded" required="No" default="">
<cfproperty name="thumbnail" type="string" hint="The name of the thumbnail image to be uploaded" required="no" default="">  
<cfproperty name="optimisedImage" type="string" hint="The name of the optimised image to be uploaded" required="no" default="">  
<cfproperty name="originalImagePath" type="string" hint="The location in the filesystem where the original image is stored." required="No" default=""> 
<cfproperty name="thumbnailImagePath" editHandler="void" type="string" hint="The location in the filesystem where the thumbnail image is stored." required="no" default=""> 
<cfproperty name="optimisedImagePath" editHandler="void" type="string" hint="The location in the filesystem where the optimized image is stored." required="no" default=""> 

<!--- import tag libraries --->
<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >


<cffunction name="ftEdit" access="public" output="true" returntype="void">
	<cfargument name="ObjectID" required="no" type="string" default="">
	
	<ft:object typename="#getTablename()#" objectID="#arguments.ObjectID#" lFields="ImageFile" inTable=0 />
	<cfoutput>
	<a href="##" onclick="Effect.toggle('edsubpanel','slide');">Advanced options</a>
	<div id="edsubpanel" style="display:none;">
	<div>		
		<ft:object typename="#getTablename()#" objectID="#arguments.ObjectID#" lFields="Title,Alt,width,height,bLibrary,status" inTable=0 />
	</div>
	</div>
	</cfoutput>
</cffunction>


<cffunction name="AddNew" access="public" output="true" returntype="void">
	<cfargument name="typename" required="true" type="string">
	<cfargument name="lFields" required="false" type="string" default="">
	
	<ft:object typename="#arguments.typename#" lfields="Title,SourceImage" inTable=0 />

</cffunction>



<cffunction name="ftDisplayThumbnail" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to display.">
	<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
	<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
	<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
	<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

	<cfparam name="arguments.stMetadata.ftDestination" default="/images">

	<cfset Request.inHead.Lightbox = 1>
	<cfsavecontent variable="html">
		<cfoutput>
		<cfif structKeyExists(stobject, "OptimisedImage") AND len(stObject.OptimisedImage)>
			<a href="#stObject.OptimisedImage#" rel="lightbox[Collections]">
				<img src="#arguments.stMetadata.value#">
			</a><br />			
			&nbsp;&nbsp;&nbsp;&nbsp;    
			
			 
			
		<cfelse>
			<img src="#arguments.stMetadata.value#">
		</cfif>
		</cfoutput>	

	</cfsavecontent>
	
	<cfreturn html>
</cffunction>
	


<cffunction name="editdud" access="public">
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
	<cfset var relatedTable = "">

	<cfset stReturn.bSuccess = true>
	<cfset stReturn.message = "">
		
	<cfset stLocal.errormessage = "">
	<!--- check if image is associated with any content items --->
	<cfset stLocal.lrelatedContentTypes = "dmNews,dmNavigation,dmHTML,dmEvent">

	<cfloop index="stLocal.relatedContentType" list="#stLocal.lrelatedContentTypes#">
		
		<cfif stLocal.relatedContentType IS "dmNews">
			<cfset relatedTable = "#application.dbowner##stLocal.relatedContentType#_aObjectIds">
		<cfelse>	
			<cfset relatedTable = "#application.dbowner##stLocal.relatedContentType#_aObjectIDs">
		</cfif>
		
		<cfquery name="stLocal.qCheck" datasource="#application.dsn#">
		SELECT	parentId
		FROM	#relatedTable#
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
	
	<cfif Len(application.url.webroot) AND application.url.webroot NEQ "/" >
		<cfset imagePath= application.url.webroot >
	<cfelse>
		<cfset imagePath= "" >
	</cfif>

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


</cfcomponent>
