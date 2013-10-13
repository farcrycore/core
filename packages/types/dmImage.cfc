<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<cfcomponent 
	extends="types" 
	displayname="Image" hint="A global image library that can be referenced from other content types. All images have a source image and an automatically generated standard and thumbnail size image for use within your content."
	bBulkUpload="true"
	icon="icon-picture">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty 
	name="title" type="string" hint="Image title." required="no" default="" blabel="true" 
	ftSeq="2" ftFieldset="General Details" ftlabel="Image Title" ftValidation="required"
	ftBulkUploadEdit="true" />

<cfproperty 
	name="alt" type="string" dbprecision="1000" hint="Alternate text" required="no" default=""
	ftSeq="4" ftFieldset="General Details" ftlabel="Alternative Text"
	fttype="longchar" ftlimit="999"
	ftBulkUploadEdit="true" /> 

<!--- image file locations --->
<cfproperty 
	name="SourceImage" type="string" hint="The URL location of the uploaded image" required="No" default="" 
	ftSeq="22" ftFieldset="Image Files" ftlabel="Source Image" 
	ftType="Image" 
	ftCreateFromSourceOption="false" 
	ftAllowResize="false"
	ftDestination="/images/dmImage/SourceImage" 
	ftImageWidth="2048" 
	ftImageHeight="2048"
	ftAutoGenerateType="FitInside"
	ftbUploadOnly="true"
	ftBulkUploadTarget="true"
	ftHint="Upload your high quality source image here."  />

<cfproperty ftSeq="24" ftFieldset="Image Files" name="StandardImage" type="string" hint="The URL location of the optimised uploaded image that should be used for general display" required="no" default="" 
	ftType="Image" 
	ftDestination="/images/dmImage/StandardImage" 
	ftImageWidth="700" 
	ftAutoGenerateType="FitInside" 
	ftSourceField="SourceImage" 
	ftCreateFromSourceDefault="true" 
	ftAllowUpload="true" 
	ftQuality=".85"
	ftlabel="Mid Size Image"
	ftHint="Mid-size image is used for the body content of your pages." />  

<cfproperty 
	name="ThumbnailImage" type="string" hint="The URL location of the thumnail of the uploaded image that should be used in " required="no" default="" 
	ftSeq="26" ftFieldset="Image Files" ftlabel="Thumbnail Image"
	ftType="Image"  
	ftDestination="/images/dmImage/ThumbnailImage" 
	ftImageWidth="80" 
	ftImageHeight="80" 
	ftAutoGenerateType="center"
	ftSourceField="SourceImage" 
	ftCreateFromSourceDefault="true" 
	ftAllowUpload="true" 
	ftQuality=".85"
	ftHint="Thumbnail image is used a teaser or admin preview image." />

<!--- image categorisation --->
<cfproperty 
	name="catImage" type="string" dbprecision="1000" hint="Image categorisation." required="no" default="" 
	ftSeq="42" ftFieldset="Categorisation" ftlabel="Category" 
	fttype="category" ftalias="dmimage" ftselectmultiple="true"
	ftBulkUploadDefault="true" />

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >

<cffunction name="ftDisplayThumbnail" access="public" output="false" returntype="string" hint="Override display of filepath to show image in formtool display mode.">
	<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
	<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
	<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
	<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

	<cfset var html	= '' />

	<cfparam name="arguments.stMetadata.ftDestination" default="/images">

	<cfsavecontent variable="html">
		<cfoutput>
			<img src="#arguments.stMetadata.value#">
		</cfoutput>	
	</cfsavecontent>
	
	<cfreturn html>
</cffunction>
	
<cffunction name="delete" access="public" hint="Specific delete method for dmImage. Removes physical files from ther server." returntype="struct">
	<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
	
	<cfset var stLocal = StructNew()>
	<!--- get object details --->
	<cfset var stObj = getData(arguments.objectid)>
	<cfset var stReturn = StructNew()>
	<cfset var relatedTable = "">
	<cfset var type	= '' />
	<cfset var prop	= '' />

	<cfset stReturn.bSuccess = true>
	<cfset stReturn.message = "">
		
	<cfset stLocal.errormessage = "">

	<cfset stLocal.relatedQty = 0 />
	
	<cfloop collection="#application.stcoapi#" item="type">
		<cfloop collection="#application.stcoapi[type].stProps#" item="prop">
			<cfif application.stcoapi[type].stProps[prop].metadata.type EQ "array" AND structKeyExists(application.stcoapi[type].stProps[prop].metadata,"ftJoin") and listFindNoCase(application.stcoapi[type].stProps[prop].metadata.ftJoin, "dmimage")>
				<cfquery name="stLocal.qCheck" datasource="#application.dsn#">
				SELECT	parentId
				FROM	#type#_#prop#
				WHERE	data = '#arguments.objectid#'
				</cfquery>
				
				<cfif stLocal.qCheck.recordCount>
					<cfset stLocal.relatedQty = stLocal.relatedQty + stLocal.qCheck.recordCount />
				</cfif>
			<cfelseif application.stcoapi[type].stProps[prop].metadata.type EQ "uuid" AND structKeyExists(application.stcoapi[type].stProps[prop].metadata,"ftJoin") and listFindNoCase(application.stcoapi[type].stProps[prop].metadata.ftJoin, "dmimage")>
				<cfquery name="stLocal.qCheck" datasource="#application.dsn#">
				SELECT	objectid
				FROM	#type#
				WHERE	#prop# = '#arguments.objectid#'
				</cfquery>
				
				<cfif stLocal.qCheck.recordCount>
					<cfset stLocal.relatedQty = stLocal.relatedQty + stLocal.qCheck.recordCount />
				</cfif>			
			</cfif>
		</cfloop>
	</cfloop>

	<cfif stLocal.relatedQty GTE 1>
		<cfset stReturn.bSuccess = false>
		<cfset stReturn.message = stReturn.message & "Sorry image [#stObj.label#] cannot be delete because it is associated to <strong>#stLocal.relatedQty#</strong> other item(s).<br />">
		<cfreturn stReturn>
	<cfelse>
		<cfreturn super.delete(argumentCollection=arguments) />
	</cfif>
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
				<cfreturn stObject.ThumbnailImage>
			</cfcase>
			<cfcase value="optimised">
				<cfreturn stObject.StandardImage>
			</cfcase>
			<cfcase value="original">
				<cfreturn stObject.SourceImage>
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
	
	<cfset var imagePath	= '' />
	<cfset var imagePos	= '' />
	<cfset var listElement	= '' />
	<cfset var i	= '' />

	<cfif Len(application.url.webroot) AND application.url.webroot NEQ "/" >
		<cfset imagePath= application.url.webroot >
	<cfelse>
		<cfset imagePath= "" >
	</cfif>

	<cfif len(arguments.filePath) and len(arguments.fileName)>
		<!--- change all backslashes to forward slashes --->
		<cfset arguments.filePath = replace(arguments.filePath, "\", "/", "all")>
		<cfset imagePos = listfindNoCase(arguments.filepath, "images", "/")>
		<!--- create a new imagepath string by looping over arguments.filepath as a list and getting all elements after and including "images" --->
		<cftry>
		<cfloop from="#imagePos#" to ="#listlen(arguments.filepath, '/')#" index="i">
			<cfset listElement = listgetAt(arguments.filepath, i, "/")>
			<cfset imagePath = "#imagePath#/#listElement#">
		</cfloop>
		<!--- add the file name onto the arguments.filepath --->
		<cfset imagePath="#imagePath#/#arguments.filename#">
		
		<cfcatch type="any">
			<cftrace type="error" text="Unable to determine imagepath. arguments.filepath: #arguments.filepath# arguments.filename: #arguments.filename#" category="dmimage">
		</cfcatch>
		</cftry>
	<cfelse>
		<cftrace category="dmImage" type="warning" text="The arguments.filepath or arguments.fileName passed to function rendorURLImagePath in dmImage.cfc is empty which will cause the image not to display">
	</cfif>
	<cfreturn imagePath>
</cffunction>

<cffunction name="BeforeSave" access="public" output="false" returntype="struct">
	<cfargument name="stProperties" required="true" type="struct">
	<cfargument name="stFields" required="true" type="struct">
	<cfargument name="stFormPost" required="false" type="struct">		
	
	<cfif not structkeyexists(arguments.stProperties,"title") or not len(arguments.stProperties.title) and structkeyexists(arguments.stProperties,"sourceImage")>
		<cfset arguments.stProperties.title = listfirst(listlast(arguments.stProperties.sourceImage,"/"),".") />
	</cfif>
	
	<cfif structkeyexists(arguments.stProperties,"title")>
		<cfset arguments.stProperties.label = arguments.stProperties.title />
	</cfif>
	
	<cfreturn super.beforeSave(argumentCollection=arguments) />
</cffunction>


</cfcomponent>